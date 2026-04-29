import '../../tracking/domain/tracking_point_entity.dart';
import '../../tracking/domain/tracking_session_failure.dart';
import '../domain/sensor_bridge_repository.dart';

class ReadCurrentTrackingPointUseCase {
  const ReadCurrentTrackingPointUseCase(this._sensorBridgeRepository);

  final SensorBridgeRepository _sensorBridgeRepository;

  Future<TrackingPointEntity> execute({required int sessionId}) async {
    final batch = await _sensorBridgeRepository
        .streamSamples(sessionId: sessionId.toString())
        .first;
    if (batch.gpsPoints.isEmpty) {
      throw TrackingSessionFailure(
        'No GPS sample available from sensor bridge.',
      );
    }

    final point = batch.gpsPoints.first;
    return TrackingPointEntity(
      sessionId: sessionId,
      timestampUtc: point.timestamp,
      longitude: point.longitude,
      latitude: point.latitude,
      accuracyMeters: point.accuracyMeters,
      speedMetersPerSecond: point.speedMetersPerSecond,
    );
  }
}
