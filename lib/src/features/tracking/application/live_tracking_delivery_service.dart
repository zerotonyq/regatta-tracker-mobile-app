import '../../../core/network/api_exception.dart';
import '../../../core/network/network_failure.dart';
import '../../api/models/api_models.dart';
import '../../receiver/data/receiver_remote_data_source.dart';
import '../domain/tracking_point_entity.dart';
import '../domain/tracking_repository.dart';
import '../domain/tracking_session_repository.dart';

class LiveTrackingDeliveryService {
  LiveTrackingDeliveryService({
    required ReceiverRemoteDataSource receiverRemoteDataSource,
    required TrackingRepository trackingRepository,
    required TrackingSessionRepository trackingSessionRepository,
    this.maxConsecutiveFailuresBeforeLocalBuffer = 3,
  }) : _receiverRemoteDataSource = receiverRemoteDataSource,
       _trackingRepository = trackingRepository,
       _trackingSessionRepository = trackingSessionRepository;

  final ReceiverRemoteDataSource _receiverRemoteDataSource;
  final TrackingRepository _trackingRepository;
  final TrackingSessionRepository _trackingSessionRepository;
  final int maxConsecutiveFailuresBeforeLocalBuffer;

  final Map<int, int> _consecutiveFailuresBySession = <int, int>{};
  final Map<int, List<TrackingPointEntity>> _pendingPointsBySession =
      <int, List<TrackingPointEntity>>{};
  final Set<int> _localFallbackSessions = <int>{};

  Future<void> deliverPoint({
    required int sessionId,
    required TrackingPointEntity point,
  }) async {
    await _trackingRepository.saveGpsPoint(point: point);

    try {
      await _receiverRemoteDataSource.uploadBatch(
        requestId: _requestIdFor(sessionId, point),
        points: <UploadBatchPointDto>[_pointDtoFromEntity(sessionId, point)],
      );
      _resetFailureState(sessionId);
    } catch (error) {
      if (!_shouldFallbackLocally(error)) {
        rethrow;
      }

      final pendingPoints = _pendingPointsBySession.putIfAbsent(
        sessionId,
        () => <TrackingPointEntity>[],
      );
      pendingPoints.add(point);

      final failureCount = (_consecutiveFailuresBySession[sessionId] ?? 0) + 1;
      _consecutiveFailuresBySession[sessionId] = failureCount;

      if (failureCount >= maxConsecutiveFailuresBeforeLocalBuffer) {
        _localFallbackSessions.add(sessionId);
      }

      if (!_localFallbackSessions.contains(sessionId)) {
        return;
      }

      for (final pendingPoint in List<TrackingPointEntity>.from(pendingPoints)) {
        await _trackingSessionRepository.queueGpsPointForSync(pendingPoint);
      }
      pendingPoints.clear();
    }
  }

  void _resetFailureState(int sessionId) {
    _consecutiveFailuresBySession.remove(sessionId);
    _pendingPointsBySession.remove(sessionId);
    _localFallbackSessions.remove(sessionId);
  }

  bool _shouldFallbackLocally(Object error) {
    if (error is NetworkFailure) {
      return error.isRetryable || error.type == NetworkFailureType.server;
    }
    if (error is ApiException) {
      final statusCode = error.statusCode;
      return statusCode == null || statusCode >= 500;
    }
    return true;
  }

  String _requestIdFor(int sessionId, TrackingPointEntity point) {
    return 'live-$sessionId-${point.timestampUtc.microsecondsSinceEpoch}';
  }

  UploadBatchPointDto _pointDtoFromEntity(
    int sessionId,
    TrackingPointEntity point,
  ) {
    return UploadBatchPointDto(
      clientTaskId: _requestIdFor(sessionId, point),
      sessionId: sessionId,
      timestampUtc: point.timestampUtc.toUtc().toIso8601String(),
      longitude: point.longitude,
      latitude: point.latitude,
      accuracyMeters: point.accuracyMeters,
      speedMetersPerSecond: point.speedMetersPerSecond,
    );
  }
}
