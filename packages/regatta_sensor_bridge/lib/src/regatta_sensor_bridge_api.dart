import 'regatta_sensor_bridge_platform_interface.dart';

class RegattaSensorBridge {
  RegattaSensorBridge({RegattaSensorBridgePlatform? platform})
    : _platform = platform ?? RegattaSensorBridgePlatform.instance;

  final RegattaSensorBridgePlatform _platform;

  Future<SessionStatus> startTrackingSession(SessionConfig config) {
    return _platform.startTrackingSession(config);
  }

  Future<SessionStatus> stopTrackingSession(String sessionId) {
    return _platform.stopTrackingSession(sessionId);
  }

  Future<SessionStatus> pauseTrackingSession(String sessionId) {
    return _platform.pauseTrackingSession(sessionId);
  }

  Future<SessionStatus> resumeTrackingSession(String sessionId) {
    return _platform.resumeTrackingSession(sessionId);
  }

  Future<void> setTrackingProfile(String sessionId, TrackingProfile profile) {
    return _platform.setTrackingProfile(sessionId, profile);
  }

  Future<HealthEvent> requestRequiredPermissions() {
    return _platform.requestRequiredPermissions();
  }

  Future<HealthEvent> getTrackingHealth({String? sessionId}) {
    return _platform.getTrackingHealth(sessionId: sessionId);
  }

  Future<SessionStatus?> getSessionStatus(String sessionId) {
    return _platform.getSessionStatus(sessionId);
  }

  Stream<SampleBatch> streamSamples({String? sessionId}) {
    return _platform.streamSamples(sessionId: sessionId);
  }

  Stream<HealthEvent> streamHealth({String? sessionId}) {
    return _platform.streamHealth(sessionId: sessionId);
  }
}

enum TrackingProfile {
  prestartPrecision,
  raceCruise,
  markRoundingPrecision,
  paused,
}

enum SessionLifecycleState {
  idle,
  preparing,
  tracking,
  paused,
  syncing,
  stopped,
  failed,
}

enum PermissionStatus { granted, denied, deniedForever, unknown }

enum DesiredAccuracy { navigation, high, balanced, lowPower }

enum BackgroundMode { foregroundService, significantLocation, disabled }

enum BufferingPolicy { streamToFlutter, persistNativeBuffer }

class SessionConfig {
  const SessionConfig({
    required this.sessionId,
    required this.raceId,
    required this.role,
    required this.gpsHz,
    required this.imuHz,
    required this.desiredAccuracy,
    required this.backgroundMode,
    required this.bufferingPolicy,
    required this.initialTrackingProfile,
  });

  final String sessionId;
  final int raceId;
  final String role;
  final double gpsHz;
  final double imuHz;
  final DesiredAccuracy desiredAccuracy;
  final BackgroundMode backgroundMode;
  final BufferingPolicy bufferingPolicy;
  final TrackingProfile initialTrackingProfile;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sessionId': sessionId,
      'raceId': raceId,
      'role': role,
      'gpsHz': gpsHz,
      'imuHz': imuHz,
      'desiredAccuracy': desiredAccuracy.name,
      'backgroundMode': backgroundMode.name,
      'bufferingPolicy': bufferingPolicy.name,
      'initialTrackingProfile': initialTrackingProfile.name,
    };
  }

  factory SessionConfig.fromMap(Map<Object?, Object?> map) {
    return SessionConfig(
      sessionId: map.stringValue('sessionId'),
      raceId: map.intValue('raceId'),
      role: map.stringValue('role'),
      gpsHz: map.doubleValue('gpsHz'),
      imuHz: map.doubleValue('imuHz'),
      desiredAccuracy: DesiredAccuracy.values.byWireName(
        map.stringValue('desiredAccuracy'),
      ),
      backgroundMode: BackgroundMode.values.byWireName(
        map.stringValue('backgroundMode'),
      ),
      bufferingPolicy: BufferingPolicy.values.byWireName(
        map.stringValue('bufferingPolicy'),
      ),
      initialTrackingProfile: TrackingProfile.values.byWireName(
        map.stringValue('initialTrackingProfile'),
      ),
    );
  }
}

class SessionStatus {
  const SessionStatus({
    required this.state,
    required this.sessionId,
    required this.startedAt,
    this.pausedAt,
    this.lastSampleAt,
    this.activeProfile,
    this.error,
  });

  final SessionLifecycleState state;
  final String sessionId;
  final DateTime startedAt;
  final DateTime? pausedAt;
  final DateTime? lastSampleAt;
  final TrackingProfile? activeProfile;
  final NativeError? error;

  SessionStatus copyWith({
    SessionLifecycleState? state,
    String? sessionId,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? lastSampleAt,
    TrackingProfile? activeProfile,
    NativeError? error,
  }) {
    return SessionStatus(
      state: state ?? this.state,
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      lastSampleAt: lastSampleAt ?? this.lastSampleAt,
      activeProfile: activeProfile ?? this.activeProfile,
      error: error ?? this.error,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'state': state.name,
      'sessionId': sessionId,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'pausedAt': pausedAt?.toUtc().toIso8601String(),
      'lastSampleAt': lastSampleAt?.toUtc().toIso8601String(),
      'activeProfile': activeProfile?.name,
      'error': error?.toMap(),
    };
  }

  factory SessionStatus.fromMap(Map<Object?, Object?> map) {
    return SessionStatus(
      state: SessionLifecycleState.values.byWireName(map.stringValue('state')),
      sessionId: map.stringValue('sessionId'),
      startedAt: map.dateTimeValue('startedAt'),
      pausedAt: map.nullableDateTimeValue('pausedAt'),
      lastSampleAt: map.nullableDateTimeValue('lastSampleAt'),
      activeProfile: map.nullableStringValue('activeProfile') == null
          ? null
          : TrackingProfile.values.byWireName(map.stringValue('activeProfile')),
      error: map.mapValue('error') == null
          ? null
          : NativeError.fromMap(map.mapValue('error')!),
    );
  }
}

class SampleBatch {
  const SampleBatch({
    required this.sessionId,
    required this.recordedAt,
    this.gpsPoints = const <GpsSample>[],
    this.imuChunkRefs = const <ImuChunkRef>[],
  });

  final String sessionId;
  final DateTime recordedAt;
  final List<GpsSample> gpsPoints;
  final List<ImuChunkRef> imuChunkRefs;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sessionId': sessionId,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'gpsPoints': gpsPoints.map((point) => point.toMap()).toList(),
      'imuChunkRefs': imuChunkRefs.map((chunk) => chunk.toMap()).toList(),
    };
  }

  factory SampleBatch.fromMap(Map<Object?, Object?> map) {
    return SampleBatch(
      sessionId: map.stringValue('sessionId'),
      recordedAt: map.dateTimeValue('recordedAt'),
      gpsPoints: map.listValue('gpsPoints').map((Object? item) {
        return GpsSample.fromMap((item as Map<Object?, Object?>));
      }).toList(),
      imuChunkRefs: map.listValue('imuChunkRefs').map((Object? item) {
        return ImuChunkRef.fromMap((item as Map<Object?, Object?>));
      }).toList(),
    );
  }
}

class GpsSample {
  const GpsSample({
    required this.timestamp,
    required this.longitude,
    required this.latitude,
    this.accuracyMeters,
    this.speedMetersPerSecond,
  });

  final DateTime timestamp;
  final double longitude;
  final double latitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'timestamp': timestamp.toUtc().toIso8601String(),
      'longitude': longitude,
      'latitude': latitude,
      'accuracyMeters': accuracyMeters,
      'speedMetersPerSecond': speedMetersPerSecond,
    };
  }

  factory GpsSample.fromMap(Map<Object?, Object?> map) {
    return GpsSample(
      timestamp: map.dateTimeValue('timestamp'),
      longitude: map.doubleValue('longitude'),
      latitude: map.doubleValue('latitude'),
      accuracyMeters: map.nullableDoubleValue('accuracyMeters'),
      speedMetersPerSecond: map.nullableDoubleValue('speedMetersPerSecond'),
    );
  }
}

class ImuChunkRef {
  const ImuChunkRef({
    required this.chunkId,
    required this.startedAt,
    required this.sampleCount,
    this.storagePath,
  });

  final String chunkId;
  final DateTime startedAt;
  final int sampleCount;
  final String? storagePath;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'chunkId': chunkId,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'sampleCount': sampleCount,
      'storagePath': storagePath,
    };
  }

  factory ImuChunkRef.fromMap(Map<Object?, Object?> map) {
    return ImuChunkRef(
      chunkId: map.stringValue('chunkId'),
      startedAt: map.dateTimeValue('startedAt'),
      sampleCount: map.intValue('sampleCount'),
      storagePath: map.nullableStringValue('storagePath'),
    );
  }
}

class HealthEvent {
  const HealthEvent({
    required this.sessionId,
    required this.recordedAt,
    required this.locationPermission,
    required this.motionPermission,
    required this.gpsAvailable,
    required this.imuAvailable,
    required this.backgroundServiceRunning,
    required this.droppedSamples,
    required this.queueDepth,
    this.batteryPercent,
    this.lastGpsSampleAgeMs,
    this.lastImuSampleAgeMs,
    this.gpsAccuracyMeters,
    this.receivedGpsSamples,
    this.receivedImuSamples,
    this.averageGpsRateHz,
    this.averageImuRateHz,
    this.lastGpsSensorTimestamp,
    this.lastImuSensorTimestamp,
    this.serviceRestarts,
    this.activeTrackingProfile,
    this.statusMessage,
    this.storagePath,
    this.error,
  });

  final String? sessionId;
  final DateTime recordedAt;
  final PermissionStatus locationPermission;
  final PermissionStatus motionPermission;
  final bool gpsAvailable;
  final bool imuAvailable;
  final bool backgroundServiceRunning;
  final int droppedSamples;
  final int queueDepth;
  final double? batteryPercent;
  final int? lastGpsSampleAgeMs;
  final int? lastImuSampleAgeMs;
  final double? gpsAccuracyMeters;
  final int? receivedGpsSamples;
  final int? receivedImuSamples;
  final double? averageGpsRateHz;
  final double? averageImuRateHz;
  final DateTime? lastGpsSensorTimestamp;
  final DateTime? lastImuSensorTimestamp;
  final int? serviceRestarts;
  final TrackingProfile? activeTrackingProfile;
  final String? statusMessage;
  final String? storagePath;
  final NativeError? error;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'sessionId': sessionId,
      'recordedAt': recordedAt.toUtc().toIso8601String(),
      'locationPermission': locationPermission.name,
      'motionPermission': motionPermission.name,
      'gpsAvailable': gpsAvailable,
      'imuAvailable': imuAvailable,
      'backgroundServiceRunning': backgroundServiceRunning,
      'droppedSamples': droppedSamples,
      'queueDepth': queueDepth,
      'batteryPercent': batteryPercent,
      'lastGpsSampleAgeMs': lastGpsSampleAgeMs,
      'lastImuSampleAgeMs': lastImuSampleAgeMs,
      'gpsAccuracyMeters': gpsAccuracyMeters,
      'receivedGpsSamples': receivedGpsSamples,
      'receivedImuSamples': receivedImuSamples,
      'averageGpsRateHz': averageGpsRateHz,
      'averageImuRateHz': averageImuRateHz,
      'lastGpsSensorTimestamp': lastGpsSensorTimestamp
          ?.toUtc()
          .toIso8601String(),
      'lastImuSensorTimestamp': lastImuSensorTimestamp
          ?.toUtc()
          .toIso8601String(),
      'serviceRestarts': serviceRestarts,
      'activeTrackingProfile': activeTrackingProfile?.name,
      'statusMessage': statusMessage,
      'storagePath': storagePath,
      'error': error?.toMap(),
    };
  }

  factory HealthEvent.fromMap(Map<Object?, Object?> map) {
    return HealthEvent(
      sessionId: map.nullableStringValue('sessionId'),
      recordedAt: map.dateTimeValue('recordedAt'),
      locationPermission: PermissionStatus.values.byWireName(
        map.stringValue('locationPermission'),
      ),
      motionPermission: PermissionStatus.values.byWireName(
        map.stringValue('motionPermission'),
      ),
      gpsAvailable: map.boolValue('gpsAvailable'),
      imuAvailable: map.boolValue('imuAvailable'),
      backgroundServiceRunning: map.boolValue('backgroundServiceRunning'),
      droppedSamples: map.intValue('droppedSamples'),
      queueDepth: map.intValue('queueDepth'),
      batteryPercent: map.nullableDoubleValue('batteryPercent'),
      lastGpsSampleAgeMs: map.nullableIntValue('lastGpsSampleAgeMs'),
      lastImuSampleAgeMs: map.nullableIntValue('lastImuSampleAgeMs'),
      gpsAccuracyMeters: map.nullableDoubleValue('gpsAccuracyMeters'),
      receivedGpsSamples: map.nullableIntValue('receivedGpsSamples'),
      receivedImuSamples: map.nullableIntValue('receivedImuSamples'),
      averageGpsRateHz: map.nullableDoubleValue('averageGpsRateHz'),
      averageImuRateHz: map.nullableDoubleValue('averageImuRateHz'),
      lastGpsSensorTimestamp: map.nullableDateTimeValue(
        'lastGpsSensorTimestamp',
      ),
      lastImuSensorTimestamp: map.nullableDateTimeValue(
        'lastImuSensorTimestamp',
      ),
      serviceRestarts: map.nullableIntValue('serviceRestarts'),
      activeTrackingProfile:
          map.nullableStringValue('activeTrackingProfile') == null
          ? null
          : TrackingProfile.values.byWireName(
              map.stringValue('activeTrackingProfile'),
            ),
      statusMessage: map.nullableStringValue('statusMessage'),
      storagePath: map.nullableStringValue('storagePath'),
      error: map.mapValue('error') == null
          ? null
          : NativeError.fromMap(map.mapValue('error')!),
    );
  }
}

class NativeError {
  const NativeError({
    required this.code,
    required this.message,
    required this.isRecoverable,
  });

  final String code;
  final String message;
  final bool isRecoverable;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'code': code,
      'message': message,
      'isRecoverable': isRecoverable,
    };
  }

  factory NativeError.fromMap(Map<Object?, Object?> map) {
    return NativeError(
      code: map.stringValue('code'),
      message: map.stringValue('message'),
      isRecoverable: map.boolValue('isRecoverable'),
    );
  }
}

class SensorBridgeException implements Exception {
  const SensorBridgeException(this.error);

  final NativeError error;

  @override
  String toString() {
    return 'SensorBridgeException(${error.code}): ${error.message}';
  }
}

extension _EnumLookup<T extends Enum> on List<T> {
  T byWireName(String rawValue) {
    return firstWhere(
      (T candidate) => candidate.name == rawValue,
      orElse: () => throw ArgumentError.value(rawValue, 'rawValue'),
    );
  }
}

extension MapAccess on Map<Object?, Object?> {
  bool boolValue(String key) => this[key] as bool? ?? false;

  DateTime dateTimeValue(String key) {
    return DateTime.parse(stringValue(key)).toUtc();
  }

  double doubleValue(String key) {
    final Object? value = this[key];
    if (value is num) {
      return value.toDouble();
    }
    throw ArgumentError.value(value, key);
  }

  int intValue(String key) {
    final Object? value = this[key];
    if (value is num) {
      return value.toInt();
    }
    throw ArgumentError.value(value, key);
  }

  List<Object?> listValue(String key) {
    return (this[key] as List<Object?>?) ?? const <Object?>[];
  }

  Map<Object?, Object?>? mapValue(String key) {
    return this[key] as Map<Object?, Object?>?;
  }

  DateTime? nullableDateTimeValue(String key) {
    final value = nullableStringValue(key);
    return value == null ? null : DateTime.parse(value).toUtc();
  }

  double? nullableDoubleValue(String key) {
    final Object? value = this[key];
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    throw ArgumentError.value(value, key);
  }

  int? nullableIntValue(String key) {
    final Object? value = this[key];
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    throw ArgumentError.value(value, key);
  }

  String? nullableStringValue(String key) => this[key] as String?;

  String stringValue(String key) {
    final Object? value = this[key];
    if (value is String) {
      return value;
    }
    throw ArgumentError.value(value, key);
  }
}
