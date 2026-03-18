import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:wyceny/app/di/locator.dart' show getIt;
import 'package:wyceny/features/logs/data/service/logger_service.dart';
import 'package:wyceny/features/route_by_postcode/domain/route_models.dart';
import 'package:wyceny/features/route_by_postcode/domain/route_repository.dart';

class RouteByPostcodeViewModel extends ChangeNotifier {
  static final Map<String, RegExp> _postcodePatterns = {
    'AT': RegExp(r'^\d{4}$'),
    'BE': RegExp(r'^\d{4}$'),
    'CH': RegExp(r'^\d{4}$'),
    'CZ': RegExp(r'^\d{3}\s?\d{2}$'),
    'DE': RegExp(r'^\d{5}$'),
    'DK': RegExp(r'^\d{4}$'),
    'EE': RegExp(r'^\d{5}$'),
    'ES': RegExp(r'^\d{5}$'),
    'FI': RegExp(r'^\d{5}$'),
    'FR': RegExp(r'^\d{5}$'),
    'GB': RegExp(
      r'^(GIR 0AA|[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2})$',
      caseSensitive: false,
    ),
    'HU': RegExp(r'^\d{4}$'),
    'IE': RegExp(r'^[A-Z0-9]{3}\s?[A-Z0-9]{4}$', caseSensitive: false),
    'IT': RegExp(r'^\d{5}$'),
    'LT': RegExp(r'^(LT-)?\d{5}$', caseSensitive: false),
    'LU': RegExp(r'^\d{4}$'),
    'LV': RegExp(r'^(LV-)?\d{4}$', caseSensitive: false),
    'NL': RegExp(r'^\d{4}\s?[A-Z]{2}$', caseSensitive: false),
    'NO': RegExp(r'^\d{4}$'),
    'PL': RegExp(r'^\d{2}-\d{3}$'),
    'PT': RegExp(r'^\d{4}-\d{3}$'),
    'RO': RegExp(r'^\d{6}$'),
    'SE': RegExp(r'^\d{3}\s?\d{2}$'),
    'SI': RegExp(r'^\d{4}$'),
    'SK': RegExp(r'^\d{3}\s?\d{2}$'),
  };

  final RouteRepository repo;
  final _logger = getIt<LogService>().logger;

  RouteByPostcodeViewModel({
    required this.repo,
    this.defaultCountryCode = 'PL',
  });

  final String defaultCountryCode;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  RouteResult? _route;
  RouteResult? get route => _route;

  LatLng? _start;
  LatLng? _end;

  LatLng? get start => _start;
  LatLng? get end => _end;

  // Debounce (żeby nie wołać API na każdy znak)
  Timer? _debounce;
  String? _lastKey;

  void scheduleBuildRoute({
    required String originZip,
    required String destinationZip,
    String? originCountryCode,
    String? destinationCountryCode,
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    final oz = originZip.trim();
    final dz = destinationZip.trim();
    final originCountry = _normalizeCountryCode(originCountryCode);
    final destinationCountry = _normalizeCountryCode(destinationCountryCode);

    if (oz.isEmpty || dz.isEmpty) {
      _logger.w('[route] skip: empty origin or destination postcode');
      clear();
      return;
    }
    if (originCountry == null || destinationCountry == null) {
      _logger.w('[route] skip: missing or invalid country code');
      clear();
      return;
    }
    if (!_isValidPostcode(oz, originCountry)) {
      _logger.w(
        '[route] skip: invalid origin postcode syntax for $originCountry: $oz',
      );
      clear();
      return;
    }
    if (!_isValidPostcode(dz, destinationCountry)) {
      _logger.w(
        '[route] skip: invalid destination postcode syntax for $destinationCountry: $dz',
      );
      clear();
      return;
    }

    final key = '$originCountry|$oz|$destinationCountry|$dz';
    if (_lastKey == key && (_route != null || _loading)) {
      return; // nic nowego
    }

    _lastKey = key;
    _debounce?.cancel();
    _logger.i('[route] schedule: $key');
    _debounce = Timer(debounce, () {
      buildRoute(
        originZip: oz,
        destinationZip: dz,
        originCountryCode: originCountry,
        destinationCountryCode: destinationCountry,
      );
    });
  }

  Future<void> buildRoute({
    required String originZip,
    required String destinationZip,
    required String originCountryCode,
    required String destinationCountryCode,
  }) async {
    _setState(loading: true, error: null);

    try {
      _logger.i(
        '[route] build: $originZip ($originCountryCode) -> $destinationZip ($destinationCountryCode)',
      );
      final s = await repo.geocodePostcode(
        postcode: originZip,
        countryCode: originCountryCode,
      );
      final e = await repo.geocodePostcode(
        postcode: destinationZip,
        countryCode: destinationCountryCode,
      );
      _start = s;
      _end = e;
      try {
        final r = await repo.fetchRoute(start: s, end: e);
        _route = r;
        _logger.i(
          '[route] ok: points=${r.points.length} dist=${r.distanceMeters} dur=${r.durationSeconds}',
        );
        _setState(loading: false, error: null);
      } catch (e, stackTrace) {
        _route = const RouteResult(points: []);
        _logger.e(
          '[route] route fetch failed',
          error: e,
          stackTrace: stackTrace,
        );
        _setState(loading: false, error: e.toString());
      }
    } catch (e, stackTrace) {
      _route = null;
      _start = null;
      _end = null;
      _logger.e('[route] geocode failed', error: e, stackTrace: stackTrace);
      _setState(loading: false, error: e.toString());
    }
  }

  void clear({bool silent = true}) {
    _debounce?.cancel();
    _route = null;
    _start = null;
    _end = null;
    _error = null;
    _loading = false;
    _lastKey = null;
    if (!silent) notifyListeners();
  }

  void _setState({required bool loading, required String? error}) {
    _loading = loading;
    _error = error;
    notifyListeners();
  }

  String? _normalizeCountryCode(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) return null;
    if (RegExp(r'^[A-Z]{2}$').hasMatch(normalized)) return normalized;
    return null;
  }

  bool _isValidPostcode(String postcode, String countryCode) {
    final pattern = _postcodePatterns[countryCode];
    if (pattern != null) return pattern.hasMatch(postcode.trim());
    return RegExp(
      r'^[A-Z0-9][A-Z0-9 -]{1,9}[A-Z0-9]$',
      caseSensitive: false,
    ).hasMatch(postcode.trim());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
