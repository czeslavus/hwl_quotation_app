import 'package:flutter/material.dart';

import 'package:wyceny/features/auth/domain/services/auth_service.dart';
import 'package:wyceny/features/dictionaries/domain/dictionaries_repository.dart';

class AuthState extends ChangeNotifier {
  final AuthService _service;
  final DictionariesRepository _dictionaries;

  String get user => _service.user;
  String get forename => _service.firstName;
  String get surname => _service.lastName;
  String get contractorName => _service.branch;
  String get skyLogicNumber => _service.skyLogicNumber;

  AuthState({
    required AuthService service,
    required DictionariesRepository dictionaries,
  }) : _service = service,
       _dictionaries = dictionaries;

  bool _loggedIn = false;
  bool _initialized = false;

  bool get isLoggedIn => _loggedIn;
  bool get isInitialized => _initialized;

  /// Wywołaj raz na starcie (Splash)
  Future<void> init() async {
    try {
      final ok = await _service.init();
      if (!ok) {
        _loggedIn = false;
        return;
      }

      try {
        await _dictionaries.preload();
        _loggedIn = true;
      } catch (_) {
        await _service.logout();
        _loggedIn = false;
      }
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String user, String pass) async {
    var ok = await _service.login(user, pass);
    if (!ok) {
      _loggedIn = false;
      notifyListeners();
      return false;
    }

    try {
      await _dictionaries.preload();
      _loggedIn = true;
      return true;
    } catch (e) {
      await _service.logout();
      _loggedIn = false;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _loggedIn = false;
    notifyListeners();
  }

  Future<bool> refreshAccessToken() => _service.refreshAccessToken();
  Future<bool> recoverRequest(String username) =>
      _service.recoverRequest(username);
  Future<bool> recoverSetPassword(
    String username,
    String code,
    String password,
  ) => _service.recoverSetPassword(username, code, password);
}

class AuthScope extends InheritedNotifier<AuthState> {
  const AuthScope({super.key, required super.notifier, required super.child});

  static AuthState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope not found in context');
    return scope!.notifier!;
  }
}
