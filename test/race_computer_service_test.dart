import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/features/local_storage/database/app_database.dart';
import 'package:vkr_regatta/src/features/judge/domain/judge_action_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/data/race_computer_repository_impl.dart';
import 'package:vkr_regatta/src/features/tracking/data/tracking_repository_impl.dart';
import 'package:vkr_regatta/src/features/tracking/domain/derived_metric_entity.dart';
import 'package:vkr_regatta/src/features/tracking/domain/tracking_point_entity.dart';

void main() {
  test(
    'race computer creates local reference course and evaluates geometry',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      final trackingRepository = TrackingRepositoryImpl(database);
      final raceComputerRepository = RaceComputerRepositoryImpl(
        appDatabase: database,
        trackingRepository: trackingRepository,
      );
      final session = await trackingRepository.createSession(
        raceId: 701,
        role: 'participant',
        intervalSeconds: 1,
      );

      await trackingRepository.saveGpsPoint(
        point: TrackingPointEntity(
          sessionId: session.id,
          timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 0),
          longitude: 30.0,
          latitude: 60.0,
          speedMetersPerSecond: 3.8,
        ),
      );
      await trackingRepository.saveGpsPoint(
        point: TrackingPointEntity(
          sessionId: session.id,
          timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 5),
          longitude: 30.0003,
          latitude: 60.0004,
          speedMetersPerSecond: 4.2,
        ),
      );
      await trackingRepository.saveDerivedMetrics(<DerivedMetricEntity>[
        DerivedMetricEntity(
          sessionId: session.id,
          timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 5),
          metricType: 'heading_deg',
          metricValue: 18,
          unit: 'deg',
        ),
        DerivedMetricEntity(
          sessionId: session.id,
          timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 5),
          metricType: 'heel_deg',
          metricValue: 7,
          unit: 'deg',
        ),
        DerivedMetricEntity(
          sessionId: session.id,
          timestampUtc: DateTime.utc(2026, 4, 29, 18, 0, 5),
          metricType: 'quality_heading_validated_by_gps',
          metricValue: 1,
          unit: 'bool',
        ),
      ]);

      await raceComputerRepository.createReferenceCourse(
        sessionId: session.id,
        raceId: 701,
      );
      final state = await raceComputerRepository.loadCurrentState(
        sessionId: session.id,
        raceId: 701,
      );

      expect(state.phase, anyOf('prestart_geometry', 'racing'));
      expect(state.course, isNotNull);
      expect(state.startLine, isNotNull);
      expect(state.nextMark, isNotNull);
      expect(state.windEstimate, isNotNull);
      expect(state.laylineHint, isNotNull);
      expect(state.confidence, greaterThan(0.4));

      await database.close();
    },
  );

  test(
    'race computer links judge countdown and recommends prestart profile',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      final trackingRepository = TrackingRepositoryImpl(database);
      final raceComputerRepository = RaceComputerRepositoryImpl(
        appDatabase: database,
        trackingRepository: trackingRepository,
      );
      final session = await trackingRepository.createSession(
        raceId: 702,
        role: 'participant',
        intervalSeconds: 1,
      );

      await trackingRepository.saveGpsPoint(
        point: TrackingPointEntity(
          sessionId: session.id,
          timestampUtc: DateTime.now().toUtc(),
          longitude: 30.001,
          latitude: 60.001,
          speedMetersPerSecond: 3.0,
        ),
      );
      await database.judgeActionDao.insertAction(
        JudgeActionEntity(
          eventId: 'configured-1',
          raceId: 702,
          eventType: 'start_procedure_configured',
          payloadJson: jsonEncode(<String, Object>{
            'durationSeconds': 300,
            'startAtUtc': DateTime.now()
                .toUtc()
                .add(const Duration(minutes: 4, seconds: 30))
                .toIso8601String(),
          }),
          createdAtUtc: DateTime.now().toUtc(),
          syncStatus: 'pending',
        ),
      );

      final state = await raceComputerRepository.loadCurrentState(
        sessionId: session.id,
        raceId: 702,
      );

      expect(state.startProcedure, isNotNull);
      expect(state.phase, 'prestart_countdown');
      expect(state.recommendedTrackingProfile.name, 'prestartPrecision');
      expect(state.startProcedure!.remainingSeconds, greaterThan(200));

      await database.close();
    },
  );
}
