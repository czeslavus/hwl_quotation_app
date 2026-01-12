import 'package:latlong2/latlong.dart';

import '../domain/route_models.dart';
import '../domain/route_repository.dart';
import 'here_api.dart';
import 'here_flexible_polyline.dart';

class HereRouteRepository implements RouteRepository {
  final HereApi api;

  HereRouteRepository(this.api);

  @override
  Future<LatLng> geocodePostcode({
    required String postcode,
    required String countryCode,
  }) {
    return api.geocodePostcode(postcode: postcode, countryCode: countryCode);
  }

  @override
  Future<RouteResult> fetchRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    final data = await api.directions(start: start, end: end);

    final routes = (data['routes'] as List?) ?? const [];
    if (routes.isEmpty) return const RouteResult(points: []);

    final route0 = routes.first as Map<String, dynamic>;
    final sections = (route0['sections'] as List?) ?? const [];
    if (sections.isEmpty) return const RouteResult(points: []);

    final section0 = sections.first as Map<String, dynamic>;
    final polyline = section0['polyline'] as String?;
    final points = polyline == null ? const <LatLng>[] : decodeHereFlexiblePolyline(polyline);

    double? distance;
    double? duration;
    final summary = section0['summary'];
    if (summary is Map<String, dynamic>) {
      distance = (summary['length'] as num?)?.toDouble();
      duration = (summary['duration'] as num?)?.toDouble();
    }

    return RouteResult(
      points: points,
      distanceMeters: distance,
      durationSeconds: duration,
    );
  }
}
