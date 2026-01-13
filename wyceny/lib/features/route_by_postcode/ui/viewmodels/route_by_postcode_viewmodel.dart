import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:wyceny/app/di/locator.dart' show getIt;
import 'package:wyceny/features/logs/data/service/logger_service.dart';
import '../../domain/route_models.dart';
import '../../domain/route_repository.dart';

class RouteByPostcodeViewModel extends ChangeNotifier {
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
    String? countryCode,
    Duration debounce = const Duration(milliseconds: 500),
  }) {
    final oz = originZip.trim();
    final dz = destinationZip.trim();

    // Minimalna walidacja: oba muszą być
    if (oz.isEmpty || dz.isEmpty) {
      _logger.w('[route] skip: empty origin or destination');
      clear(silent: false);
      return;
    }

    final key = '${countryCode ?? defaultCountryCode}|$oz|$dz';
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
        countryCode: countryCode,
      );
    });
  }

  Future<void> buildRoute({
    required String originZip,
    required String destinationZip,
    String? countryCode,
  }) async {
    _setState(loading: true, error: null);

    try {
      final cc = (countryCode?.trim().isNotEmpty ?? false)
          ? countryCode!.trim()
          : defaultCountryCode;

      _logger.i('[route] build: $originZip -> $destinationZip ($cc)');
      final s = await repo.geocodePostcode(postcode: originZip, countryCode: cc);
      final e = await repo.geocodePostcode(postcode: destinationZip, countryCode: cc);
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
        _logger.e('[route] route fetch failed', error: e, stackTrace: stackTrace);
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
