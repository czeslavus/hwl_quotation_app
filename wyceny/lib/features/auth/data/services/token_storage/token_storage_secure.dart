import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wyceny/features/auth/data/services/token_storage.dart';


TokenStorage createPlatformTokenStorage() => SecureTokenStorage();


class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _inner = const FlutterSecureStorage();


  @override
  Future<void> write(String key, String value) => _inner.write(key: key, value: value);


  @override
  Future<String?> read(String key) => _inner.read(key: key);


  @override
  Future<void> delete(String key) => _inner.delete(key: key);
}