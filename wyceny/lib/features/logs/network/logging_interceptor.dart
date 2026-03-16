import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:wyceny/features/logs/data/service/logger_service.dart';

class LoggingInterceptor extends Interceptor {
  final _logger = GetIt.I<LogService>().logger; // singleton z DI

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
    final request = err.requestOptions;
    _logger.e(
      '[HTTP ×] ${err.response?.statusCode} ${request.uri}',
      error: err,
      stackTrace: err.stackTrace,
    );
    _logger.e('[HTTP ×] Request headers: ${request.headers}');
    if (request.queryParameters.isNotEmpty) {
      _logger.e('[HTTP ×] Query: ${request.queryParameters}');
    }
    if (request.data != null) {
      _logger.e('[HTTP ×] Body: ${_stringifyForLog(request.data)}');
    }
    if (err.response?.data != null) {
      _logger.e(
        '[HTTP ×] Response body: ${_stringifyForLog(err.response?.data)}',
      );
    }
    _logger.e('[HTTP ×] cURL: ${_buildCurl(request)}');
    handler.next(err);
  }

  String _truncate(String s, {int max = 800}) =>
      s.length <= max ? s : '${s.substring(0, max)}…';

  String _buildCurl(RequestOptions request) {
    final parts = <String>[
      'curl',
      '-X',
      request.method.toUpperCase(),
      '\'${request.uri}\'',
    ];

    request.headers.forEach((key, value) {
      parts.add('-H');
      parts.add('\'$key: ${_escapeSingleQuotes(value.toString())}\'');
    });

    if (request.data != null) {
      parts.add('--data-raw');
      parts.add('\'${_escapeSingleQuotes(_stringifyForLog(request.data))}\'');
    }

    return parts.join(' ');
  }

  String _stringifyForLog(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  String _escapeSingleQuotes(String value) {
    return value.replaceAll("'", "'\"'\"'");
  }
}
