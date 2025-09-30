import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wyceny/features/auth/data/services/token_storage.dart';

TokenStorage createPlatformTokenStorage() => SecureTokenStorage();

class SecureTokenStorage implements TokenStorage {
  static const _readTimeout = Duration(seconds: 2);

  final FlutterSecureStorage _inner = const FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) async {
    try {
      await _inner.write(key: key, value: value);
    } on PlatformException catch (e) {
      // można zalogować, ale nie crashować
      print('SecureStorage write error: $e');
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _inner.read(key: key).timeout(_readTimeout);
    } on TimeoutException {
      print('SecureStorage read timeout');
      return null;
    } on PlatformException catch (e) {
      print('SecureStorage read error: $e');
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _inner.delete(key: key);
    } on PlatformException catch (e) {
      print('SecureStorage delete error: $e');
    }
  }
}
