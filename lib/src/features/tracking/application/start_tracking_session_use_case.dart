import '../domain/tracking_repository.dart';
import '../domain/tracking_session_entity.dart';

class StartTrackingSessionUseCase {
  const StartTrackingSessionUseCase(this._trackingRepository);

  final TrackingRepository _trackingRepository;

  Future<TrackingSessionEntity> execute({
    required int raceId,
    required int intervalSeconds,
    required String role,
    String? sensorHealthSnapshot,
  }) {
    return _trackingRepository.createSession(
      raceId: raceId,
      role: role,
      intervalSeconds: intervalSeconds,
      sensorHealthSnapshot: sensorHealthSnapshot,
    );
  }
}
