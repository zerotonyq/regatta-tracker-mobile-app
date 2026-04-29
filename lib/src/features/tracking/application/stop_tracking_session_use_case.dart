import '../domain/tracking_repository.dart';
import '../domain/tracking_session_entity.dart';

class StopTrackingSessionUseCase {
  const StopTrackingSessionUseCase(this._trackingRepository);

  final TrackingRepository _trackingRepository;

  Future<String> execute({
    required int sessionId,
    TrackingSessionState state = TrackingSessionState.completed,
    String? failureReason,
  }) async {
    await _trackingRepository.transitionSessionState(
      sessionId: sessionId,
      state: state,
      endedAtUtc: DateTime.now().toUtc(),
      failureReason: failureReason,
    );
    return state == TrackingSessionState.completed
        ? 'Tracking session stopped'
        : 'Tracking session finished with state ${state.name}';
  }
}
