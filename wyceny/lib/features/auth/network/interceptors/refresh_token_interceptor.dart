import 'package:dio/dio.dart';
import 'package:wyceny/features/auth/data/services/token_storage.dart';
import 'package:wyceny/features/auth/network/auth_rules.dart';

typedef RefreshFn = Future<String?> Function(String? refreshToken);

class RefreshTokenInterceptor extends Interceptor {
  RefreshTokenInterceptor(
      this._dio,
      this._storage,
      this._refreshFn,
      this._onRefreshFailed,

      );

  final Dio _dio;
  final TokenStorage _storage;
  final RefreshFn _refreshFn;
  final Future<void> Function() _onRefreshFailed;

  Future<String?> _getRefreshToken() async {
    return await _storage.read(kRefreshTokenKey);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Tylko 401 i nie dla endpointów auth/refresh
    if (err.response?.statusCode != 401 || AuthRules.isAuthExempt(err.requestOptions)) {
      return handler.next(err);
    }

    // Spróbuj odświeżyć
    final refresh = await _getRefreshToken();
    final newAccess = await _refreshFn(refresh);

    if (newAccess == null) {
      // Jeśli odświeżenie tokenu się nie powiodło, wywołaj funkcję obsługującą błąd
      await _onRefreshFailed();
      return handler.next(err); // Przekaż błąd dalej, aby oryginalne żądanie zakończyło się niepowodzeniem
    }

    await _storage.write(kAccessTokenKey, newAccess);

    // powtórz oryginalne żądanie z nowym tokenem

    final orig = err.requestOptions;
    final response = await _dio.request<dynamic>(
      orig.path,
      data: orig.data,
      queryParameters: orig.queryParameters,
      options: Options(
        method: orig.method,
        headers: Map<String, dynamic>.from(orig.headers)..remove('Authorization'),
        contentType: orig.contentType,
        responseType: orig.responseType,
        sendTimeout: orig.sendTimeout,
        receiveTimeout: orig.receiveTimeout,
        followRedirects: orig.followRedirects,
        validateStatus: orig.validateStatus,
        receiveDataWhenStatusError: orig.receiveDataWhenStatusError,
        extra: orig.extra,
      ),
      cancelToken: orig.cancelToken,
      onSendProgress: orig.onSendProgress,
      onReceiveProgress: orig.onReceiveProgress,
    );
    return handler.resolve(response);
  }
}
