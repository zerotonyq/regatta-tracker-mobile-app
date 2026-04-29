import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../judge/domain/judge_action_entity.dart';
import '../../tracking/domain/derived_metric_entity.dart';
import '../../sync/domain/sync_job_entity.dart';
import '../../tracking/domain/imu_chunk_entity.dart';
import '../../tracking/domain/tracking_point_entity.dart';
import '../../tracking/domain/tracking_session_entity.dart';

part 'app_database.g.dart';
part '../dao/imu_chunk_dao.dart';
part '../dao/app_settings_dao.dart';
part '../dao/course_definition_dao.dart';
part '../dao/derived_metric_dao.dart';
part '../dao/judge_action_dao.dart';
part '../dao/sync_queue_dao.dart';
part '../dao/tracking_point_dao.dart';
part '../dao/tracking_session_dao.dart';

class TrackingSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get raceId => integer()();
  TextColumn get role => text()();
  TextColumn get state => text()();
  IntColumn get intervalSeconds => integer()();
  DateTimeColumn get startedAtUtc => dateTime()();
  DateTimeColumn get endedAtUtc => dateTime().nullable()();
  TextColumn get failureReason => text().nullable()();
  DateTimeColumn get lastSyncAtUtc => dateTime().nullable()();
  TextColumn get sensorHealthSnapshot => text().nullable()();
}

class GpsPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(TrackingSessions, #id)();
  DateTimeColumn get timestampUtc => dateTime()();
  RealColumn get longitude => real()();
  RealColumn get latitude => real()();
  RealColumn get accuracyMeters => real().nullable()();
  RealColumn get speedMetersPerSecond => real().nullable()();
}

class ImuChunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(TrackingSessions, #id)();
  DateTimeColumn get capturedAtUtc => dateTime()();
  IntColumn get chunkStartMonotonicNs => integer()();
  IntColumn get sampleCount => integer()();
  IntColumn get samplingHz => integer()();
  TextColumn get payloadFormat =>
      text().withDefault(const Constant('imu-int16-le-v1'))();
  BlobColumn get payload => blob()();
}

class DerivedMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(TrackingSessions, #id)();
  DateTimeColumn get timestampUtc => dateTime()();
  TextColumn get metricType => text()();
  RealColumn get metricValue => real()();
  TextColumn get unit => text().nullable()();
}

class SyncQueue extends Table {
  TextColumn get id => text()();
  IntColumn get sessionId =>
      integer().nullable().references(TrackingSessions, #id)();
  TextColumn get jobType => text()();
  TextColumn get state => text()();
  TextColumn get payloadJson => text().nullable()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get availableAtUtc => dateTime()();
  TextColumn get lastError => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(100))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class JudgeActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().nullable().references(TrackingSessions, #id)();
  IntColumn get raceId => integer().nullable()();
  TextColumn get actionType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();
}

class CourseDefinitions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get raceId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
}

class ExportJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().nullable().references(TrackingSessions, #id)();
  TextColumn get format => text()();
  TextColumn get state => text()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();
  TextColumn get filePath => text().nullable()();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get diagnosticsTag => text().nullable()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    TrackingSessions,
    GpsPoints,
    ImuChunks,
    DerivedMetrics,
    SyncQueue,
    JudgeActions,
    CourseDefinitions,
    ExportJobs,
    AppSettings,
  ],
  daos: [
    TrackingSessionDao,
    TrackingPointDao,
    ImuChunkDao,
    DerivedMetricDao,
    CourseDefinitionDao,
    SyncQueueDao,
    JudgeActionDao,
    AppSettingsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(exportJobs, exportJobs.diagnosticsTag);
      }
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('PRAGMA journal_mode = WAL;');
      await customStatement('PRAGMA synchronous = NORMAL;');
      await customStatement('PRAGMA temp_store = MEMORY;');
      await customStatement('PRAGMA cache_size = -20000;');
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS gps_points_session_timestamp_idx '
      'ON gps_points(session_id, timestamp_utc);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS imu_chunks_session_captured_idx '
      'ON imu_chunks(session_id, captured_at_utc);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS derived_metrics_session_timestamp_idx '
      'ON derived_metrics(session_id, timestamp_utc);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS sync_queue_state_available_priority_idx '
      'ON sync_queue(state, available_at_utc, priority);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS tracking_sessions_state_started_idx '
      'ON tracking_sessions(state, started_at_utc);',
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationSupportDirectory();
    final file = File(p.join(directory.path, 'regatta_local.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}

TrackingSessionState trackingSessionStateFromDb(String value) {
  if (value == 'active') {
    return TrackingSessionState.tracking;
  }

  return TrackingSessionState.values.firstWhere(
    (candidate) => candidate.name == value,
    orElse: () => TrackingSessionState.idle,
  );
}
