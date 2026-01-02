import 'package:latlong2/latlong.dart';
import 'route_models.dart';

abstract class RouteRepository {
  Future<LatLng> geocodePostcode({
    required String postcode,
    required String countryCode, // np. "PL"
  });

  Future<RouteResult> fetchRoute({
    required LatLng start,
    required LatLng end,
  });
}
