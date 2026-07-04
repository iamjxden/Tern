import '../storage/secure_store.dart';

/// Persists the JWT session token on-device using the secure keystore
/// so the person stays signed in across app restarts, and the same
/// token is what proves to the backend who they are when restoring
/// chats, projects and memory after a reinstall + re-login.
class SessionStore {
  static const _tokenKey = 'tern_session_token';
  static const _userIdKey = 'tern_session_user_id';
  static const _emailKey = 'tern_session_email';

  final SecureStore _secureStore;

  SessionStore({SecureStore? secureStore}) : _secureStore = secureStore ?? SecureStore();

  Future<void> saveSession({
    required String token,
    required String userId,
    required String email,
  }) async {
    await _secureStore.write(_tokenKey, token);
    await _secureStore.write(_userIdKey, userId);
    await _secureStore.write(_emailKey, email);
  }

  Future<String?> getToken() => _secureStore.read(_tokenKey);
  Future<String?> getUserId() => _secureStore.read(_userIdKey);
  Future<String?> getEmail() => _secureStore.read(_emailKey);

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _secureStore.delete(_tokenKey);
    await _secureStore.delete(_userIdKey);
    await _secureStore.delete(_emailKey);
  }
}
