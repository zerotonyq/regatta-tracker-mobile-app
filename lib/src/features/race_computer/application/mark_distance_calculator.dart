import '../../tracking/domain/tracking_point_entity.dart';
import '../domain/geo_point_entity.dart';
import '../domain/mark_entity.dart';
import '../domain/mark_snapshot_entity.dart';
import 'geo_math.dart';

class MarkDistanceCalculator {
  const MarkDistanceCalculator({GeoMath geoMath = const GeoMath()})
    : _geoMath = geoMath;

  final GeoMath _geoMath;

  MarkSnapshotEntity calculate({
    required MarkEntity mark,
    required TrackingPointEntity currentPoint,
  }) {
    final boatPoint = GeoPointEntity(
      latitude: currentPoint.latitude,
      longitude: currentPoint.longitude,
    );
    final distance = _geoMath.distanceMeters(boatPoint, mark.position);
    final bearing = _geoMath.bearingDegrees(boatPoint, mark.position);
    final speed = currentPoint.speedMetersPerSecond;
    final etaSeconds = speed == null || speed <= 0.2
        ? null
        : (distance / speed).round();

    return MarkSnapshotEntity(
      markName: mark.name,
      distanceMeters: distance,
      bearingDegrees: bearing,
      etaSeconds: etaSeconds,
    );
  }
}
