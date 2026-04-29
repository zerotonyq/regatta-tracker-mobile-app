import '../domain/tracking_repository.dart';
import '../domain/tracking_session_entity.dart';

class RestoreActiveTrackingSessionUseCase {
  const RestoreActiveTrackingSessionUseCase(this._trackingRepository);

  final TrackingRepository _trackingRepository;

  Future<TrackingSessionEntity?> execute() {
    return _trackingRepository.loadLatestUnfinishedSession();
  }
}
