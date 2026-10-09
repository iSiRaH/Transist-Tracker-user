import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_jwt_token';
  static const _userKey = 'auth_user_json';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveUserJson(String jsonStr) async {
    await _storage.write(key: _userKey, value: jsonStr);
  }

  Future<String?> readUserJson() async {
    return _storage.read(key: _userKey);
  }

  Future<void> clearUserJson() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
