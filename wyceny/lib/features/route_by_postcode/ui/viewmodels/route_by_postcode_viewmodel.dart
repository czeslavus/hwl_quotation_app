import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/route_models.dart';
import '../../domain/route_repository.dart';

class RouteByPostcodeViewModel extends ChangeNotifier {
  final RouteRepository repo;

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
      clear(silent: false);
      return;
    }

    final key = '${countryCode ?? defaultCountryCode}|$oz|$dz';
    if (_lastKey == key && (_route != null || _loading)) {
      return; // nic nowego
    }

    _lastKey = key;
    _debounce?.cancel();
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

      final s = await repo.geocodePostcode(postcode: originZip, countryCode: cc);
      final e = await repo.geocodePostcode(postcode: destinationZip, countryCode: cc);

      final r = await repo.fetchRoute(start: s, end: e);

      _start = s;
      _end = e;
      _route = r;

      _setState(loading: false, error: null);
    } catch (e) {
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
