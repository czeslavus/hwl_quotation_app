import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class HereApi {
  final Dio _dio;
  final String _apiKey;

  HereApi({
    required String apiKey,
    Dio? dio,
  })  : _apiKey = apiKey,
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'Accept': 'application/json',
              },
            ));

  Future<LatLng> geocodePostcode({
    required String postcode,
    required String countryCode,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://geocode.search.hereapi.com/v1/geocode',
      queryParameters: {
        'qq': 'postalCode=$postcode',
        'in': 'countryCode:$countryCode',
        'limit': 1,
        'apiKey': _apiKey,
      },
    );

    final data = res.data;
    if (data == null) throw Exception('HERE geocode: empty response');

    final items = (data['items'] as List?) ?? const [];
    if (items.isEmpty) {
      throw Exception('No geocode results for "$postcode"');
    }

    final item0 = items.first as Map<String, dynamic>;
    final position = item0['position'] as Map<String, dynamic>;
    final lat = (position['lat'] as num).toDouble();
    final lon = (position['lng'] as num).toDouble();

    return LatLng(lat, lon);
  }

  Future<Map<String, dynamic>> directions({
    required LatLng start,
    required LatLng end,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      'https://router.hereapi.com/v8/routes',
      queryParameters: {
        'transportMode': 'car',
        'origin': '${start.latitude},${start.longitude}',
        'destination': '${end.latitude},${end.longitude}',
        'routingMode': 'fast',
        'return': 'polyline,summary',
        'apiKey': _apiKey,
      },
    );

    final data = res.data;
    if (data == null) throw Exception('HERE routes: empty response');
    return data;
  }
}
