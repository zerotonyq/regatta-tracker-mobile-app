import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:vkr_regatta/src/features/judge/domain/judge_action_entity.dart';
import 'package:vkr_regatta/src/features/judge/data/judge_local_repository_impl.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_race_context_entity.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_race_status.dart';
import 'package:vkr_regatta/src/features/local_storage/database/app_database.dart';
import 'package:vkr_regatta/src/features/sync/data/sync_repository_impl.dart';
import 'package:vkr_regatta/src/features/sync/domain/sync_job_entity.dart';
import 'package:vkr_regatta/src/features/tracking/data/tracking_repository_impl.dart';
import 'package:vkr_regatta/src/features/tracking/domain/imu_chunk_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_session_entity.dart';

void main() {
  test(
    'persists session, gps points, imu chunks and sync queue across reopen',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('regatta-db-test');
      final dbFile = File(p.join(tempDir.path, 'regatta_test.sqlite'));

      final database = AppDatabase(executor: NativeDatabase(dbFile));
      final trackingRepository = TrackingRepositoryImpl(database);
      final syncRepository = SyncRepositoryImpl(database);

      final session = await trackingRepository.createSession(
        raceId: 42,
        role: 'participant',
        intervalSeconds: 5,
        sensorHealthSnapshot: '{"gps":"ok"}',
      );

      await trackingRepository.saveGpsPoint(
        point: TrackingPointEntity(
          sessionId: session.id,
          timestampUtc: DateTime.utc(2026, 1, 2, 3, 4, 5),
          longitude: 30.1234,
          latitude: 59.9876,
          accuracyMeters: 4.5,
          speedMetersPerSecond: 3.2,
        ),
      );
      await trackingRepository.saveImuChunk(
        chunk: ImuChunkEntity(
          sessionId: session.id,
          capturedAtUtc: DateTime.utc(2026, 1, 2, 3, 4, 5),
          chunkStartMonotonicNs: 1234567890,
          sampleCount: 50,
          samplingHz: 50,
          payload: Uint8List.fromList(List<int>.generate(32, (index) => index)),
        ),
      );
      await syncRepository.enqueue(
        SyncJobEntity(
          id: 'sync-1',
          type: 'gps_point_upload',
          state: 'pending',
          createdAtUtc: DateTime.utc(2026, 1, 2, 3, 4, 6),
          availableAtUtc: DateTime.utc(2026, 1, 2, 3, 4, 6),
          sessionId: session.id,
          payloadJson: '{"session_id":${session.id}}',
        ),
      );
      await trackingRepository.transitionSessionState(
        sessionId: session.id,
        state: TrackingSessionState.completed,
        endedAtUtc: DateTime.utc(2026, 1, 2, 3, 5, 0),
      );

      await database.close();

      final reopenedDatabase = AppDatabase(executor: NativeDatabase(dbFile));
      final reopenedTrackingRepository = TrackingRepositoryImpl(
        reopenedDatabase,
      );
      final reopenedSyncRepository = SyncRepositoryImpl(reopenedDatabase);

      final restoredSession = await reopenedTrackingRepository
          .loadLatestUnfinishedSession();
      final restoredPoints = await reopenedTrackingRepository
          .loadGpsPointsForSession(session.id);
      final pendingJobs = await reopenedSyncRepository.getPendingJobs();

      expect(restoredSession, isNull);
      expect(restoredPoints, hasLength(1));
      expect(restoredPoints.single.sessionId, session.id);
      expect(restoredPoints.single.longitude, 30.1234);
      expect(pendingJobs, hasLength(1));
      expect(pendingJobs.single.id, 'sync-1');

      await reopenedDatabase.close();
      await tempDir.delete(recursive: true);
    },
  );

  test('restores latest unfinished tracking session after restart', () async {
    final tempDir = await Directory.systemTemp.createTemp('regatta-db-restore');
    final dbFile = File(p.join(tempDir.path, 'regatta_restore.sqlite'));

    final database = AppDatabase(executor: NativeDatabase(dbFile));
    final trackingRepository = TrackingRepositoryImpl(database);

    final session = await trackingRepository.createSession(
      raceId: 77,
      role: 'participant',
      intervalSeconds: 2,
    );
    await database.close();

    final reopenedDatabase = AppDatabase(executor: NativeDatabase(dbFile));
    final reopenedTrackingRepository = TrackingRepositoryImpl(reopenedDatabase);
    final restoredSession = await reopenedTrackingRepository
        .loadLatestUnfinishedSession();

    expect(restoredSession, isNotNull);
    expect(restoredSession?.id, session.id);
    expect(restoredSession?.raceId, 77);
    expect(restoredSession?.state, TrackingSessionState.preparing);

    await reopenedDatabase.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'persists judge local context and recent actions across reopen',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('judge-db-restore');
      final dbFile = File(p.join(tempDir.path, 'judge_restore.sqlite'));

      final database = AppDatabase(executor: NativeDatabase(dbFile));
      final judgeLocalRepository = JudgeLocalRepositoryImpl(database);
      final recordedAt = DateTime.utc(2026, 4, 29, 14, 15, 0);

      await judgeLocalRepository.saveContext(
        JudgeRaceContextEntity(
          lastRaceId: 501,
          status: JudgeRaceStatus.started,
          lastJudgeActionAtUtc: recordedAt,
        ),
      );
      await database.judgeActionDao.insertAction(
        JudgeActionEntity(
          eventId: 'race-started-1',
          raceId: 501,
          eventType: 'race_started',
          payloadJson: '{"backendMessage":"ok"}',
          createdAtUtc: DateTime.utc(2026, 4, 29, 14, 15, 0),
          syncStatus: 'pending',
        ),
      );
      await database.close();

      final reopenedDatabase = AppDatabase(executor: NativeDatabase(dbFile));
      final reopenedJudgeLocalRepository = JudgeLocalRepositoryImpl(
        reopenedDatabase,
      );

      final restoredContext = await reopenedJudgeLocalRepository.loadContext();
      final restoredActions = await reopenedJudgeLocalRepository
          .loadRecentActions();

      expect(restoredContext.lastRaceId, 501);
      expect(restoredContext.status, JudgeRaceStatus.started);
      expect(restoredContext.lastJudgeActionAtUtc, recordedAt);
      expect(restoredActions, hasLength(1));
      expect(restoredActions.single.raceId, 501);
      expect(restoredActions.single.eventType, 'race_started');

      await reopenedDatabase.close();
      await tempDir.delete(recursive: true);
    },
  );
}
