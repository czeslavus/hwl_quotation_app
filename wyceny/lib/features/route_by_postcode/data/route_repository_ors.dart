import 'package:latlong2/latlong.dart';
import '../domain/route_models.dart';
import '../domain/route_repository.dart';
import 'ors_api.dart';

class OrsRouteRepository implements RouteRepository {
  final OrsApi api;

  OrsRouteRepository(this.api);

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
    final geo = await api.directionsGeoJson(start: start, end: end);

    final features = (geo['features'] as List?) ?? const [];
    if (features.isEmpty) return const RouteResult(points: []);

    final feat0 = features.first as Map<String, dynamic>;
    final geometry = (feat0['geometry'] as Map<String, dynamic>?) ?? const {};
    final coords = (geometry['coordinates'] as List?) ?? const [];

    final points = <LatLng>[];
    for (final c in coords) {
      if (c is List && c.length >= 2) {
        final lon = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        points.add(LatLng(lat, lon));
      }
    }

    double? distance;
    double? duration;

    final props = feat0['properties'];
    if (props is Map<String, dynamic>) {
      final summary = props['summary'];
      if (summary is Map<String, dynamic>) {
        distance = (summary['distance'] as num?)?.toDouble();
        duration = (summary['duration'] as num?)?.toDouble();
      }
    }

    return RouteResult(
      points: points,
      distanceMeters: distance,
      durationSeconds: duration,
    );
  }
}
