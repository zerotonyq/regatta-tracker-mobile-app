import '../../tracking/domain/tracking_point_entity.dart';
import '../domain/sensor_bridge_repository.dart';

class ReadCurrentTrackingPointUseCase {
  const ReadCurrentTrackingPointUseCase(this._sensorBridgeRepository);

  final SensorBridgeRepository _sensorBridgeRepository;

  Future<TrackingPointEntity> execute() async {
    final point = await _sensorBridgeRepository.getCurrentLocation();
    return TrackingPointEntity(
      sessionId: 0,
      timestampUtc: point.timestamp,
      longitude: point.longitude,
      latitude: point.latitude,
      accuracyMeters: point.accuracyMeters,
      speedMetersPerSecond: point.speedMetersPerSecond,
    );
  }
}
