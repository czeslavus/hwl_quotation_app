import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double? distanceMeters;
  final double? durationSeconds;

  const RouteResult({
    required this.points,
    this.distanceMeters,
    this.durationSeconds,
  });

  bool get isEmpty => points.isEmpty;
}
