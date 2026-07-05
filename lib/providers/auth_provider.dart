import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../auth/auth_api_client.dart';
import '../auth/session_store.dart';
import '../config/app_config.dart';

const _sentinel = Object();

enum AuthStatus { unknown, signedOut, awaitingOtp, signedIn }

class AuthState {
  final AuthStatus status;
  final TernUser? user;
  final String? pendingEmail;
  final bool isLoading;
  final String? error;
  final DateTime? otpSentAt;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.pendingEmail,
    this.isLoading = false,
    this.error,
    this.otpSentAt,
  });

  bool get canResendOtp {
    if (otpSentAt == null) return true;
    return DateTime.now().difference(otpSentAt!) > AppConfig.otpResendCooldown;
  }

  AuthState copyWith({
    AuthStatus? status,
    TernUser? user,
    String? pendingEmail,
    bool? isLoading,
    Object? error = _sentinel,
    Object? otpSentAt = _sentinel,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        pendingEmail: pendingEmail ?? this.pendingEmail,
        isLoading: isLoading ?? this.isLoading,
        error: identical(error, _sentinel) ? this.error : error as String?,
        otpSentAt: identical(otpSentAt, _sentinel) ? this.otpSentAt : otpSentAt as DateTime?,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiClient _api;
  final SessionStore _sessionStore;
  final GoogleSignIn _googleSignIn;

  AuthNotifier({
    AuthApiClient? api,
    SessionStore? sessionStore,
    GoogleSignIn? googleSignIn,
  })  : _api = api ?? AuthApiClient(),
        _sessionStore = sessionStore ?? SessionStore(),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: AppConfig.apiBaseUrl.isEmpty
                  ? null
                  : '44456740583-lrkkqm7k3ao2l76ofe6us8oq2vnhp4mp.apps.googleusercontent.com',
              scopes: const ['email', 'profile'],
            ),
        super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = await _sessionStore.getToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.signedOut);
      return;
    }
    try {
      final user = await _api.getCurrentUser(token);
      state = state.copyWith(status: AuthStatus.signedIn, user: user);
    } catch (_) {
      await _sessionStore.clearSession();
      state = state.copyWith(status: AuthStatus.signedOut);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('Google sign-in did not return a token');
      }
      final result = await _api.signInWithGoogle(idToken);
      await _sessionStore.saveSession(
        token: result.token,
        userId: result.user.id,
        email: result.user.email,
      );
      state = state.copyWith(
        status: AuthStatus.signedIn,
        user: result.user,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> requestEmailOtp(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.sendOtp(email);
      state = state.copyWith(
        status: AuthStatus.awaitingOtp,
        pendingEmail: email,
        isLoading: false,
        otpSentAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resendEmailOtp() async {
    final email = state.pendingEmail;
    if (email == null || !state.canResendOtp) return;
    await requestEmailOtp(email);
  }

  Future<bool> verifyEmailOtp(String code) async {
    final email = state.pendingEmail;
    if (email == null) {
      state = state.copyWith(error: 'No email pending verification');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.verifyOtp(email, code);
      await _sessionStore.saveSession(
        token: result.token,
        userId: result.user.id,
        email: result.user.email,
      );
      state = state.copyWith(
        status: AuthStatus.signedIn,
        user: result.user,
        isLoading: false,
        pendingEmail: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void cancelOtpFlow() {
    state = state.copyWith(status: AuthStatus.signedOut, pendingEmail: null, error: null);
  }

  Future<bool> updateProfile({String? name, String? displayName, Map<String, dynamic>? preferences}) async {
    final token = await _sessionStore.getToken();
    if (token == null) return false;
    try {
      final user = await _api.updateProfile(
        token,
        name: name,
        displayName: displayName,
        preferences: preferences,
      );
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    final token = await _sessionStore.getToken();
    if (token == null) return false;
    try {
      await _api.deleteAccount(token);
      await signOut();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _sessionStore.clearSession();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    state = const AuthState(status: AuthStatus.signedOut);
  }

  Future<String?> currentToken() => _sessionStore.getToken();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
