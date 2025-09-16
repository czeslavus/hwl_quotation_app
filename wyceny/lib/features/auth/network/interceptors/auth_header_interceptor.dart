import 'package:dio/dio.dart';
import 'package:wyceny/features/auth/data/services/token_storage.dart';
import '../auth_rules.dart';

class AuthHeaderInterceptor extends Interceptor {
  AuthHeaderInterceptor(this._storage);

  final TokenStorage _storage;

  Future<String?> _getAccessToken() async {
    return await _storage.read(kAccessTokenKey);
  }
  Future<String?> _getDeviceId()   async => _storage.read(kDeviceIdKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    // Ustaw nagłówek ngrok-skip-browser-warning zawsze,
    // @todo usunąć w kodzie produkcyjnym
    options.headers['ngrok-skip-browser-warning'] = '1';

    // Device Id zawsze – także dla ścieżek wykluczonych z auth
    final did = await _getDeviceId();
    if (did != null && did.isNotEmpty) {
      // @todo - dodać w kodzie na serwerze oryginalnym
//      options.headers['X-Device-Id'] = did;
    }

    if (AuthRules.isAuthExempt(options)) return handler.next(options);

    final token = await _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
