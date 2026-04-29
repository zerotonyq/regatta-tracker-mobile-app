import '../domain/tracking_session_entity.dart';

class TrackingViewModel {
  const TrackingViewModel({
    required this.running,
    required this.status,
    this.session,
    this.error,
  });

  final bool running;
  final String status;
  final TrackingSessionEntity? session;
  final String? error;
}
