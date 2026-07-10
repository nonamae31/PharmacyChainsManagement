import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> readRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
