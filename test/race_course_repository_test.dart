import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/network/api_exception.dart';
import 'package:vkr_regatta/src/features/api/models/api_models.dart';
import 'package:vkr_regatta/src/features/local_storage/database/app_database.dart';
import 'package:vkr_regatta/src/features/management/data/management_remote_data_source.dart';
import 'package:vkr_regatta/src/features/race_computer/data/race_computer_repository_impl.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/course_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/geo_point_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/mark_entity.dart';
import 'package:vkr_regatta/src/features/race_computer/domain/start_line_entity.dart';
import 'package:vkr_regatta/src/features/tracking/data/tracking_repository_impl.dart';

void main() {
  test('CourseEntity roundtrips start line and marks JSON', () {
    final course = _course(701);

    final restored = CourseEntity.fromJson(
      jsonDecode(jsonEncode(course.toJson())) as Map<String, Object?>,
    );

    expect(restored.raceId, 701);
    expect(restored.startLine.committeeBoat.latitude, 60);
    expect(restored.startLine.pinEnd.longitude, 30.001);
    expect(restored.marks.single.name, 'Windward');
  });

  test('repository saves course locally', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    final repository = RaceComputerRepositoryImpl(
      appDatabase: database,
      trackingRepository: TrackingRepositoryImpl(database),
    );

    await repository.saveCourse(_course(702));
    final restored = await repository.loadCourse(raceId: 702);

    expect(restored, isNotNull);
    expect(restored!.name, 'Test course');
    await database.close();
  });

  test(
    'repository loads missing local course from remote and caches it',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      final remote = _FakeManagementRemoteDataSource(course: _course(703));
      final repository = RaceComputerRepositoryImpl(
        appDatabase: database,
        trackingRepository: TrackingRepositoryImpl(database),
        managementRemoteDataSource: remote,
      );

      final restored = await repository.loadCourse(raceId: 703);
      final cached = await database.courseDefinitionDao.loadCourseDefinition(
        703,
      );

      expect(restored, isNotNull);
      expect(restored!.raceId, 703);
      expect(cached, isNotNull);
      await database.close();
    },
  );

  test('repository treats remote 404 course as not configured', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    final repository = RaceComputerRepositoryImpl(
      appDatabase: database,
      trackingRepository: TrackingRepositoryImpl(database),
      managementRemoteDataSource: _FakeManagementRemoteDataSource(),
    );

    final restored = await repository.loadCourse(raceId: 704);

    expect(restored, isNull);
    await database.close();
  });
}

CourseEntity _course(int raceId) {
  return CourseEntity(
    raceId: raceId,
    name: 'Test course',
    startLine: const StartLineEntity(
      committeeBoat: GeoPointEntity(latitude: 60, longitude: 30),
      pinEnd: GeoPointEntity(latitude: 60, longitude: 30.001),
    ),
    marks: const <MarkEntity>[
      MarkEntity(
        id: 'windward',
        name: 'Windward',
        position: GeoPointEntity(latitude: 60.002, longitude: 30.0005),
        order: 1,
        roundingSide: MarkRoundingSide.port,
      ),
    ],
    finishLine: const StartLineEntity(
      committeeBoat: GeoPointEntity(latitude: 60.003, longitude: 30.0002),
      pinEnd: GeoPointEntity(latitude: 60.003, longitude: 30.0012),
    ),
    updatedAtUtc: DateTime.utc(2026, 5, 26, 12),
    source: 'test',
  );
}

class _FakeManagementRemoteDataSource extends ManagementRemoteDataSource {
  _FakeManagementRemoteDataSource({this.course}) : super(managementApi: null);

  final CourseEntity? course;

  @override
  Future<RaceCourseResponseDto> getRaceCourse({required int raceId}) async {
    final course = this.course;
    if (course == null) {
      throw ApiException(statusCode: 404, message: 'course not found');
    }
    return RaceCourseResponseDto(
      raceId: raceId,
      updatedAt: course.updatedAtUtc.toIso8601String(),
      payload: <String, Object?>{
        'version': 1,
        'start_line': <String, Object?>{
          'p1': <String, Object?>{'longitude': 30.0, 'latitude': 60.0},
          'p2': <String, Object?>{'longitude': 30.001, 'latitude': 60.0},
        },
        'marks': <Object?>[
          <String, Object?>{
            'id': 'windward',
            'point': <String, Object?>{
              'longitude': 30.0005,
              'latitude': 60.002,
            },
            'rounding_side': 'port',
          },
        ],
        'finish_line': <String, Object?>{
          'p1': <String, Object?>{'longitude': 30.0002, 'latitude': 60.003},
          'p2': <String, Object?>{'longitude': 30.0012, 'latitude': 60.003},
        },
      },
    );
  }

  @override
  Future<RaceCourseResponseDto> upsertRaceCourse({
    required int raceId,
    required Map<String, Object?> payload,
  }) async {
    return RaceCourseResponseDto(
      raceId: raceId,
      updatedAt: DateTime.utc(2026, 5, 26, 12).toIso8601String(),
      payload: payload,
    );
  }
}
