import 'dart:math' as math;

import '../domain/geo_point_entity.dart';

class GeoMath {
  const GeoMath();

  static const double earthRadiusMeters = 6371000;

  double distanceMeters(GeoPointEntity from, GeoPointEntity to) {
    final dLat = _degreesToRadians(to.latitude - from.latitude);
    final dLon = _degreesToRadians(to.longitude - from.longitude);
    final lat1 = _degreesToRadians(from.latitude);
    final lat2 = _degreesToRadians(to.latitude);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double bearingDegrees(GeoPointEntity from, GeoPointEntity to) {
    final lat1 = _degreesToRadians(from.latitude);
    final lat2 = _degreesToRadians(to.latitude);
    final dLon = _degreesToRadians(to.longitude - from.longitude);
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return normalizeDegrees(_radiansToDegrees(math.atan2(y, x)));
  }

  GeoPointEntity offsetPoint({
    required GeoPointEntity origin,
    required double bearingDegrees,
    required double distanceMeters,
  }) {
    final angularDistance = distanceMeters / earthRadiusMeters;
    final bearing = _degreesToRadians(bearingDegrees);
    final lat1 = _degreesToRadians(origin.latitude);
    final lon1 = _degreesToRadians(origin.longitude);

    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angularDistance) +
          math.cos(lat1) * math.sin(angularDistance) * math.cos(bearing),
    );
    final lon2 =
        lon1 +
        math.atan2(
          math.sin(bearing) * math.sin(angularDistance) * math.cos(lat1),
          math.cos(angularDistance) - math.sin(lat1) * math.sin(lat2),
        );

    return GeoPointEntity(
      latitude: _radiansToDegrees(lat2),
      longitude: _radiansToDegrees(lon2),
    );
  }

  double normalizeDegrees(double degrees) {
    final normalized = degrees % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  double angleDifferenceDegrees(double from, double to) {
    final delta = normalizeDegrees(to - from);
    return delta > 180 ? delta - 360 : delta;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  double _radiansToDegrees(double radians) => radians * 180 / math.pi;
}
