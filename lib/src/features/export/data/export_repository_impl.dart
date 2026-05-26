import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' as drift;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/config/app_config.dart';
import '../../local_storage/database/app_database.dart';
import '../../sensor_bridge/domain/sensor_bridge_repository.dart';
import '../../tracking/domain/tracking_health.dart';
import '../../tracking/domain/derived_metric_entity.dart';
import '../../tracking/domain/imu_chunk_entity.dart';
import '../../tracking/domain/tracking_point_entity.dart';
import '../../tracking/domain/tracking_session_entity.dart';
import '../domain/diagnostics_snapshot_entity.dart';
import '../domain/export_format.dart';
import '../domain/export_payload_entity.dart';
import '../domain/export_repository.dart';
import '../domain/session_summary_entity.dart';

class ExportRepositoryImpl implements ExportRepository {
  ExportRepositoryImpl({
    required AppDatabase appDatabase,
    required SensorBridgeRepository sensorBridgeRepository,
    required AppConfig config,
    Directory? exportRootDirectory,
  }) : _appDatabase = appDatabase,
       _sensorBridgeRepository = sensorBridgeRepository,
       _config = config,
       _exportRootDirectory = exportRootDirectory;

  final AppDatabase _appDatabase;
  final SensorBridgeRepository _sensorBridgeRepository;
  final AppConfig _config;
  final Directory? _exportRootDirectory;

  @override
  Future<List<SessionSummaryEntity>> loadCompletedSessions() async {
    final sessions = await _appDatabase.trackingSessionDao
        .loadCompletedSessions();
    final summaries = <SessionSummaryEntity>[];
    for (final session in sessions) {
      summaries.add(await _buildSessionSummary(session));
    }
    return summaries;
  }

  @override
  Future<SessionSummaryEntity?> loadSessionSummary(int sessionId) async {
    final session = await _appDatabase.trackingSessionDao.loadSessionById(
      sessionId,
    );
    if (session == null) {
      return null;
    }
    return _buildSessionSummary(session);
  }

  @override
  Future<DiagnosticsSnapshotEntity> buildDiagnostics({int? sessionId}) async {
    final session = sessionId == null
        ? null
        : await _appDatabase.trackingSessionDao.loadSessionById(sessionId);
    final summary = session == null
        ? null
        : await _buildSessionSummary(session);
    final health = await _sensorBridgeRepository.readTrackingHealth(
      sessionId: sessionId?.toString(),
    );
    return _buildDiagnosticsSnapshot(
      summary: summary,
      health: health,
      session: session,
    );
  }

  @override
  Future<ExportPayloadEntity> buildExport({
    required int sessionId,
    required ExportFormat format,
  }) async {
    final session = await _appDatabase.trackingSessionDao.loadSessionById(
      sessionId,
    );
    if (session == null) {
      throw StateError('Session $sessionId was not found.');
    }
    final summary = await _buildSessionSummary(session);
    final diagnostics = await buildDiagnostics(sessionId: sessionId);
    final gpsPoints = await _appDatabase.trackingPointDao.loadPointsForSession(
      sessionId,
    );

    final createdAtUtc = DateTime.now().toUtc();
    final diagnosticsTag =
        'diag-$sessionId-${createdAtUtc.microsecondsSinceEpoch}';
    final jobId = await _appDatabase
        .into(_appDatabase.exportJobs)
        .insert(
          ExportJobsCompanion.insert(
            sessionId: drift.Value(sessionId),
            format: format.name,
            state: 'pending',
            createdAtUtc: createdAtUtc,
            diagnosticsTag: drift.Value(diagnosticsTag),
          ),
        );

    try {
      await (_appDatabase.update(_appDatabase.exportJobs)
            ..where((tbl) => tbl.id.equals(jobId)))
          .write(const ExportJobsCompanion(state: drift.Value('in_progress')));

      final bytes = await _buildBytes(
        summary: summary,
        diagnostics: diagnostics,
        gpsPoints: gpsPoints,
        format: format,
      );
      final directory = await _resolveExportDirectory();
      final fileName = _buildFileName(
        sessionId: sessionId,
        format: format,
        createdAtUtc: createdAtUtc,
      );
      final filePath = p.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      final completedAtUtc = DateTime.now().toUtc();

      await (_appDatabase.update(
        _appDatabase.exportJobs,
      )..where((tbl) => tbl.id.equals(jobId))).write(
        ExportJobsCompanion(
          state: const drift.Value('completed'),
          completedAtUtc: drift.Value(completedAtUtc),
          filePath: drift.Value(filePath),
          diagnosticsTag: drift.Value(diagnosticsTag),
        ),
      );

      return ExportPayloadEntity(
        fileName: fileName,
        bytes: bytes,
        filePath: filePath,
        format: format,
        sessionId: sessionId,
        jobState: 'completed',
        diagnosticsTag: diagnosticsTag,
      );
    } catch (error) {
      await (_appDatabase.update(
        _appDatabase.exportJobs,
      )..where((tbl) => tbl.id.equals(jobId))).write(
        ExportJobsCompanion(
          state: const drift.Value('failed'),
          completedAtUtc: drift.Value(DateTime.now().toUtc()),
          errorMessage: drift.Value(error.toString()),
          diagnosticsTag: drift.Value(diagnosticsTag),
        ),
      );
      rethrow;
    }
  }

  Future<SessionSummaryEntity> _buildSessionSummary(
    TrackingSessionEntity session,
  ) async {
    final gpsPointCount = await _appDatabase.trackingPointDao
        .countPointsForSession(session.id);
    final imuSummary = await _appDatabase.imuChunkDao.summarizeForSession(
      session.id,
    );
    final gpsPoints = await _appDatabase.trackingPointDao.loadPointsForSession(
      session.id,
    );
    final derivedMetrics = await _appDatabase.derivedMetricDao
        .loadMetricsForSession(session.id);
    final syncJobs = await _appDatabase.syncQueueDao.getJobsForSession(
      session.id,
    );
    final exportRow = await _loadLatestExportJob(session.id);
    final endedAtUtc = session.endedAtUtc ?? gpsPoints.lastOrNull?.timestampUtc;
    final duration = endedAtUtc == null
        ? Duration.zero
        : endedAtUtc.difference(session.startedAtUtc);
    final speedSamples = gpsPoints
        .where((point) => point.speedMetersPerSecond != null)
        .map((point) => point.speedMetersPerSecond!)
        .toList(growable: false);
    final double averageSpeedMetersPerSecond = speedSamples.isEmpty
        ? 0
        : speedSamples.fold<double>(0, (sum, value) => sum + value) /
              speedSamples.length;
    final derivedMetricSummary = <String, double>{};
    for (final metricType in <String>[
      'heading_deg',
      'heel_deg',
      'turn_rate_deg_s',
      'roll_deg',
      'pitch_deg',
    ]) {
      final metric = derivedMetrics.where(
        (item) => item.metricType == metricType,
      );
      if (metric.isNotEmpty) {
        derivedMetricSummary[metricType] = metric.first.metricValue;
      }
    }
    final droppedSampleCount = _parseHealthSnapshotValue(
      session.sensorHealthSnapshot,
      'dropped',
    );
    final pendingSync = syncJobs.any((job) {
      return job.state == 'pending' ||
          job.state == 'in_progress' ||
          job.state == 'failed_retryable';
    });
    final failedSync = syncJobs.any((job) => job.state == 'failed_terminal');
    final syncState = failedSync
        ? 'failed_terminal'
        : pendingSync
        ? 'pending'
        : 'synced';

    return SessionSummaryEntity(
      sessionId: session.id,
      raceId: session.raceId,
      role: session.role,
      state: session.state.name,
      startedAtUtc: session.startedAtUtc,
      endedAtUtc: endedAtUtc,
      duration: duration.isNegative ? Duration.zero : duration,
      gpsPointCount: gpsPointCount,
      imuChunkCount: imuSummary.$1,
      imuSampleCount: imuSummary.$2,
      syncState: syncState,
      averageSpeedMetersPerSecond: averageSpeedMetersPerSecond.isFinite
          ? averageSpeedMetersPerSecond
          : 0.0,
      derivedMetricSummary: derivedMetricSummary,
      droppedSampleCount: droppedSampleCount,
      hasErrors:
          session.failureReason != null || failedSync || droppedSampleCount > 0,
      failureReason: session.failureReason,
      sensorHealthSnapshot: session.sensorHealthSnapshot,
      lastExportPath: exportRow?.filePath,
      lastExportState: exportRow?.state,
      lastExportedAtUtc: exportRow?.completedAtUtc,
    );
  }

  Future<ExportJob?> _loadLatestExportJob(int sessionId) {
    return (_appDatabase.select(_appDatabase.exportJobs)
          ..where((tbl) => tbl.sessionId.equals(sessionId))
          ..orderBy([
            (tbl) => drift.OrderingTerm(
              expression: tbl.createdAtUtc,
              mode: drift.OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  DiagnosticsSnapshotEntity _buildDiagnosticsSnapshot({
    required SessionSummaryEntity? summary,
    required TrackingHealth health,
    required TrackingSessionEntity? session,
  }) {
    final nowUtc = DateTime.now().toUtc();
    final durationSeconds = summary?.duration.inSeconds ?? 0;
    final averageGpsRateHz = durationSeconds <= 0
        ? 0.0
        : summary!.gpsPointCount / durationSeconds.toDouble();
    final averageImuRateHz = durationSeconds <= 0
        ? 0.0
        : summary!.imuSampleCount / durationSeconds.toDouble();
    final syncLagSeconds = session?.lastSyncAtUtc == null
        ? 0
        : nowUtc.difference(session!.lastSyncAtUtc!).inSeconds;
    final batteryMarkers = <String>[
      if ((summary?.imuSampleCount ?? 0) > 10_000) 'high_imu_volume',
      if ((summary?.gpsPointCount ?? 0) > 1_000) 'high_gps_volume',
      if ((summary?.droppedSampleCount ?? 0) > 0) 'dropped_samples_present',
      if (health.backgroundServiceRunning) 'background_service_active',
    ];

    return DiagnosticsSnapshotEntity(
      generatedAtUtc: nowUtc,
      appVersion: _config.userAgent,
      databaseSchemaVersion: _appDatabase.schemaVersion,
      locationPermission: health.locationPermission.name,
      motionPermission: health.motionPermission.name,
      gpsEnabled: health.gpsEnabled,
      imuEnabled: health.imuEnabled,
      backgroundServiceRunning: health.backgroundServiceRunning,
      averageGpsRateHz: averageGpsRateHz,
      averageImuRateHz: averageImuRateHz,
      droppedSamples: summary?.droppedSampleCount ?? health.droppedSampleCount,
      syncLagSeconds: syncLagSeconds < 0 ? 0 : syncLagSeconds,
      pendingSyncJobs: health.pendingSyncCount,
      batteryImpactMarkers: batteryMarkers,
      sensorHealthSnapshot:
          summary?.sensorHealthSnapshot ?? session?.sensorHealthSnapshot ?? '',
      sessionId: session?.id,
    );
  }

  Future<List<int>> _buildBytes({
    required SessionSummaryEntity summary,
    required DiagnosticsSnapshotEntity diagnostics,
    required List<TrackingPointEntity> gpsPoints,
    required ExportFormat format,
  }) async {
    final summaryJson = _summaryJson(summary);
    final diagnosticsJson = _diagnosticsJson(diagnostics);
    final csv = _buildCsv(summary: summary, gpsPoints: gpsPoints);
    final gpx = _buildGpx(gpsPoints);
    final geoJson = _buildGeoJson(gpsPoints);
    final derivedMetrics = await _appDatabase.derivedMetricDao
        .loadMetricsForSession(summary.sessionId);
    final imuChunks = await _appDatabase.imuChunkDao.loadChunksForSession(
      summary.sessionId,
    );
    final derivedMetricsCsv = _buildDerivedMetricsCsv(derivedMetrics);
    final derivedMetricsJson = _buildDerivedMetricsJson(derivedMetrics);
    final manifestJson = _buildManifestJson(
      summary: summary,
      diagnostics: diagnostics,
      imuChunks: imuChunks,
      derivedMetrics: derivedMetrics,
    );

    return switch (format) {
      ExportFormat.csv => utf8.encode(csv),
      ExportFormat.gpx => utf8.encode(gpx),
      ExportFormat.geoJson => utf8.encode(geoJson),
      ExportFormat.diagnosticsJson => utf8.encode(diagnosticsJson),
      ExportFormat.zipBundle => _buildZipBundle(
        manifestJson: manifestJson,
        summaryJson: summaryJson,
        diagnosticsJson: diagnosticsJson,
        csv: csv,
        gpx: gpx,
        geoJson: geoJson,
        derivedMetricsCsv: derivedMetricsCsv,
        derivedMetricsJson: derivedMetricsJson,
        imuChunks: imuChunks,
      ),
    };
  }

  List<int> _buildZipBundle({
    required String manifestJson,
    required String summaryJson,
    required String diagnosticsJson,
    required String csv,
    required String gpx,
    required String geoJson,
    required String derivedMetricsCsv,
    required String derivedMetricsJson,
    required List<ImuChunkEntity> imuChunks,
  }) {
    final archive = Archive()
      ..addFile(ArchiveFile.string('manifest.json', manifestJson))
      ..addFile(ArchiveFile.string('session_summary.json', summaryJson))
      ..addFile(ArchiveFile.string('gps.csv', csv))
      ..addFile(ArchiveFile.string('track.gpx', gpx))
      ..addFile(ArchiveFile.string('track.geojson', geoJson))
      ..addFile(ArchiveFile.string('derived_metrics.csv', derivedMetricsCsv))
      ..addFile(ArchiveFile.string('derived_metrics.json', derivedMetricsJson))
      ..addFile(ArchiveFile.string('diagnostics.json', diagnosticsJson));
    for (final chunk in imuChunks) {
      archive.addFile(
        ArchiveFile(
          _imuChunkFileName(chunk),
          chunk.payload.length,
          chunk.payload,
        ),
      );
    }
    return ZipEncoder().encode(archive);
  }

  String _buildManifestJson({
    required SessionSummaryEntity summary,
    required DiagnosticsSnapshotEntity diagnostics,
    required List<ImuChunkEntity> imuChunks,
    required List<DerivedMetricEntity> derivedMetrics,
  }) {
    final payloadFormats =
        imuChunks
            .map((chunk) => chunk.payloadFormat)
            .toSet()
            .toList(growable: false)
          ..sort();
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'schema': 'vkr-regatta-export-bundle-v1',
      'sessionId': summary.sessionId,
      'raceId': summary.raceId,
      'generatedAtUtc': diagnostics.generatedAtUtc.toIso8601String(),
      'targetGpsHz': 1.0,
      'targetImuHz': 50.0,
      'averageGpsRateHz': diagnostics.averageGpsRateHz,
      'averageImuRateHz': diagnostics.averageImuRateHz,
      'gpsPointCount': summary.gpsPointCount,
      'imuChunkCount': imuChunks.length,
      'imuEventCount': summary.imuSampleCount,
      'imuPayloadFormats': payloadFormats,
      'derivedMetricCount': derivedMetrics.length,
      'diagnosticsTag': diagnostics.sessionId == null
          ? null
          : 'session-${diagnostics.sessionId}',
      'files': <String>[
        'session_summary.json',
        'gps.csv',
        'track.gpx',
        'track.geojson',
        'derived_metrics.csv',
        'derived_metrics.json',
        'diagnostics.json',
        ...imuChunks.map(_imuChunkFileName),
      ],
    });
  }

  String _imuChunkFileName(ImuChunkEntity chunk) {
    final stamp = chunk.capturedAtUtc
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    return 'imu_chunks/imu_${chunk.id ?? stamp}.bin';
  }

  String _summaryJson(SessionSummaryEntity summary) {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'sessionId': summary.sessionId,
      'raceId': summary.raceId,
      'role': summary.role,
      'state': summary.state,
      'startedAtUtc': summary.startedAtUtc.toIso8601String(),
      'endedAtUtc': summary.endedAtUtc?.toIso8601String(),
      'durationSeconds': summary.duration.inSeconds,
      'gpsPointCount': summary.gpsPointCount,
      'imuChunkCount': summary.imuChunkCount,
      'imuSampleCount': summary.imuSampleCount,
      'syncState': summary.syncState,
      'averageSpeedMetersPerSecond': summary.averageSpeedMetersPerSecond,
      'derivedMetricSummary': summary.derivedMetricSummary,
      'droppedSampleCount': summary.droppedSampleCount,
      'hasErrors': summary.hasErrors,
      'failureReason': summary.failureReason,
      'sensorHealthSnapshot': summary.sensorHealthSnapshot,
    });
  }

  String _diagnosticsJson(DiagnosticsSnapshotEntity diagnostics) {
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'generatedAtUtc': diagnostics.generatedAtUtc.toIso8601String(),
      'appVersion': diagnostics.appVersion,
      'databaseSchemaVersion': diagnostics.databaseSchemaVersion,
      'sessionId': diagnostics.sessionId,
      'locationPermission': diagnostics.locationPermission,
      'motionPermission': diagnostics.motionPermission,
      'gpsEnabled': diagnostics.gpsEnabled,
      'imuEnabled': diagnostics.imuEnabled,
      'backgroundServiceRunning': diagnostics.backgroundServiceRunning,
      'averageGpsRateHz': diagnostics.averageGpsRateHz,
      'averageImuRateHz': diagnostics.averageImuRateHz,
      'droppedSamples': diagnostics.droppedSamples,
      'syncLagSeconds': diagnostics.syncLagSeconds,
      'pendingSyncJobs': diagnostics.pendingSyncJobs,
      'batteryImpactMarkers': diagnostics.batteryImpactMarkers,
      'sensorHealthSnapshot': diagnostics.sensorHealthSnapshot,
    });
  }

  String _buildCsv({
    required SessionSummaryEntity summary,
    required List<TrackingPointEntity> gpsPoints,
  }) {
    final buffer = StringBuffer()
      ..writeln('summary_key,summary_value')
      ..writeln('session_id,${summary.sessionId}')
      ..writeln('race_id,${summary.raceId}')
      ..writeln('state,${summary.state}')
      ..writeln('duration_seconds,${summary.duration.inSeconds}')
      ..writeln('gps_point_count,${summary.gpsPointCount}')
      ..writeln('imu_chunk_count,${summary.imuChunkCount}')
      ..writeln('sync_state,${summary.syncState}')
      ..writeln(
        'average_speed_mps,${summary.averageSpeedMetersPerSecond.toStringAsFixed(3)}',
      )
      ..writeln()
      ..writeln(
        'timestamp_utc,latitude,longitude,accuracy_meters,speed_meters_per_second',
      );
    for (final point in gpsPoints) {
      buffer.writeln(
        '${point.timestampUtc.toIso8601String()},${point.latitude},${point.longitude},${point.accuracyMeters ?? ''},${point.speedMetersPerSecond ?? ''}',
      );
    }
    return buffer.toString();
  }

  String _buildDerivedMetricsCsv(List<DerivedMetricEntity> metrics) {
    final buffer = StringBuffer()
      ..writeln('timestamp_utc,metric_type,metric_value,unit');
    for (final metric in metrics.reversed) {
      buffer.writeln(
        '${metric.timestampUtc.toIso8601String()},${metric.metricType},${metric.metricValue},${metric.unit ?? ''}',
      );
    }
    return buffer.toString();
  }

  String _buildDerivedMetricsJson(List<DerivedMetricEntity> metrics) {
    return const JsonEncoder.withIndent('  ').convert(
      metrics.reversed
          .map((metric) {
            return <String, Object?>{
              'timestampUtc': metric.timestampUtc.toIso8601String(),
              'metricType': metric.metricType,
              'metricValue': metric.metricValue,
              'unit': metric.unit,
            };
          })
          .toList(growable: false),
    );
  }

  String _buildGpx(List<TrackingPointEntity> gpsPoints) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<gpx version="1.1" creator="vkr-regatta-mobile">')
      ..writeln('<trk><name>Regatta track</name><trkseg>');
    for (final point in gpsPoints) {
      buffer.writeln(
        '<trkpt lat="${point.latitude}" lon="${point.longitude}"><time>${point.timestampUtc.toIso8601String()}</time></trkpt>',
      );
    }
    buffer
      ..writeln('</trkseg></trk>')
      ..writeln('</gpx>');
    return buffer.toString();
  }

  String _buildGeoJson(List<TrackingPointEntity> gpsPoints) {
    final coordinates = gpsPoints
        .map((point) => <double>[point.longitude, point.latitude])
        .toList(growable: false);
    final features = <Map<String, Object?>>[
      <String, Object?>{
        'type': 'Feature',
        'properties': <String, Object?>{'name': 'track'},
        'geometry': <String, Object?>{
          'type': 'LineString',
          'coordinates': coordinates,
        },
      },
    ];
    if (gpsPoints.isNotEmpty) {
      features.addAll(<Map<String, Object?>>[
        _pointFeature('start', gpsPoints.first),
        _pointFeature('finish', gpsPoints.last),
      ]);
    }
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'type': 'FeatureCollection',
      'features': features,
    });
  }

  Map<String, Object?> _pointFeature(String name, TrackingPointEntity point) {
    return <String, Object?>{
      'type': 'Feature',
      'properties': <String, Object?>{
        'name': name,
        'timestampUtc': point.timestampUtc.toIso8601String(),
      },
      'geometry': <String, Object?>{
        'type': 'Point',
        'coordinates': <double>[point.longitude, point.latitude],
      },
    };
  }

  Future<Directory> _resolveExportDirectory() async {
    final root = _exportRootDirectory ?? await getApplicationSupportDirectory();
    final directory = Directory(p.join(root.path, 'exports'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _buildFileName({
    required int sessionId,
    required ExportFormat format,
    required DateTime createdAtUtc,
  }) {
    final stamp = createdAtUtc.toIso8601String().replaceAll(':', '-');
    final extension = switch (format) {
      ExportFormat.csv => 'csv',
      ExportFormat.gpx => 'gpx',
      ExportFormat.geoJson => 'geojson',
      ExportFormat.zipBundle => 'zip',
      ExportFormat.diagnosticsJson => 'json',
    };
    final prefix = switch (format) {
      ExportFormat.diagnosticsJson => 'diagnostics',
      _ => 'session_$sessionId',
    };
    return '$prefix-$stamp.$extension';
  }

  int _parseHealthSnapshotValue(String? snapshot, String key) {
    if (snapshot == null || snapshot.isEmpty) {
      return 0;
    }
    for (final pair in snapshot.split(';')) {
      final parts = pair.split('=');
      if (parts.length != 2 || parts.first != key) {
        continue;
      }
      return int.tryParse(parts.last) ?? 0;
    }
    return 0;
  }
}

extension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
