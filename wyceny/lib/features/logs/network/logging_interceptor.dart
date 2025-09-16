import 'package:dio/dio.dart';
import 'package:e_kierowca_app/app/di/locator.dart';
import 'package:e_kierowca_app/features/logs/data/service/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  final _logger = getIt<LogService>().logger; // singleton z DI

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('[HTTP →] ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      _logger.d('Headers: ${_truncate(options.headers.toString())}');
    }
    if (options.data != null) {
      _logger.d('Body: ${_truncate(options.data.toString())}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('[HTTP ←] ${response.statusCode} ${response.requestOptions.uri}');
    _logger.d('Resp: ${_truncate(response.data.toString())}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '[HTTP ×] ${err.response?.statusCode} ${err.requestOptions.uri}',
      error: err,
      stackTrace: err.stackTrace,
    );
    handler.next(err);
  }

  String _truncate(String s, {int max = 800}) =>
      s.length <= max ? s : '${s.substring(0, max)}…';
}
