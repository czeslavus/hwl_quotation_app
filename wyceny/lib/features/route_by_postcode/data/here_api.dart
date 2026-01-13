import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class HereApi {
  final Dio _dio;
  final String _apiKey;
  static const Map<String, String> _iso2ToIso3 = {
    'AL': 'ALB',
    'AD': 'AND',
    'AT': 'AUT',
    'BY': 'BLR',
    'BE': 'BEL',
    'BA': 'BIH',
    'BG': 'BGR',
    'HR': 'HRV',
    'CY': 'CYP',
    'CZ': 'CZE',
    'DK': 'DNK',
    'EE': 'EST',
    'FI': 'FIN',
    'FR': 'FRA',
    'DE': 'DEU',
    'GR': 'GRC',
    'HU': 'HUN',
    'IS': 'ISL',
    'IE': 'IRL',
    'IT': 'ITA',
    'XK': 'XKX',
    'LV': 'LVA',
    'LI': 'LIE',
    'LT': 'LTU',
    'LU': 'LUX',
    'MT': 'MLT',
    'MD': 'MDA',
    'MC': 'MCO',
    'ME': 'MNE',
    'NL': 'NLD',
    'MK': 'MKD',
    'NO': 'NOR',
    'PL': 'POL',
    'PT': 'PRT',
    'RO': 'ROU',
    'RU': 'RUS',
    'SM': 'SMR',
    'RS': 'SRB',
    'SK': 'SVK',
    'SI': 'SVN',
    'ES': 'ESP',
    'SE': 'SWE',
    'CH': 'CHE',
    'TR': 'TUR',
    'UA': 'UKR',
    'GB': 'GBR',
    'VA': 'VAT',
  };

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
    final iso2 = countryCode.toUpperCase();
    final iso3 = _iso2ToIso3[iso2] ?? iso2;
    final res = await _dio.get<Map<String, dynamic>>(
      'https://geocode.search.hereapi.com/v1/geocode',
      queryParameters: {
        'qq': 'postalCode=$postcode',
        'in': 'countryCode:$iso3',
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
        'transportMode': 'truck',
        'origin': '${start.latitude},${start.longitude}',
        'destination': '${end.latitude},${end.longitude}',
        'routingMode': 'fast',
        'return': 'polyline,summary',
        'polyline': 'flexible',
        'apiKey': _apiKey,
      },
    );

    final data = res.data;
    if (data == null) throw Exception('HERE routes: empty response');
    return data;
  }
}
