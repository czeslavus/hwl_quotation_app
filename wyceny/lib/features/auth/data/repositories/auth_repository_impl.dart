import 'package:dio/dio.dart';

import 'package:wyceny/features/auth/domain/repositories/auth_repository.dart';

/// Implementacja repozytorium auth. Tylko wywołania HTTP.
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;

  AuthRepositoryImpl(this._dio);

  static const String _loginPath = '/auth/login';
  static const String _refreshPath = '/auth/refresh';
  static const String _recoverRequestPath = '/auth/recover/request';
  static const String _recoverSetPasswordPath = '/auth/recover/set';

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    CancelToken? cancelToken,
  }) async {
    final resp = await _dio.post(
      _loginPath,
      data: {
        'username': username,
        'password': password,
      },
      cancelToken: cancelToken,
    );
    if (resp.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw DioException(
      requestOptions: resp.requestOptions,
      response: resp,
      error: 'Unexpected login response shape',
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<Map<String, dynamic>> refreshAccessToken({
    required String refreshToken,
    CancelToken? cancelToken,
  }) async {
    final resp = await _dio.post(
      _refreshPath,
      data: {
        'refresh_token': refreshToken,
      },
      cancelToken: cancelToken,
    );
    if (resp.data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(resp.data as Map);
    }
    throw DioException(
      requestOptions: resp.requestOptions,
      response: resp,
      error: 'Unexpected refresh response shape',
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<void> recoverRequest({
    required String username,
    CancelToken? cancelToken,
  }) async {
    await _dio.post(
      _recoverRequestPath,
      data: {'username': username},
      cancelToken: cancelToken,
    );
  }

  @override
  Future<void> recoverSetPassword({
    required String username,
    required String code,
    required String password,
    CancelToken? cancelToken,
  }) async {
    await _dio.post(
      _recoverSetPasswordPath,
      data: {
        'username': username,
        'code': code,
        'password': password,
      },
      cancelToken: cancelToken,
    );
  }
}
