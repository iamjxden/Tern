import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveApiKey(String provider, String key) =>
      _storage.write(key: 'api_key_$provider', value: key);

  Future<String?> getApiKey(String provider) =>
      _storage.read(key: 'api_key_$provider');

  Future<void> deleteApiKey(String provider) =>
      _storage.delete(key: 'api_key_$provider');

  Future<bool> hasApiKey(String provider) async {
    final key = await _storage.read(key: 'api_key_$provider');
    return key != null && key.isNotEmpty;
  }

  Future<List<String>> getConfiguredProviders() async {
    final providers = ['openai', 'anthropic', 'openrouter'];
    final configured = <String>[];
    for (final p in providers) {
      if (await hasApiKey(p)) configured.add(p);
    }
    return configured;
  }

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> clearAll() => _storage.deleteAll();
}
