import 'dart:convert';

import '../../../core/network/api_exception.dart';
import '../../local_storage/database/app_database.dart';
import '../../management/data/management_remote_data_source.dart';
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
    ManagementRemoteDataSource? managementRemoteDataSource,
    RaceComputerService raceComputerService = const RaceComputerService(),
    GeoMath geoMath = const GeoMath(),
  }) : _appDatabase = appDatabase,
       _trackingRepository = trackingRepository,
       _managementRemoteDataSource = managementRemoteDataSource,
       _raceComputerService = raceComputerService,
       _geoMath = geoMath;

  final AppDatabase _appDatabase;
  final TrackingRepository _trackingRepository;
  final ManagementRemoteDataSource? _managementRemoteDataSource;
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
          roundingSide: MarkRoundingSide.port,
        ),
      ],
      finishLine: StartLineEntity(
        committeeBoat: _geoMath.offsetPoint(
          origin: origin,
          bearingDegrees: 180,
          distanceMeters: 40,
        ),
        pinEnd: _geoMath.offsetPoint(
          origin: origin,
          bearingDegrees: 180,
          distanceMeters: 70,
        ),
        name: 'Reference finish line',
      ),
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
      return syncCourseFromRemote(raceId: raceId);
    }
    return CourseEntity.fromJson(
      jsonDecode(row.payloadJson) as Map<String, Object?>,
    );
  }

  @override
  Future<void> saveCourse(
    CourseEntity course, {
    bool publishRemote = false,
  }) async {
    await _saveCourseLocal(course);
    if (!publishRemote) {
      return;
    }
    final remote = _managementRemoteDataSource;
    if (remote == null) {
      return;
    }
    final response = await remote.upsertRaceCourse(
      raceId: course.raceId,
      payload: _toApiCoursePayload(course),
    );
    final remoteCourse = _fromApiCoursePayload(
      raceId: response.raceId,
      updatedAt: response.updatedAt,
      payload: response.payload,
    );
    await _saveCourseLocal(remoteCourse);
  }

  @override
  Future<CourseEntity?> syncCourseFromRemote({required int raceId}) async {
    final remote = _managementRemoteDataSource;
    if (remote == null) {
      return null;
    }
    try {
      final response = await remote.getRaceCourse(raceId: raceId);
      final course = _fromApiCoursePayload(
        raceId: response.raceId,
        updatedAt: response.updatedAt,
        payload: response.payload,
      );
      await _saveCourseLocal(course);
      return course;
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> _saveCourseLocal(CourseEntity course) {
    return _appDatabase.courseDefinitionDao.upsertCourseDefinition(
      raceId: course.raceId,
      name: course.name,
      payloadJson: jsonEncode(course.toJson()),
      updatedAtUtc: course.updatedAtUtc,
      version: course.version,
    );
  }

  Map<String, Object?> _toApiCoursePayload(CourseEntity course) {
    return <String, Object?>{
      'version': course.version,
      'start_line': <String, Object?>{
        'p1': _toApiPoint(course.startLine.committeeBoat),
        'p2': _toApiPoint(course.startLine.pinEnd),
      },
      'marks': course.marks
          .map(
            (mark) => <String, Object?>{
              'id': mark.id,
              'point': _toApiPoint(mark.position),
              'rounding_side': mark.roundingSide.name,
            },
          )
          .toList(growable: false),
      'finish_line': <String, Object?>{
        'p1': _toApiPoint(course.finishLine.committeeBoat),
        'p2': _toApiPoint(course.finishLine.pinEnd),
      },
    };
  }

  CourseEntity _fromApiCoursePayload({
    required int raceId,
    required String updatedAt,
    required Map<String, Object?> payload,
  }) {
    final startLine = payload['start_line'] as Map<String, Object?>;
    final finishLine = payload['finish_line'] as Map<String, Object?>;
    final marksJson = (payload['marks'] as List<Object?>?) ?? const <Object?>[];
    return CourseEntity(
      raceId: raceId,
      name: 'Race $raceId course',
      startLine: StartLineEntity(
        committeeBoat: _fromApiPoint(startLine['p1']! as Map<String, Object?>),
        pinEnd: _fromApiPoint(startLine['p2']! as Map<String, Object?>),
      ),
      marks: marksJson.asMap().entries.map((entry) {
        final json = entry.value! as Map<String, Object?>;
        final sideRaw = json['rounding_side'] as String? ?? 'port';
        return MarkEntity(
          id: json['id'] as String,
          name: 'Mark ${entry.key + 1}',
          position: _fromApiPoint(json['point']! as Map<String, Object?>),
          order: entry.key + 1,
          roundingSide: sideRaw == 'starboard'
              ? MarkRoundingSide.starboard
              : MarkRoundingSide.port,
        );
      }).toList(growable: false),
      finishLine: StartLineEntity(
        committeeBoat: _fromApiPoint(
          finishLine['p1']! as Map<String, Object?>,
        ),
        pinEnd: _fromApiPoint(finishLine['p2']! as Map<String, Object?>),
        name: 'Finish line',
      ),
      updatedAtUtc: DateTime.parse(updatedAt).toUtc(),
      version: (payload['version'] as num?)?.toInt() ?? 1,
      source: 'remote_management',
    );
  }

  Map<String, Object?> _toApiPoint(GeoPointEntity point) => <String, Object?>{
    'longitude': point.longitude,
    'latitude': point.latitude,
  };

  GeoPointEntity _fromApiPoint(Map<String, Object?> json) {
    return GeoPointEntity(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
