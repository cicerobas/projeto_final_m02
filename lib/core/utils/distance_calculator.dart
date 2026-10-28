import 'dart:math';

abstract final class DistanceCalculator {
  static const double _earthRadiusKm = 6371.0;

  static double haversineKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    final deltaLatitude = _toRadians(toLatitude - fromLatitude);
    final deltaLongitude = _toRadians(toLongitude - fromLongitude);

    final a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(_toRadians(fromLatitude)) *
            cos(_toRadians(toLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
