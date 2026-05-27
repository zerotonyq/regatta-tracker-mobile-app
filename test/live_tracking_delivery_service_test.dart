import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/network/api_exception.dart';
import 'package:vkr_regatta/src/features/api/models/api_models.dart';
import 'package:vkr_regatta/src/features/receiver/data/receiver_remote_data_source.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_entity.dart';
import 'package:vkr_regatta/src/features/tracking/application/live_tracking_delivery_service.dart';
import 'package:vkr_regatta/src/features/tracking/domain/derived_metric_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/imu_chunk_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_repository.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_repository.dart';

void main() {
  test('passes race_id in live upload batch requests', () async {
    final receiver = _FakeReceiverRemoteDataSource(
      response: UploadBatchResponseDto(
        requestId: 'live-1',
        savedCount: 1,
        skippedCount: 0,
        items: <UploadBatchItemResultDto>[
          UploadBatchItemResultDto(
            clientTaskId: 'client-1',
            sessionId: 1,
            status: 'saved',
            message: 'OK',
          ),
        ],
      ),
    );
    final trackingRepository = _FakeTrackingRepository(
      sessionsById: <int, TrackingSessionEntity>{
        1: _session(id: 1, raceId: 99),
      },
    );
    final sessionRepository = _FakeTrackingSessionRepository();
    final service = LiveTrackingDeliveryService(
      receiverRemoteDataSource: receiver,
      trackingRepository: trackingRepository,
      trackingSessionRepository: sessionRepository,
    );
    final point = TrackingPointEntity(
      sessionId: 1,
      timestampUtc: DateTime.utc(2026, 4, 29, 12),
      longitude: 30,
      latitude: 60,
    );

    await service.deliverPoint(sessionId: 1, point: point);

    expect(receiver.uploadRaceIds, <int?>[99]);
    expect(sessionRepository.queuedGpsPoints, isEmpty);
  });

  test(
    'queues point and skips network upload when race_id is unavailable',
    () async {
      final receiver = _FakeReceiverRemoteDataSource(
        response: UploadBatchResponseDto(
          requestId: 'live-1',
          savedCount: 1,
          skippedCount: 0,
          items: <UploadBatchItemResultDto>[
            UploadBatchItemResultDto(
              clientTaskId: 'client-1',
              sessionId: 1,
              status: 'saved',
              message: 'OK',
            ),
          ],
        ),
      );
      final trackingRepository = _FakeTrackingRepository();
      final sessionRepository = _FakeTrackingSessionRepository();
      final service = LiveTrackingDeliveryService(
        receiverRemoteDataSource: receiver,
        trackingRepository: trackingRepository,
        trackingSessionRepository: sessionRepository,
      );
      final point = TrackingPointEntity(
        sessionId: 1,
        timestampUtc: DateTime.utc(2026, 4, 29, 12),
        longitude: 30,
        latitude: 60,
      );

      await service.deliverPoint(sessionId: 1, point: point);

      expect(receiver.uploadRaceIds, isEmpty);
      expect(sessionRepository.queuedGpsPoints, <TrackingPointEntity>[point]);
    },
  );

  test(
    'queues live point when receiver skips it before race acceptance',
    () async {
      final receiver = _FakeReceiverRemoteDataSource(
        response: UploadBatchResponseDto(
          requestId: 'live-1',
          savedCount: 0,
          skippedCount: 1,
          items: <UploadBatchItemResultDto>[
            UploadBatchItemResultDto(
              clientTaskId: 'client-1',
              sessionId: 1,
              status: 'skipped',
              message:
                  "The race either didn't start or ended. The received coordinates were not saved",
            ),
          ],
        ),
      );
      final trackingRepository = _FakeTrackingRepository(
        sessionsById: <int, TrackingSessionEntity>{
          1: _session(id: 1, raceId: 10),
        },
      );
      final sessionRepository = _FakeTrackingSessionRepository();
      final service = LiveTrackingDeliveryService(
        receiverRemoteDataSource: receiver,
        trackingRepository: trackingRepository,
        trackingSessionRepository: sessionRepository,
      );
      final point = TrackingPointEntity(
        sessionId: 1,
        timestampUtc: DateTime.utc(2026, 4, 29, 12),
        longitude: 30,
        latitude: 60,
      );

      await service.deliverPoint(sessionId: 1, point: point);

      expect(trackingRepository.savedGpsPoints, <TrackingPointEntity>[point]);
      expect(sessionRepository.queuedGpsPoints, <TrackingPointEntity>[point]);
    },
  );
}

class _FakeReceiverRemoteDataSource extends ReceiverRemoteDataSource {
  _FakeReceiverRemoteDataSource({required this.response})
    : super(receiverApi: null);

  final UploadBatchResponseDto response;
  final List<int?> uploadRaceIds = <int?>[];

  @override
  Future<UploadBatchResponseDto> uploadBatch({
    required String requestId,
    int? raceId,
    required List<UploadBatchPointDto> points,
  }) async {
    if (points.isEmpty) {
      throw ApiException(statusCode: 400, message: 'points required');
    }
    uploadRaceIds.add(raceId);
    return response;
  }
}

class _FakeTrackingSessionRepository implements TrackingSessionRepository {
  final List<TrackingPointEntity> queuedGpsPoints = <TrackingPointEntity>[];

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    required TrackingSessionState state,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<int> getPendingSyncCount({int? sessionId}) async => 0;

  @override
  Future<TrackingPointEntity?> loadLatestGpsPoint(int sessionId) async => null;

  @override
  Future<List<SyncJobEntity>> loadPendingSyncJobs() async =>
      const <SyncJobEntity>[];

  @override
  Future<void> queueGpsPointForSync(TrackingPointEntity point) async {
    queuedGpsPoints.add(point);
  }

  @override
  Future<TrackingSessionEntity?> restoreSession() async => null;

  @override
  Future<void> saveGpsPoint(TrackingPointEntity point) {
    throw UnimplementedError();
  }

  @override
  Future<TrackingSessionEntity> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }
}

class _FakeTrackingRepository implements TrackingRepository {
  _FakeTrackingRepository({Map<int, TrackingSessionEntity>? sessionsById})
    : _sessionsById = sessionsById ?? <int, TrackingSessionEntity>{};

  final List<TrackingPointEntity> savedGpsPoints = <TrackingPointEntity>[];
  final Map<int, TrackingSessionEntity> _sessionsById;

  @override
  Future<TrackingSessionEntity> createSession({
    required int raceId,
    required String role,
    required int intervalSeconds,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasImuChunk({
    required int sessionId,
    required DateTime capturedAtUtc,
  }) async => false;

  @override
  Future<List<DerivedMetricEntity>> loadDerivedMetricsForSession(
    int sessionId, {
    int? limit,
  }) async => const <DerivedMetricEntity>[];

  @override
  Future<List<TrackingPointEntity>> loadGpsPointsForSession(
    int sessionId,
  ) async => savedGpsPoints;

  @override
  Future<TrackingPointEntity?> loadLatestGpsPointForSession(
    int sessionId,
  ) async => savedGpsPoints.isEmpty ? null : savedGpsPoints.last;

  @override
  Future<TrackingSessionEntity?> loadLatestUnfinishedSession() async => null;

  @override
  Future<List<TrackingPointEntity>> loadRecentGpsPointsForSession(
    int sessionId, {
    int limit = 2,
  }) async => savedGpsPoints.take(limit).toList(growable: false);

  @override
  Future<TrackingSessionEntity?> loadSessionById(int sessionId) async =>
      _sessionsById[sessionId];

  @override
  Future<void> saveDerivedMetrics(List<DerivedMetricEntity> metrics) async {}

  @override
  Future<void> saveGpsPoint({required TrackingPointEntity point}) async {
    savedGpsPoints.add(point);
  }

  @override
  Future<void> saveImuChunk({required ImuChunkEntity chunk}) async {}

  @override
  Future<void> transitionSessionState({
    required int sessionId,
    required TrackingSessionState state,
    DateTime? endedAtUtc,
    String? failureReason,
    DateTime? lastSyncAtUtc,
    String? sensorHealthSnapshot,
  }) {
    throw UnimplementedError();
  }
}

TrackingSessionEntity _session({required int id, required int raceId}) {
  return TrackingSessionEntity(
    id: id,
    raceId: raceId,
    role: 'participant',
    state: TrackingSessionState.tracking,
    intervalSeconds: 1,
    startedAtUtc: DateTime.utc(2026, 4, 29, 11),
  );
}
