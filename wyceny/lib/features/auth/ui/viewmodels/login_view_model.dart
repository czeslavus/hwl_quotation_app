import 'package:e_kierowca_app/app/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// ViewModel odpowiedzialny za logikę ekranu logowania.
class LoginViewModel extends ChangeNotifier {
  final AuthState _auth;

  LoginViewModel(this._auth);

  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  CancelToken? _cancelToken;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get obscurePassword => _obscurePassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Próba logowania. Zwraca true przy powodzeniu.
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
        _error = 'Nieprawidłowe dane logowania.';
      }
      return ok;
    } catch (e) {
      _error = _humanizeError(e);
      return false;
    } finally {
      _setLoading(false);
      _cancelToken = null;
    }
  }

  /// Opcjonalnie: odzyskiwanie hasła
  Future<bool> recover({required String username}) async {
    _setLoading(true);
    _error = null;
    _cancelToken = CancelToken();
    try {
      await _auth.recoverRequest(username);
      return true;
    } catch (e) {
      _error = _humanizeError(e);
      return false;
    } finally {
      _setLoading(false);
      _cancelToken = null;
    }
  }

  void cancel() {
    _cancelToken?.cancel('Canceled by user');
  }

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

  String _humanizeError(Object e) {
    // Tu możesz rozwinąć mapowanie wyjątków na czytelne komunikaty
    return 'Wystąpił błąd podczas logowania.';
  }
}
