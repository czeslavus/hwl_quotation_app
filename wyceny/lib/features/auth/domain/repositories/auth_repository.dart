import 'package:dio/dio.dart';

abstract class AuthRepository {
  /// Zwraca mapę z tokenami (np. access/refresh) oraz innymi polami zwracanymi przez backend.
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    CancelToken? cancelToken,
  });

  /// Odświeża access token przy użyciu refresh tokena.
  Future<Map<String, dynamic>> refreshAccessToken({
    required String refreshToken,
    CancelToken? cancelToken,
  });

  /// Rozpoczyna procedurę odzyskiwania hasła.
  Future<void> recoverRequest({
    required String username,
    CancelToken? cancelToken,
  });

  /// Ustawia nowe hasło.
  Future<void> recoverSetPassword({
    required String username,
    required String code,
    required String password,
    CancelToken? cancelToken,
  });
}
