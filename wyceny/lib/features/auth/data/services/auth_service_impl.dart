import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:wyceny/features/auth/data/services/token_storage.dart';

import 'package:wyceny/features/auth/domain/repositories/auth_repository.dart';
import 'package:wyceny/features/auth/domain/services/auth_service.dart';

class AuthServiceImpl implements AuthService {
  final AuthRepository _repo;
  final TokenStorage _secureStorage;

  @override
  String get user => _displayUserName;
  @override
  String get firstName => _firstName;
  @override
  String get lastName => _lastName;
  @override
  String get branch => _branch;
  @override
  String get skyLogicNumber => _slNumber;

  String _displayUserName = '';
  String _firstName = '';
  String _lastName = '';
  String _branch = '';
  String _slNumber = '';


  AuthServiceImpl({
    required AuthRepository repository,
    required TokenStorage storage,
  })  : _repo = repository,
        _secureStorage = storage;

  Timer? _refreshTimer;
  bool _isRefreshing = false;
  DateTime? _lastRefreshAttemptAt;
  bool _lastRefreshOk = true;
  static const Duration _refreshThrottle = Duration(seconds: 30);

  @override
  Future<bool> init() async {
    final access = await _secureStorage.read(kAccessTokenKey);
    final refresh = await _secureStorage.read(kRefreshTokenKey);
    if (access != null && refresh != null) {
      _scheduleRefreshFromAccess(access);
      _firstName = await _secureStorage.read('firstName') ?? 'Jan';
      _lastName = await _secureStorage.read('lastName') ?? 'Nowak';
      _slNumber = await _secureStorage.read('skyLogicNumber') ?? '007';
      _branch = await _secureStorage.read('branch') ?? 'CD Projekt';

      return true;
    }
    return false;
  }

  @override
  Future<bool> login(String username, String password) async {
    final res = await _repo.login(username: username, password: password);
    final access = res['access_token'] as String?;
    final refresh = res['refresh_token'] as String?;
    final du = res['user']?['username'] as String?;
    _displayUserName = du ?? username;
    _firstName = res['firstName'] ?? 'Jan';
    _lastName = res['lastName'] ?? 'Nowak';
    _slNumber = res['skyLogicNumber'] ?? '007';
    _branch = res['branch'] ?? 'Kopalnia Bogdanka';

    if (access == null || refresh == null) {
      return false;
    }

    await _secureStorage.write(kAccessTokenKey, access);
    await _secureStorage.write(kRefreshTokenKey, refresh);
    await _secureStorage.write('firstName', _firstName);
    await _secureStorage.write('lastName', _lastName);
    await _secureStorage.write('skyLogicNumber', _slNumber);
    await _secureStorage.write('branch', _branch);
    _scheduleRefreshFromAccess(access);
    return true;
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(kAccessTokenKey);
    await _secureStorage.delete(kRefreshTokenKey);
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<bool> refreshAccessToken() async {
    if (_isRefreshing) return false;
    if (_lastRefreshAttemptAt != null &&
        DateTime.now().difference(_lastRefreshAttemptAt!) < _refreshThrottle &&
        _lastRefreshOk) {
      // throttle
      return false;
    }

    _isRefreshing = true;
    _lastRefreshAttemptAt = DateTime.now();

    try {
      final refresh = await _secureStorage.read(kRefreshTokenKey);
      if (refresh == null) {
        _isRefreshing = false;
        _lastRefreshOk = false;
        await logout(); // Automatyczne wylogowanie przy braku refresh tokena
        return false;
      }

      final res = await _repo.refreshAccessToken(refreshToken: refresh);
      final newAccess = res['access_token'] as String?;
      final newRefresh = res['refresh_token'] as String? ?? refresh;

      if (newAccess == null) {
        _isRefreshing = false;
        _lastRefreshOk = false;
        await logout(); // Automatyczne wylogowanie przy braku nowego access tokena
        return false;
      }

      await _secureStorage.write(kAccessTokenKey, newAccess);
      await _secureStorage.write(kRefreshTokenKey, newRefresh);

      _scheduleRefreshFromAccess(newAccess);
      _isRefreshing = false;
      _lastRefreshOk = true;
      return true;
    } on DioException catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('refreshAccessToken DioException: $e\n$st');
      }
      _isRefreshing = false;
      _lastRefreshOk = false;
      if (e.response?.statusCode == 401) {
        await logout(); // Automatyczne wylogowanie po 401
      }
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('refreshAccessToken error: $e\n$st');
      }
      _isRefreshing = false;
      _lastRefreshOk = false;
      await logout(); // Automatyczne wylogowanie przy innych błędach
      return false;
    }
  }

  @override
  Future<bool> recoverRequest(String username) async {
    await _repo.recoverRequest(username: username);
    return true;
  }

  @override
  Future<bool> recoverSetPassword(
      String username,
      String code,
      String password,
      ) async {
    await _repo.recoverSetPassword(
      username: username,
      code: code,
      password: password,
    );
    return true;
  }

  // ===== Helpers =====

  void _scheduleRefreshFromAccess(String access) {
    _refreshTimer?.cancel();
    final exp = _jwtExp(access);
    if (exp == null) return;

    final now = DateTime.now().toUtc();
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    // odśwież 60s przed wygaśnięciem (min. 10s)
    var delta = expiry.difference(now) - const Duration(seconds: 60);
    if (delta.isNegative) delta = const Duration(seconds: 10);

    _refreshTimer = Timer(delta, () {
      refreshAccessToken();
    });
  }

  int? _jwtExp(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final map = json.decode(payload) as Map<String, dynamic>;
      var exp = map['exp'];
      int? v;
      if (exp is int) v = exp;
      if (exp is String) v = int.tryParse(exp);
      if (v == null) return null;
      // normalizacja ms -> s
      if (v > 100000000000) v = v ~/ 1000;
      return v;
    } catch (_) {
      return null;
    }
  }

  Future<String?> get accessToken async => _secureStorage.read(kAccessTokenKey);

  @override
  String getDisplayName() {
    return firstName+' '+lastName+" ("+skyLogicNumber+", "+branch+")";
  }
}
