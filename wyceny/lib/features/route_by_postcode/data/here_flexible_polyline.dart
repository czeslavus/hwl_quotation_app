import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const _encodingTable =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

int _decodeChar(String char) {
  final index = _encodingTable.indexOf(char);
  if (index == -1) {
    throw FormatException('Invalid HERE polyline character: $char');
  }
  return index;
}

int _decodeUnsignedVarint(String encoded, _DecodeState state) {
  var result = 0;
  var shift = 0;

  while (true) {
    if (state.index >= encoded.length) {
      throw const FormatException('Unexpected end of HERE polyline');
    }
    final byte = _decodeChar(encoded[state.index++]);
    result |= (byte & 0x1f) << shift;

    if (byte < 0x20) break;
    shift += 5;
  }

  return result;
}

int _decodeSignedVarint(String encoded, _DecodeState state) {
  final unsigned = _decodeUnsignedVarint(encoded, state);
  final signed = (unsigned >> 1) ^ (-(unsigned & 1));
  return signed;
}

class _DecodeState {
  int index = 0;
}

List<LatLng> decodeHereFlexiblePolyline(String encoded) {
  if (encoded.isEmpty) return const [];

  final state = _DecodeState();
  final header = _decodeUnsignedVarint(encoded, state);
  final precision = header & 0x0f;
  final thirdDim = (header >> 4) & 0x07;
  final thirdDimPrecision = (header >> 7) & 0x0f;

  final factor = math.pow(10, precision).toDouble();
  final thirdDimFactor = math.pow(10, thirdDimPrecision).toDouble();

  var lastLat = 0;
  var lastLon = 0;

  final coordinates = <LatLng>[];

  while (state.index < encoded.length) {
    lastLat += _decodeSignedVarint(encoded, state);
    lastLon += _decodeSignedVarint(encoded, state);

    final lat = lastLat / factor;
    final lon = lastLon / factor;
    coordinates.add(LatLng(lat, lon));

    if (thirdDim != 0) {
      final _ = _decodeSignedVarint(encoded, state) / thirdDimFactor;
    }
  }

  return coordinates;
}
