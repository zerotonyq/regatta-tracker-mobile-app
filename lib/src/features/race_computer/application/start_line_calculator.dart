import 'dart:math' as math;

import '../../tracking/domain/tracking_point_entity.dart';
import '../domain/geo_point_entity.dart';
import '../domain/start_line_entity.dart';
import '../domain/start_line_snapshot_entity.dart';
import 'geo_math.dart';

class StartLineCalculator {
  const StartLineCalculator({GeoMath geoMath = const GeoMath()})
    : _geoMath = geoMath;

  final GeoMath _geoMath;

  StartLineSnapshotEntity calculate({
    required StartLineEntity line,
    required TrackingPointEntity currentPoint,
    TrackingPointEntity? previousPoint,
    double? windDirectionDegrees,
  }) {
    final lineBearing = _geoMath.bearingDegrees(
      line.committeeBoat,
      line.pinEnd,
    );
    final lateralOffset = _signedDistanceToLine(
      line: line,
      point: GeoPointEntity(
        latitude: currentPoint.latitude,
        longitude: currentPoint.longitude,
      ),
    );
    final previousOffset = previousPoint == null
        ? lateralOffset
        : _signedDistanceToLine(
            line: line,
            point: GeoPointEntity(
              latitude: previousPoint.latitude,
              longitude: previousPoint.longitude,
            ),
          );
    final closingSpeed = previousPoint == null
        ? 0.0
        : _computeClosingSpeed(
            previousOffset: previousOffset,
            currentOffset: lateralOffset,
            previousPoint: previousPoint,
            currentPoint: currentPoint,
          );

    return StartLineSnapshotEntity(
      distanceToLineMeters: lateralOffset.abs(),
      crossedLine:
          (previousOffset <= 0 && lateralOffset > 0) ||
          (previousOffset >= 0 && lateralOffset < 0),
      favoredEnd: _favoredEnd(lineBearing, windDirectionDegrees),
      favoredEndBiasDegrees: windDirectionDegrees == null
          ? 0.0
          : _geoMath.angleDifferenceDegrees(
              lineBearing + 90,
              windDirectionDegrees,
            ),
      lineBearingDegrees: lineBearing,
      lateralOffsetMeters: lateralOffset,
      lineClosingSpeedMetersPerSecond: closingSpeed,
    );
  }

  double _signedDistanceToLine({
    required StartLineEntity line,
    required GeoPointEntity point,
  }) {
    final latScale = 111320.0;
    final lonScale =
        111320.0 *
        math.cos(
          ((line.committeeBoat.latitude + line.pinEnd.latitude) / 2) *
              math.pi /
              180.0,
        );
    final ax = line.committeeBoat.longitude * lonScale;
    final ay = line.committeeBoat.latitude * latScale;
    final bx = line.pinEnd.longitude * lonScale;
    final by = line.pinEnd.latitude * latScale;
    final px = point.longitude * lonScale;
    final py = point.latitude * latScale;
    final dx = bx - ax;
    final dy = by - ay;
    final length = math.sqrt((dx * dx) + (dy * dy));
    if (length == 0) {
      return 0;
    }
    return ((px - ax) * dy - (py - ay) * dx) / length;
  }

  double _computeClosingSpeed({
    required double previousOffset,
    required double currentOffset,
    required TrackingPointEntity previousPoint,
    required TrackingPointEntity currentPoint,
  }) {
    final dtSeconds =
        currentPoint.timestampUtc
            .difference(previousPoint.timestampUtc)
            .inMilliseconds /
        1000.0;
    if (dtSeconds <= 0) {
      return 0;
    }
    return (previousOffset.abs() - currentOffset.abs()) / dtSeconds;
  }

  String _favoredEnd(double lineBearing, double? windDirectionDegrees) {
    if (windDirectionDegrees == null) {
      return 'unknown';
    }
    final relativeWind = _geoMath.angleDifferenceDegrees(
      lineBearing + 90,
      windDirectionDegrees,
    );
    return relativeWind >= 0 ? 'committee' : 'pin';
  }
}
