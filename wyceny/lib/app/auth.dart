import 'package:flutter/material.dart';

import 'package:wyceny/features/auth/domain/services/auth_service.dart';


class AuthState extends ChangeNotifier {
  final AuthService _service;

  String get user => _service.user;

  AuthState({
    required AuthService service,
  })  : _service = service;

  bool _loggedIn = false;
  bool _initialized = false;


  bool get isLoggedIn => _loggedIn;
  bool get isInitialized => _initialized;

  /// Wywołaj raz na starcie (Splash)
  Future<void> init() async {
    try {
      final ok = await _service.init();
      _loggedIn = ok;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }


  Future<bool> login(String user, String pass) async {
    print('In login');
    final ok = await _service.login(user, pass);
    _loggedIn = ok;
    notifyListeners();
    return ok;
  }


  Future<void> logout() async {
    await _service.logout();
    _loggedIn = false;
    notifyListeners();
  }


  Future<bool> refreshAccessToken() => _service.refreshAccessToken();
  Future<bool> recoverRequest(String username) => _service.recoverRequest(username);
  Future<bool> recoverSetPassword(String username, String code, String password) =>
      _service.recoverSetPassword(username, code, password);
}


class AuthScope extends InheritedNotifier<AuthState> {
  const AuthScope({super.key, required super.notifier, required super.child});


  static AuthState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in context');
    return scope!.notifier!;
  }
}