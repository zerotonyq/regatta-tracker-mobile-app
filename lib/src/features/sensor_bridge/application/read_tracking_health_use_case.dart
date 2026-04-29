import '../../tracking/domain/tracking_health.dart';
import '../domain/sensor_bridge_repository.dart';

class ReadTrackingHealthUseCase {
  const ReadTrackingHealthUseCase(this._sensorBridgeRepository);

  final SensorBridgeRepository _sensorBridgeRepository;

  Future<TrackingHealth> execute({String? sessionId}) {
    return _sensorBridgeRepository.readTrackingHealth(sessionId: sessionId);
  }
}
