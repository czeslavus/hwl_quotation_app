import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OrsApi {
  final Dio _dio;

  OrsApi({
    required String apiKey,
    Dio? dio,
  }) : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://api.openrouteservice.org',
        headers: {
          'Authorization': apiKey,
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ));

  Future<LatLng> geocodePostcode({
    required String postcode,
    required String countryCode,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/geocode/search',
      queryParameters: {
        'text': postcode,
        'boundary.country': countryCode,
        'size': 1,
      },
    );

    final data = res.data;
    if (data == null) throw Exception('ORS geocode: empty response');

    final features = (data['features'] as List?) ?? const [];
    if (features.isEmpty) {
      throw Exception('No geocode results for "$postcode"');
    }

    final f0 = features.first as Map<String, dynamic>;
    final geom = f0['geometry'] as Map<String, dynamic>;
    final coords = geom['coordinates'] as List; // [lon, lat]

    final lon = (coords[0] as num).toDouble();
    final lat = (coords[1] as num).toDouble();
    return LatLng(lat, lon);
  }

  Future<Map<String, dynamic>> directionsGeoJson({
    required LatLng start,
    required LatLng end,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/v2/directions/driving-car',
      data: {
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ],
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    final data = res.data;
    if (data == null) throw Exception('ORS directions: empty response');
    return data;
  }
}
