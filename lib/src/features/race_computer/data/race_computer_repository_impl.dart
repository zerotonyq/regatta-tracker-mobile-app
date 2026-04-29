import 'dart:convert';

import '../../local_storage/database/app_database.dart';
import '../../tracking/domain/tracking_repository.dart';
import '../../tracking/domain/tracking_session_entity.dart';
import '../application/geo_math.dart';
import '../application/race_computer_service.dart';
import '../domain/course_entity.dart';
import '../domain/geo_point_entity.dart';
import '../domain/mark_entity.dart';
import '../domain/race_computer_repository.dart';
import '../domain/race_state_entity.dart';
import '../domain/start_line_entity.dart';

class RaceComputerRepositoryImpl implements RaceComputerRepository {
  RaceComputerRepositoryImpl({
    required AppDatabase appDatabase,
    required TrackingRepository trackingRepository,
    RaceComputerService raceComputerService = const RaceComputerService(),
    GeoMath geoMath = const GeoMath(),
  }) : _appDatabase = appDatabase,
       _trackingRepository = trackingRepository,
       _raceComputerService = raceComputerService,
       _geoMath = geoMath;

  final AppDatabase _appDatabase;
  final TrackingRepository _trackingRepository;
  final RaceComputerService _raceComputerService;
  final GeoMath _geoMath;

  @override
  Future<void> createReferenceCourse({
    required int sessionId,
    required int raceId,
  }) async {
    final latestPoint = await _trackingRepository.loadLatestGpsPointForSession(
      sessionId,
    );
    if (latestPoint == null) {
      throw StateError('Cannot create a reference course without GPS data.');
    }

    final origin = GeoPointEntity(
      latitude: latestPoint.latitude,
      longitude: latestPoint.longitude,
    );
    final committeeBoat = _geoMath.offsetPoint(
      origin: origin,
      bearingDegrees: 270,
      distanceMeters: 30,
    );
    final pinEnd = _geoMath.offsetPoint(
      origin: origin,
      bearingDegrees: 90,
      distanceMeters: 30,
    );
    final windwardMark = _geoMath.offsetPoint(
      origin: origin,
      bearingDegrees: 0,
      distanceMeters: 250,
    );

    final course = CourseEntity(
      raceId: raceId,
      name: 'Local reference course',
      startLine: StartLineEntity(
        committeeBoat: committeeBoat,
        pinEnd: pinEnd,
        name: 'Reference start line',
      ),
      marks: <MarkEntity>[
        MarkEntity(
          id: 'windward_mark',
          name: 'Windward mark',
          position: windwardMark,
          order: 1,
        ),
      ],
      updatedAtUtc: DateTime.now().toUtc(),
      source: 'local_reference',
    );

    await _appDatabase.courseDefinitionDao.upsertCourseDefinition(
      raceId: raceId,
      name: course.name,
      payloadJson: jsonEncode(course.toJson()),
      updatedAtUtc: course.updatedAtUtc,
      version: course.version,
    );
  }

  @override
  Future<RaceStateEntity> loadCurrentState({
    required int sessionId,
    required int raceId,
  }) async {
    final session = await _trackingRepository.loadSessionById(sessionId);
    final currentPoint = await _trackingRepository.loadLatestGpsPointForSession(
      sessionId,
    );
    final recentPoints = await _trackingRepository
        .loadRecentGpsPointsForSession(sessionId, limit: 2);
    final derivedMetrics = await _trackingRepository
        .loadDerivedMetricsForSession(sessionId, limit: 40);
    final course = await loadCourse(raceId: raceId);
    final judgeActions = await _appDatabase.judgeActionDao.loadActionsForRace(
      raceId: raceId,
      limit: 50,
    );

    return _raceComputerService.evaluate(
      raceId: raceId,
      currentPoint: currentPoint,
      previousPoint: recentPoints.length > 1 ? recentPoints[1] : null,
      course: course,
      latestMetrics: derivedMetrics,
      judgeActions: judgeActions,
      nowUtc: DateTime.now().toUtc(),
      trackingState: session?.state ?? TrackingSessionState.idle,
    );
  }

  @override
  Future<CourseEntity?> loadCourse({required int raceId}) async {
    final row = await _appDatabase.courseDefinitionDao.loadCourseDefinition(
      raceId,
    );
    if (row == null) {
      return null;
    }
    return CourseEntity.fromJson(
      jsonDecode(row.payloadJson) as Map<String, Object?>,
    );
  }
}
