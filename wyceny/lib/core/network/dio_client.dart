import 'package:dio/dio.dart';
import 'package:wyceny/app/env/app_environment.dart';
import 'package:wyceny/features/auth/data/services/token_storage.dart';
import 'package:wyceny/features/auth/network/interceptors/auth_header_interceptor.dart';
import 'package:wyceny/features/auth/network/interceptors/refresh_token_interceptor.dart';
import 'package:wyceny/features/logs/network/logging_interceptor.dart';

class DioClient {
  DioClient(
      EnvConfig config,
      TokenStorage storage, {
        required RefreshFn refreshFn,
        required Future<void> Function() onRefreshFailed,
      }) : _dio = Dio(BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
    // validateStatus: (code) => code != null && code >= 200 && code < 400,
  )) {
    // Kolejność ma znaczenie:
    // 1) Auth nagłówek (omija /auth i /refresh)
    // 2) Refresh (przechwytuje 401 i ponawia)
    // 3) Logging (na końcu, by widzieć retry)
    _dio.interceptors.addAll([
      AuthHeaderInterceptor(storage),
      RefreshTokenInterceptor(_dio, storage, refreshFn, onRefreshFailed),
    ]);

    if (config.enableHttpLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  final Dio _dio;

  Dio get instance => _dio;
}
