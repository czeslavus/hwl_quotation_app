import 'package:wyceny/app/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

enum LoginError {
  invalidCredentials,
  network,
  unknown,
}

class LoginViewModel extends ChangeNotifier {
  final AuthState _auth;
  LoginViewModel(this._auth);

  bool _isLoading = false;
  LoginError? _error;
  bool _obscurePassword = true;
  CancelToken? _cancelToken;

  bool get isLoading => _isLoading;
  LoginError? get error => _error;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    _cancelToken = CancelToken();

    try {
      final ok = await _auth.login(username, password);
      if (!ok) {
        _error = LoginError.invalidCredentials;
      }
      return ok;
    } catch (e) {
      _error = _mapError(e);
      return false;
    } finally {
      _setLoading(false);
      _cancelToken = null;
    }
  }

  Future<bool> recover({required String username}) async {
    _setLoading(true);
    _error = null;
    _cancelToken = CancelToken();
    try {
      await _auth.recoverRequest(username);
      return true;
    } catch (e) {
      _error = _mapError(e);
      return false;
    } finally {
      _setLoading(false);
      _cancelToken = null;
    }
  }

  void cancel() => _cancelToken?.cancel('Canceled by user');

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  LoginError _mapError(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        return LoginError.invalidCredentials;
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return LoginError.network;
        case DioExceptionType.badResponse:
        case DioExceptionType.badCertificate:
        case DioExceptionType.cancel:
        case DioExceptionType.unknown:
          return LoginError.network;
      }
    }
    return LoginError.network;
  }
}
