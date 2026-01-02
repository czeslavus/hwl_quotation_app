import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:wyceny/features/quotations/ui/viewmodels/quotation_viewmodel.dart';
import 'package:wyceny/features/route_by_postcode/domain/route_repository.dart';
import 'package:wyceny/features/route_by_postcode/ui/viewmodels/route_by_postcode_viewmodel.dart';

// TODO: <- popraw import na TEN, gdzie masz getIt i setupDI()
import 'package:wyceny/app/di/locator.dart' show getIt;

class QuotationRouteMap extends StatelessWidget {
  const QuotationRouteMap({super.key});

  @override
  Widget build(BuildContext context) {
    // Lokalny VM tylko do mapy (część ekranu) — minimalne i izolowane
    return ChangeNotifierProvider<RouteByPostcodeViewModel>(
      create: (_) => RouteByPostcodeViewModel(
        repo: getIt<RouteRepository>(),
        defaultCountryCode: 'PL',
      ),
      child: const _QuotationRouteMapBody(),
    );
  }
}

class _QuotationRouteMapBody extends StatefulWidget {
  const _QuotationRouteMapBody();

  @override
  State<_QuotationRouteMapBody> createState() => _QuotationRouteMapBodyState();
}

class _QuotationRouteMapBodyState extends State<_QuotationRouteMapBody> {
  final MapController _mapController = MapController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Kiedy VM od wyceny się zmienia (zipy/cokolwiek), odpalamy routing
    final qvm = context.watch<QuotationViewModel>();
    final rvm = context.read<RouteByPostcodeViewModel>();

    // Jeśli kiedyś chcesz używać kraju z dropdownów:
    // - ORS chce ISO-2 (np. "PL", "DE").
    // - Ty masz originCountryId/destinationCountryId, więc musisz mieć mapę id -> iso2.
    // Na POC zostawiamy "PL".
    rvm.scheduleBuildRoute(
      originZip: qvm.originZip,
      destinationZip: qvm.destinationZip,
      countryCode: 'PL',
    );
  }

  @override
  Widget build(BuildContext context) {
    final rvm = context.watch<RouteByPostcodeViewModel>();

    // Auto-dopasowanie kamery do trasy (po pobraniu)
    final points = rvm.route?.points ?? const <LatLng>[];
    if (points.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(18),
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
        ),

        // lekki overlay statusu
        Positioned(
          left: 8,
          top: 8,
          right: 8,
          child: _StatusPill(
            loading: rvm.loading,
            error: rvm.error,
            hasRoute: points.isNotEmpty,
          ),
        ),
      ],
    );
  }
}

class _RouteMap extends StatelessWidget {
  final MapController mapController;
  final LatLng? start;
  final LatLng? end;
  final List<LatLng> routePoints;

  const _RouteMap({
    required this.mapController,
    required this.start,
    required this.end,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    final center = start ?? const LatLng(52.2297, 21.0122); // fallback: Warszawa

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
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'pl.hellmann.wyceny', // <- ustaw na swój package
          ),
          if (routePoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints,
                  strokeWidth: 4,
                ),
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
  final bool hasRoute;

  const _StatusPill({
    required this.loading,
    required this.error,
    required this.hasRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading && error == null && !hasRoute) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    Widget child;
    if (loading) {
      child = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Wyznaczanie trasy...'),
        ],
      );
    } else if (error != null) {
      child = Text(
        error!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      child = const Text('Trasa gotowa');
    }

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      color: error != null
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DefaultTextStyle(
          style: theme.textTheme.bodyMedium!.copyWith(
            color: error != null
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onSurface,
          ),
          child: child,
        ),
      ),
    );
  }
}
