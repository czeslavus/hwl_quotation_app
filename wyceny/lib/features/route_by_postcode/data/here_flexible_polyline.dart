import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const _encodingTable =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

int _decodeChar(String encoded, int index) {
  if (index >= encoded.length) {
    throw FormatException('Unexpected end of HERE polyline', encoded, index);
  }

  final char = encoded[index];
  final tableIndex = _encodingTable.indexOf(char);
  if (tableIndex == -1) {
    throw FormatException(
      'Invalid HERE polyline character: $char',
      encoded,
      index,
    );
  }
  return tableIndex;
}

int _decodeUnsignedVarint(String encoded, _DecodeState state) {
  var result = BigInt.zero;
  var shift = 0;

  while (true) {
    final byte = _decodeChar(encoded, state.index);
    state.index += 1;
    final value = byte % 32;
    result += BigInt.from(value) << shift;

    if (byte < 0x20) break;
    shift += 5;
  }

  return result.toInt();
}

int _decodeSignedVarint(String encoded, _DecodeState state) {
  final unsigned = _decodeUnsignedVarint(encoded, state);
  final value = unsigned ~/ 2;
  return unsigned.isOdd ? -value - 1 : value;
}

class _DecodeState {
  int index = 0;
}

class _PolylineDecodeResult {
  final List<LatLng> points;
  final bool isValid;

  const _PolylineDecodeResult(this.points, this.isValid);
}

List<LatLng> decodeHereFlexiblePolyline(String encoded) {
  if (encoded.isEmpty) return const [];

  final flexibleResult = _decodeFlexiblePolyline(encoded);
  if (flexibleResult.isValid) return flexibleResult.points;

  if (encoded.length > 1) {
    final trimmedResult = _decodeFlexiblePolyline(encoded.substring(1));
    if (trimmedResult.isValid) return trimmedResult.points;
  }

  final legacy5 = _decodeEncodedPolyline(encoded, precision: 5);
  if (_coordinatesInRange(legacy5)) return legacy5;

  final legacy6 = _decodeEncodedPolyline(encoded, precision: 6);
  if (_coordinatesInRange(legacy6)) return legacy6;

  return flexibleResult.points;
}

_PolylineDecodeResult _decodeFlexiblePolyline(String encoded) {
  final state = _DecodeState();
  final coordinates = <LatLng>[];
  var isValid = true;

  try {
    final header = _decodeUnsignedVarint(encoded, state);
    final precision = header & 0x0f;
    final thirdDim = (header >> 4) & 0x07;
    final thirdDimPrecision = (header >> 7) & 0x0f;

    final factor = math.pow(10, precision).toDouble();
    final thirdDimFactor = math.pow(10, thirdDimPrecision).toDouble();

    var lastLat = 0;
    var lastLon = 0;

    while (state.index < encoded.length) {
      lastLat += _decodeSignedVarint(encoded, state);
      lastLon += _decodeSignedVarint(encoded, state);

      final lat = lastLat / factor;
      final lon = lastLon / factor;
      if (lat.abs() > 90 || lon.abs() > 180) {
        isValid = false;
        break;
      }
      coordinates.add(LatLng(lat, lon));

      if (thirdDim != 0) {
        final _ = _decodeSignedVarint(encoded, state) / thirdDimFactor;
      }
    }
  } on FormatException catch (_) {
    isValid = false;
  }

  return _PolylineDecodeResult(coordinates, isValid);
}

List<LatLng> _decodeEncodedPolyline(String encoded, {required int precision}) {
  final coordinates = <LatLng>[];
  var index = 0;
  var lat = 0;
  var lon = 0;
  final factor = math.pow(10, precision).toDouble();

  while (index < encoded.length) {
    final latResult = _decodeLegacyValue(encoded, index);
    if (latResult == null) break;
    index = latResult.nextIndex;
    lat += latResult.value;

    final lonResult = _decodeLegacyValue(encoded, index);
    if (lonResult == null) break;
    index = lonResult.nextIndex;
    lon += lonResult.value;

    coordinates.add(LatLng(lat / factor, lon / factor));
  }

  return coordinates;
}

class _LegacyDecodeResult {
  final int value;
  final int nextIndex;

  const _LegacyDecodeResult(this.value, this.nextIndex);
}

_LegacyDecodeResult? _decodeLegacyValue(String encoded, int startIndex) {
  var result = BigInt.zero;
  var shift = 0;
  var index = startIndex;

  while (index < encoded.length) {
    final byte = encoded.codeUnitAt(index) - 63;
    index += 1;
    final value = byte % 32;
    result += BigInt.from(value) << shift;
    shift += 5;
    if (byte < 0x20) {
      final unsigned = result.toInt();
      final shifted = unsigned ~/ 2;
      final signed = unsigned.isOdd ? -shifted - 1 : shifted;
      return _LegacyDecodeResult(signed, index);
    }
  }

  return null;
}

bool _coordinatesInRange(List<LatLng> points) {
  if (points.isEmpty) return false;
  for (final point in points) {
    if (point.latitude.abs() > 90 || point.longitude.abs() > 180) {
      return false;
    }
  }
  return true;
}
