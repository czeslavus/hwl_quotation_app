import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:wyceny/app/env/app_environment.dart';
import 'package:wyceny/app/di/locator.dart' show getIt;
import 'package:wyceny/features/route_by_postcode/domain/route_repository.dart';
import 'package:wyceny/features/route_by_postcode/ui/viewmodels/route_by_postcode_viewmodel.dart';

class RouteMapByPostcode extends StatelessWidget {
  const RouteMapByPostcode({
    super.key,
    required this.originZip,
    required this.destinationZip,
    this.originCountryCode,
    this.destinationCountryCode,
    this.defaultCountryCode = 'PL',
  });

  final String originZip;
  final String destinationZip;
  final String? originCountryCode;
  final String? destinationCountryCode;
  final String defaultCountryCode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RouteByPostcodeViewModel>(
      create: (_) => RouteByPostcodeViewModel(
        repo: getIt<RouteRepository>(),
        defaultCountryCode: defaultCountryCode,
      ),
      child: _RouteMapBody(
        originZip: originZip,
        destinationZip: destinationZip,
        originCountryCode: originCountryCode,
        destinationCountryCode: destinationCountryCode,
        defaultCountryCode: defaultCountryCode,
      ),
    );
  }
}

class _RouteMapBody extends StatefulWidget {
  const _RouteMapBody({
    required this.originZip,
    required this.destinationZip,
    required this.originCountryCode,
    required this.destinationCountryCode,
    required this.defaultCountryCode,
  });

  final String originZip;
  final String destinationZip;
  final String? originCountryCode;
  final String? destinationCountryCode;
  final String defaultCountryCode;

  @override
  State<_RouteMapBody> createState() => _RouteMapBodyState();
}

class _RouteMapBodyState extends State<_RouteMapBody> {
  final MapController _mapController = MapController();

  String? _lastOrigin;
  String? _lastDest;
  String? _lastCountry;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleRoute();
    });
  }

  @override
  void didUpdateWidget(covariant _RouteMapBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleRoute();
    });
  }

  void _scheduleRoute() {
    final rvm = context.read<RouteByPostcodeViewModel>();

    final origin = widget.originZip;
    final dest = widget.destinationZip;
    final country = _pickCountryCode();

    final changed = origin != _lastOrigin || dest != _lastDest || country != _lastCountry;
    if (!changed) return;

    _lastOrigin = origin;
    _lastDest = dest;
    _lastCountry = country;

    rvm.scheduleBuildRoute(
      originZip: origin,
      destinationZip: dest,
      countryCode: country,
    );
  }

  String _pickCountryCode() {
    final origin = widget.originCountryCode?.trim();
    if (origin != null && origin.isNotEmpty) return origin;
    final dest = widget.destinationCountryCode?.trim();
    if (dest != null && dest.isNotEmpty) return dest;
    return widget.defaultCountryCode;
  }

  @override
  Widget build(BuildContext context) {
    final rvm = context.watch<RouteByPostcodeViewModel>();
    final points = rvm.route?.points ?? const <LatLng>[];
    final routeColor = getIt<EnvConfig>().routeColor;
    final routeDistanceKm = _distanceKm(rvm.route?.distanceMeters);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (points.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final bounds = LatLngBounds.fromPoints(points);
            final padding = _routePadding(constraints);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: padding,
              ),
            );
          });
        }

        return Stack(
          children: [
            _RouteMap(
              mapController: _mapController,
              start: rvm.start,
              end: rvm.end,
              routePoints: points,
              routeColor: routeColor,
            ),
            Positioned(
              left: 8,
              top: 8,
              right: 8,
              child: _StatusPill(
                loading: rvm.loading,
                error: rvm.error,
              ),
            ),
            if (routeDistanceKm != null && points.isNotEmpty)
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: _DistancePill(distanceKm: routeDistanceKm),
              ),
          ],
        );
      },
    );
  }

  double? _distanceKm(double? meters) {
    if (meters == null || meters <= 0) return null;
    return meters / 1000.0;
  }

  EdgeInsets _routePadding(BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      return const EdgeInsets.all(18);
    }

    final horizontal = constraints.maxWidth * 0.1;
    final vertical = constraints.maxHeight * 0.1;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }
}

class _RouteMap extends StatelessWidget {
  final MapController mapController;
  final LatLng? start;
  final LatLng? end;
  final List<LatLng> routePoints;
  final Color routeColor;

  const _RouteMap({
    required this.mapController,
    required this.start,
    required this.end,
    required this.routePoints,
    required this.routeColor,
  });

  @override
  Widget build(BuildContext context) {
    final center = start ?? const LatLng(52.2297, 21.0122);

    final markers = <Marker>[
      if (start != null)
        Marker(
          point: start!,
          width: 40,
          height: 40,
          child: const Icon(Icons.location_on, size: 36),
        ),
      if (end != null)
        Marker(
          point: end!,
          width: 40,
          height: 40,
          child: const Icon(Icons.flag, size: 30),
        ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 10,
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'pl.hellmann.wyceny',
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(points: routePoints, strokeWidth: 4, color: routeColor),
              ],
            ),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool loading;
  final String? error;

  const _StatusPill({
    required this.loading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading && error == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    final Widget child;
    if (loading) {
      child = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Wyznaczanie trasy...'),
        ],
      );
    } else {
      child = Text(error ?? '', maxLines: 2, overflow: TextOverflow.ellipsis);
    }

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      color: error != null ? theme.colorScheme.errorContainer : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(
            color: error != null ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSurface,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DistancePill extends StatelessWidget {
  final double distanceKm;

  const _DistancePill({required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = 'Dystans: ${distanceKm.toStringAsFixed(1)} km';

    return Align(
      alignment: Alignment.center,
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
