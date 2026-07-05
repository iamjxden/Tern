import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AuthApiException implements Exception {
  final String message;
  AuthApiException(this.message);
  @override
  String toString() => message;
}

class TernUser {
  final String id;
  final String email;
  final String? name;
  final String? displayName;
  final String? avatar;
  final Map<String, dynamic>? preferences;

  const TernUser({
    required this.id,
    required this.email,
    this.name,
    this.displayName,
    this.avatar,
    this.preferences,
  });

  factory TernUser.fromJson(Map<String, dynamic> json) => TernUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
        displayName: json['displayName'] as String?,
        avatar: json['avatarUrl'] as String?,
        preferences: json['preferences'] == null
            ? null
            : Map<String, dynamic>.from(json['preferences'] as Map),
      );
}

class AuthResult {
  final String token;
  final TernUser user;
  const AuthResult({required this.token, required this.user});
}

class AuthApiClient {
  final http.Client _http;
  final String baseUrl;

  AuthApiClient({http.Client? client, String? baseUrl})
      : _http = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  T _unwrap<T>(http.Response res, T Function(Map<String, dynamic>) onData) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
      return onData(body['data'] as Map<String, dynamic>);
    }
    final error = body['error'];
    throw AuthApiException(error is String ? error : 'Request failed');
  }

  Future<AuthResult> signInWithGoogle(String idToken) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.authGoogleEndpoint}'),
      headers: _jsonHeaders,
      body: jsonEncode({'idToken': idToken}),
    );
    return _unwrap(res, (data) => AuthResult(
          token: data['token'] as String,
          user: TernUser.fromJson(data['user'] as Map<String, dynamic>),
        ));
  }

  Future<void> sendOtp(String email) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.authSendOtpEndpoint}'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode < 200 || res.statusCode >= 300 || body['success'] != true) {
      final error = body['error'];
      throw AuthApiException(error is String ? error : 'Failed to send code');
    }
  }

  Future<AuthResult> verifyOtp(String email, String code) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.authVerifyOtpEndpoint}'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _unwrap(res, (data) => AuthResult(
          token: data['token'] as String,
          user: TernUser.fromJson(data['user'] as Map<String, dynamic>),
        ));
  }

  Future<TernUser> getCurrentUser(String token) async {
    final res = await _http.get(
      Uri.parse('$baseUrl${AppConfig.userMeEndpoint}'),
      headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
    );
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
      return TernUser.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw AuthApiException(body['error'] as String? ?? 'Failed to load profile');
  }

  Future<TernUser> updateProfile(
    String token, {
    String? name,
    String? displayName,
    Map<String, dynamic>? preferences,
  }) async {
    final res = await _http.put(
      Uri.parse('$baseUrl${AppConfig.userMeEndpoint}'),
      headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        if (name != null) 'name': name,
        if (displayName != null) 'displayName': displayName,
        if (preferences != null) 'preferences': preferences,
      }),
    );
    return _unwrap(res, (data) => TernUser.fromJson(data));
  }

  Future<void> deleteAccount(String token) async {
    final res = await _http.delete(
      Uri.parse('$baseUrl${AppConfig.userMeEndpoint}'),
      headers: {..._jsonHeaders, 'Authorization': 'Bearer $token'},
    );
    _unwrap(res, (data) => data);
  }
}
