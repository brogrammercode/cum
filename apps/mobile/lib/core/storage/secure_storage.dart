import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const accessTokenKey = 'cruz_access_token';
  static const refreshTokenKey = 'cruz_refresh_token';

  Future<void> saveTokens({required String access, required String refresh}) {
    return Future.wait([
      _storage.write(key: accessTokenKey, value: access),
      _storage.write(key: refreshTokenKey, value: refresh),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: refreshTokenKey);

  Future<void> clear() => Future.wait([
    _storage.delete(key: accessTokenKey),
    _storage.delete(key: refreshTokenKey),
  ]);
}
