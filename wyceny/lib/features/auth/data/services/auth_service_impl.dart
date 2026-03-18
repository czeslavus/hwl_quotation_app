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
  }) : _repo = repository,
       _secureStorage = storage;

  Timer? _refreshTimer;
  Completer<bool>? _refreshCompleter;
  DateTime? _lastRefreshAttemptAt;
  bool _lastRefreshOk = true;
  static const Duration _refreshThrottle = Duration(seconds: 30);
  static const Duration _refreshSkew = Duration(seconds: 60);

  @override
  Future<bool> init() async {
    final access = await _secureStorage.read(kAccessTokenKey);
    final refresh = await _secureStorage.read(kRefreshTokenKey);
    if (access == null || refresh == null) {
      return false;
    }

    _firstName = await _secureStorage.read('firstName') ?? 'Jan';
    _lastName = await _secureStorage.read('lastName') ?? 'Nowak';
    _slNumber = await _secureStorage.read('skyLogicNumber') ?? '007';
    _branch = await _secureStorage.read('branch') ?? 'CD Projekt';

    if (_shouldRefreshImmediately(access)) {
      final refreshed = await refreshAccessToken();
      if (!refreshed) {
        return false;
      }

      final currentAccess = await _secureStorage.read(kAccessTokenKey);
      if (currentAccess == null || currentAccess.isEmpty) {
        return false;
      }
      _scheduleRefreshFromAccess(currentAccess);
      return true;
    }

    _scheduleRefreshFromAccess(access);
    return true;
  }

  @override
  Future<bool> login(String username, String password) async {
    final res = await _repo.login(username: username, password: password);
    final access = _readString(res, 'accessToken', fallbackKey: 'access_token');
    final refresh = _readString(
      res,
      'refreshToken',
      fallbackKey: 'refresh_token',
    );
    final du = _readNestedString(res, ['user', 'username']);
    _displayUserName = du ?? username;
    _firstName = _readString(res, 'firstName') ?? 'Jan';
    _lastName = _readString(res, 'lastName') ?? 'Nowak';
    _slNumber = _readString(res, 'skyLogicNumber') ?? '007';
    _branch = _readString(res, 'branch') ?? 'Kopalnia Bogdanka';

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
    _refreshCompleter = null;
    _lastRefreshAttemptAt = null;
    _lastRefreshOk = false;
  }

  @override
  Future<bool> refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final access = await _secureStorage.read(kAccessTokenKey);
    final refresh = await _secureStorage.read(kRefreshTokenKey);
    if (refresh == null ||
        refresh.isEmpty ||
        access == null ||
        access.isEmpty) {
      _lastRefreshOk = false;
      await logout();
      return false;
    }

    if (_lastRefreshAttemptAt != null &&
        DateTime.now().difference(_lastRefreshAttemptAt!) < _refreshThrottle &&
        _lastRefreshOk &&
        !_shouldRefreshImmediately(access)) {
      return true;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;
    _lastRefreshAttemptAt = DateTime.now();

    try {
      final res = await _repo.refreshAccessToken(
        accessToken: access,
        refreshToken: refresh,
      );
      final newAccess = _readString(
        res,
        'accessToken',
        fallbackKey: 'access_token',
      );
      final newRefresh =
          _readString(res, 'refreshToken', fallbackKey: 'refresh_token') ??
          refresh;

      if (newAccess == null) {
        _lastRefreshOk = false;
        await logout();
        completer.complete(false);
        return false;
      }

      await _secureStorage.write(kAccessTokenKey, newAccess);
      await _secureStorage.write(kRefreshTokenKey, newRefresh);

      _scheduleRefreshFromAccess(newAccess);
      _lastRefreshOk = true;
      completer.complete(true);
      return true;
    } on DioException catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('refreshAccessToken DioException: $e\n$st');
      }
      _lastRefreshOk = false;
      if (e.response?.statusCode == 401) {
        await logout();
      }
      if (!completer.isCompleted) completer.complete(false);
      return false;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('refreshAccessToken error: $e\n$st');
      }
      _lastRefreshOk = false;
      await logout();
      if (!completer.isCompleted) completer.complete(false);
      return false;
    } finally {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      if (identical(_refreshCompleter, completer)) {
        _refreshCompleter = null;
      }
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
    final delta = expiry.difference(now) - _refreshSkew;

    if (delta <= Duration.zero) {
      unawaited(refreshAccessToken());
      return;
    }

    _refreshTimer = Timer(delta, refreshAccessToken);
  }

  int? _jwtExp(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      var payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
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

  String? _readString(
    Map<String, dynamic> source,
    String key, {
    String? fallbackKey,
  }) {
    final value =
        source[key] ?? (fallbackKey == null ? null : source[fallbackKey]);
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  String? _readNestedString(Map<String, dynamic> source, List<String> path) {
    dynamic current = source;
    for (final segment in path) {
      if (current is! Map) return null;
      current = current[segment];
    }
    if (current is String) return current;
    return null;
  }

  Future<String?> get accessToken async => _secureStorage.read(kAccessTokenKey);

  @override
  String getDisplayName() {
    return '$firstName $lastName ($skyLogicNumber, $branch)';
  }

  bool _shouldRefreshImmediately(String access) {
    final exp = _jwtExp(access);
    if (exp == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    final now = DateTime.now().toUtc();
    return !expiry.isAfter(now.add(_refreshSkew));
  }
}
