// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TrackingSessionsTable extends TrackingSessions
    with TableInfo<$TrackingSessionsTable, TrackingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _raceIdMeta = const VerificationMeta('raceId');
  @override
  late final GeneratedColumn<int> raceId = GeneratedColumn<int>(
    'race_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalSecondsMeta = const VerificationMeta(
    'intervalSeconds',
  );
  @override
  late final GeneratedColumn<int> intervalSeconds = GeneratedColumn<int>(
    'interval_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtUtcMeta = const VerificationMeta(
    'endedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> endedAtUtc = GeneratedColumn<DateTime>(
    'ended_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtUtcMeta = const VerificationMeta(
    'lastSyncAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAtUtc =
      GeneratedColumn<DateTime>(
        'last_sync_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sensorHealthSnapshotMeta =
      const VerificationMeta('sensorHealthSnapshot');
  @override
  late final GeneratedColumn<String> sensorHealthSnapshot =
      GeneratedColumn<String>(
        'sensor_health_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    raceId,
    role,
    state,
    intervalSeconds,
    startedAtUtc,
    endedAtUtc,
    failureReason,
    lastSyncAtUtc,
    sensorHealthSnapshot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracking_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('race_id')) {
      context.handle(
        _raceIdMeta,
        raceId.isAcceptableOrUnknown(data['race_id']!, _raceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_raceIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('interval_seconds')) {
      context.handle(
        _intervalSecondsMeta,
        intervalSeconds.isAcceptableOrUnknown(
          data['interval_seconds']!,
          _intervalSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervalSecondsMeta);
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('ended_at_utc')) {
      context.handle(
        _endedAtUtcMeta,
        endedAtUtc.isAcceptableOrUnknown(
          data['ended_at_utc']!,
          _endedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_at_utc')) {
      context.handle(
        _lastSyncAtUtcMeta,
        lastSyncAtUtc.isAcceptableOrUnknown(
          data['last_sync_at_utc']!,
          _lastSyncAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('sensor_health_snapshot')) {
      context.handle(
        _sensorHealthSnapshotMeta,
        sensorHealthSnapshot.isAcceptableOrUnknown(
          data['sensor_health_snapshot']!,
          _sensorHealthSnapshotMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      raceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}race_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      intervalSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_seconds'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      endedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at_utc'],
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      lastSyncAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at_utc'],
      ),
      sensorHealthSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sensor_health_snapshot'],
      ),
    );
  }

  @override
  $TrackingSessionsTable createAlias(String alias) {
    return $TrackingSessionsTable(attachedDatabase, alias);
  }
}

class TrackingSession extends DataClass implements Insertable<TrackingSession> {
  final int id;
  final int raceId;
  final String role;
  final String state;
  final int intervalSeconds;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final String? failureReason;
  final DateTime? lastSyncAtUtc;
  final String? sensorHealthSnapshot;
  const TrackingSession({
    required this.id,
    required this.raceId,
    required this.role,
    required this.state,
    required this.intervalSeconds,
    required this.startedAtUtc,
    this.endedAtUtc,
    this.failureReason,
    this.lastSyncAtUtc,
    this.sensorHealthSnapshot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['race_id'] = Variable<int>(raceId);
    map['role'] = Variable<String>(role);
    map['state'] = Variable<String>(state);
    map['interval_seconds'] = Variable<int>(intervalSeconds);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    if (!nullToAbsent || endedAtUtc != null) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc);
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    if (!nullToAbsent || lastSyncAtUtc != null) {
      map['last_sync_at_utc'] = Variable<DateTime>(lastSyncAtUtc);
    }
    if (!nullToAbsent || sensorHealthSnapshot != null) {
      map['sensor_health_snapshot'] = Variable<String>(sensorHealthSnapshot);
    }
    return map;
  }

  TrackingSessionsCompanion toCompanion(bool nullToAbsent) {
    return TrackingSessionsCompanion(
      id: Value(id),
      raceId: Value(raceId),
      role: Value(role),
      state: Value(state),
      intervalSeconds: Value(intervalSeconds),
      startedAtUtc: Value(startedAtUtc),
      endedAtUtc: endedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtUtc),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      lastSyncAtUtc: lastSyncAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAtUtc),
      sensorHealthSnapshot: sensorHealthSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(sensorHealthSnapshot),
    );
  }

  factory TrackingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackingSession(
      id: serializer.fromJson<int>(json['id']),
      raceId: serializer.fromJson<int>(json['raceId']),
      role: serializer.fromJson<String>(json['role']),
      state: serializer.fromJson<String>(json['state']),
      intervalSeconds: serializer.fromJson<int>(json['intervalSeconds']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      endedAtUtc: serializer.fromJson<DateTime?>(json['endedAtUtc']),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      lastSyncAtUtc: serializer.fromJson<DateTime?>(json['lastSyncAtUtc']),
      sensorHealthSnapshot: serializer.fromJson<String?>(
        json['sensorHealthSnapshot'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'raceId': serializer.toJson<int>(raceId),
      'role': serializer.toJson<String>(role),
      'state': serializer.toJson<String>(state),
      'intervalSeconds': serializer.toJson<int>(intervalSeconds),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'endedAtUtc': serializer.toJson<DateTime?>(endedAtUtc),
      'failureReason': serializer.toJson<String?>(failureReason),
      'lastSyncAtUtc': serializer.toJson<DateTime?>(lastSyncAtUtc),
      'sensorHealthSnapshot': serializer.toJson<String?>(sensorHealthSnapshot),
    };
  }

  TrackingSession copyWith({
    int? id,
    int? raceId,
    String? role,
    String? state,
    int? intervalSeconds,
    DateTime? startedAtUtc,
    Value<DateTime?> endedAtUtc = const Value.absent(),
    Value<String?> failureReason = const Value.absent(),
    Value<DateTime?> lastSyncAtUtc = const Value.absent(),
    Value<String?> sensorHealthSnapshot = const Value.absent(),
  }) => TrackingSession(
    id: id ?? this.id,
    raceId: raceId ?? this.raceId,
    role: role ?? this.role,
    state: state ?? this.state,
    intervalSeconds: intervalSeconds ?? this.intervalSeconds,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    endedAtUtc: endedAtUtc.present ? endedAtUtc.value : this.endedAtUtc,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    lastSyncAtUtc: lastSyncAtUtc.present
        ? lastSyncAtUtc.value
        : this.lastSyncAtUtc,
    sensorHealthSnapshot: sensorHealthSnapshot.present
        ? sensorHealthSnapshot.value
        : this.sensorHealthSnapshot,
  );
  TrackingSession copyWithCompanion(TrackingSessionsCompanion data) {
    return TrackingSession(
      id: data.id.present ? data.id.value : this.id,
      raceId: data.raceId.present ? data.raceId.value : this.raceId,
      role: data.role.present ? data.role.value : this.role,
      state: data.state.present ? data.state.value : this.state,
      intervalSeconds: data.intervalSeconds.present
          ? data.intervalSeconds.value
          : this.intervalSeconds,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      endedAtUtc: data.endedAtUtc.present
          ? data.endedAtUtc.value
          : this.endedAtUtc,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      lastSyncAtUtc: data.lastSyncAtUtc.present
          ? data.lastSyncAtUtc.value
          : this.lastSyncAtUtc,
      sensorHealthSnapshot: data.sensorHealthSnapshot.present
          ? data.sensorHealthSnapshot.value
          : this.sensorHealthSnapshot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackingSession(')
          ..write('id: $id, ')
          ..write('raceId: $raceId, ')
          ..write('role: $role, ')
          ..write('state: $state, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('failureReason: $failureReason, ')
          ..write('lastSyncAtUtc: $lastSyncAtUtc, ')
          ..write('sensorHealthSnapshot: $sensorHealthSnapshot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    raceId,
    role,
    state,
    intervalSeconds,
    startedAtUtc,
    endedAtUtc,
    failureReason,
    lastSyncAtUtc,
    sensorHealthSnapshot,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackingSession &&
          other.id == this.id &&
          other.raceId == this.raceId &&
          other.role == this.role &&
          other.state == this.state &&
          other.intervalSeconds == this.intervalSeconds &&
          other.startedAtUtc == this.startedAtUtc &&
          other.endedAtUtc == this.endedAtUtc &&
          other.failureReason == this.failureReason &&
          other.lastSyncAtUtc == this.lastSyncAtUtc &&
          other.sensorHealthSnapshot == this.sensorHealthSnapshot);
}

class TrackingSessionsCompanion extends UpdateCompanion<TrackingSession> {
  final Value<int> id;
  final Value<int> raceId;
  final Value<String> role;
  final Value<String> state;
  final Value<int> intervalSeconds;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime?> endedAtUtc;
  final Value<String?> failureReason;
  final Value<DateTime?> lastSyncAtUtc;
  final Value<String?> sensorHealthSnapshot;
  const TrackingSessionsCompanion({
    this.id = const Value.absent(),
    this.raceId = const Value.absent(),
    this.role = const Value.absent(),
    this.state = const Value.absent(),
    this.intervalSeconds = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.lastSyncAtUtc = const Value.absent(),
    this.sensorHealthSnapshot = const Value.absent(),
  });
  TrackingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int raceId,
    required String role,
    required String state,
    required int intervalSeconds,
    required DateTime startedAtUtc,
    this.endedAtUtc = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.lastSyncAtUtc = const Value.absent(),
    this.sensorHealthSnapshot = const Value.absent(),
  }) : raceId = Value(raceId),
       role = Value(role),
       state = Value(state),
       intervalSeconds = Value(intervalSeconds),
       startedAtUtc = Value(startedAtUtc);
  static Insertable<TrackingSession> custom({
    Expression<int>? id,
    Expression<int>? raceId,
    Expression<String>? role,
    Expression<String>? state,
    Expression<int>? intervalSeconds,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? endedAtUtc,
    Expression<String>? failureReason,
    Expression<DateTime>? lastSyncAtUtc,
    Expression<String>? sensorHealthSnapshot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (raceId != null) 'race_id': raceId,
      if (role != null) 'role': role,
      if (state != null) 'state': state,
      if (intervalSeconds != null) 'interval_seconds': intervalSeconds,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (endedAtUtc != null) 'ended_at_utc': endedAtUtc,
      if (failureReason != null) 'failure_reason': failureReason,
      if (lastSyncAtUtc != null) 'last_sync_at_utc': lastSyncAtUtc,
      if (sensorHealthSnapshot != null)
        'sensor_health_snapshot': sensorHealthSnapshot,
    });
  }

  TrackingSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? raceId,
    Value<String>? role,
    Value<String>? state,
    Value<int>? intervalSeconds,
    Value<DateTime>? startedAtUtc,
    Value<DateTime?>? endedAtUtc,
    Value<String?>? failureReason,
    Value<DateTime?>? lastSyncAtUtc,
    Value<String?>? sensorHealthSnapshot,
  }) {
    return TrackingSessionsCompanion(
      id: id ?? this.id,
      raceId: raceId ?? this.raceId,
      role: role ?? this.role,
      state: state ?? this.state,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      failureReason: failureReason ?? this.failureReason,
      lastSyncAtUtc: lastSyncAtUtc ?? this.lastSyncAtUtc,
      sensorHealthSnapshot: sensorHealthSnapshot ?? this.sensorHealthSnapshot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (raceId.present) {
      map['race_id'] = Variable<int>(raceId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (intervalSeconds.present) {
      map['interval_seconds'] = Variable<int>(intervalSeconds.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (endedAtUtc.present) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc.value);
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (lastSyncAtUtc.present) {
      map['last_sync_at_utc'] = Variable<DateTime>(lastSyncAtUtc.value);
    }
    if (sensorHealthSnapshot.present) {
      map['sensor_health_snapshot'] = Variable<String>(
        sensorHealthSnapshot.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('raceId: $raceId, ')
          ..write('role: $role, ')
          ..write('state: $state, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('failureReason: $failureReason, ')
          ..write('lastSyncAtUtc: $lastSyncAtUtc, ')
          ..write('sensorHealthSnapshot: $sensorHealthSnapshot')
          ..write(')'))
        .toString();
  }
}

class $GpsPointsTable extends GpsPoints
    with TableInfo<$GpsPointsTable, GpsPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GpsPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions (id)',
    ),
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> timestampUtc = GeneratedColumn<DateTime>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMetersMeta = const VerificationMeta(
    'accuracyMeters',
  );
  @override
  late final GeneratedColumn<double> accuracyMeters = GeneratedColumn<double>(
    'accuracy_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMetersPerSecondMeta =
      const VerificationMeta('speedMetersPerSecond');
  @override
  late final GeneratedColumn<double> speedMetersPerSecond =
      GeneratedColumn<double>(
        'speed_meters_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestampUtc,
    longitude,
    latitude,
    accuracyMeters,
    speedMetersPerSecond,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gps_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<GpsPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('accuracy_meters')) {
      context.handle(
        _accuracyMetersMeta,
        accuracyMeters.isAcceptableOrUnknown(
          data['accuracy_meters']!,
          _accuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('speed_meters_per_second')) {
      context.handle(
        _speedMetersPerSecondMeta,
        speedMetersPerSecond.isAcceptableOrUnknown(
          data['speed_meters_per_second']!,
          _speedMetersPerSecondMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GpsPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GpsPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      accuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy_meters'],
      ),
      speedMetersPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_meters_per_second'],
      ),
    );
  }

  @override
  $GpsPointsTable createAlias(String alias) {
    return $GpsPointsTable(attachedDatabase, alias);
  }
}

class GpsPoint extends DataClass implements Insertable<GpsPoint> {
  final int id;
  final int sessionId;
  final DateTime timestampUtc;
  final double longitude;
  final double latitude;
  final double? accuracyMeters;
  final double? speedMetersPerSecond;
  const GpsPoint({
    required this.id,
    required this.sessionId,
    required this.timestampUtc,
    required this.longitude,
    required this.latitude,
    this.accuracyMeters,
    this.speedMetersPerSecond,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['timestamp_utc'] = Variable<DateTime>(timestampUtc);
    map['longitude'] = Variable<double>(longitude);
    map['latitude'] = Variable<double>(latitude);
    if (!nullToAbsent || accuracyMeters != null) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters);
    }
    if (!nullToAbsent || speedMetersPerSecond != null) {
      map['speed_meters_per_second'] = Variable<double>(speedMetersPerSecond);
    }
    return map;
  }

  GpsPointsCompanion toCompanion(bool nullToAbsent) {
    return GpsPointsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestampUtc: Value(timestampUtc),
      longitude: Value(longitude),
      latitude: Value(latitude),
      accuracyMeters: accuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracyMeters),
      speedMetersPerSecond: speedMetersPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMetersPerSecond),
    );
  }

  factory GpsPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GpsPoint(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      timestampUtc: serializer.fromJson<DateTime>(json['timestampUtc']),
      longitude: serializer.fromJson<double>(json['longitude']),
      latitude: serializer.fromJson<double>(json['latitude']),
      accuracyMeters: serializer.fromJson<double?>(json['accuracyMeters']),
      speedMetersPerSecond: serializer.fromJson<double?>(
        json['speedMetersPerSecond'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'timestampUtc': serializer.toJson<DateTime>(timestampUtc),
      'longitude': serializer.toJson<double>(longitude),
      'latitude': serializer.toJson<double>(latitude),
      'accuracyMeters': serializer.toJson<double?>(accuracyMeters),
      'speedMetersPerSecond': serializer.toJson<double?>(speedMetersPerSecond),
    };
  }

  GpsPoint copyWith({
    int? id,
    int? sessionId,
    DateTime? timestampUtc,
    double? longitude,
    double? latitude,
    Value<double?> accuracyMeters = const Value.absent(),
    Value<double?> speedMetersPerSecond = const Value.absent(),
  }) => GpsPoint(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    longitude: longitude ?? this.longitude,
    latitude: latitude ?? this.latitude,
    accuracyMeters: accuracyMeters.present
        ? accuracyMeters.value
        : this.accuracyMeters,
    speedMetersPerSecond: speedMetersPerSecond.present
        ? speedMetersPerSecond.value
        : this.speedMetersPerSecond,
  );
  GpsPoint copyWithCompanion(GpsPointsCompanion data) {
    return GpsPoint(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      accuracyMeters: data.accuracyMeters.present
          ? data.accuracyMeters.value
          : this.accuracyMeters,
      speedMetersPerSecond: data.speedMetersPerSecond.present
          ? data.speedMetersPerSecond.value
          : this.speedMetersPerSecond,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GpsPoint(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('longitude: $longitude, ')
          ..write('latitude: $latitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('speedMetersPerSecond: $speedMetersPerSecond')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    timestampUtc,
    longitude,
    latitude,
    accuracyMeters,
    speedMetersPerSecond,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GpsPoint &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestampUtc == this.timestampUtc &&
          other.longitude == this.longitude &&
          other.latitude == this.latitude &&
          other.accuracyMeters == this.accuracyMeters &&
          other.speedMetersPerSecond == this.speedMetersPerSecond);
}

class GpsPointsCompanion extends UpdateCompanion<GpsPoint> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<DateTime> timestampUtc;
  final Value<double> longitude;
  final Value<double> latitude;
  final Value<double?> accuracyMeters;
  final Value<double?> speedMetersPerSecond;
  const GpsPointsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.longitude = const Value.absent(),
    this.latitude = const Value.absent(),
    this.accuracyMeters = const Value.absent(),
    this.speedMetersPerSecond = const Value.absent(),
  });
  GpsPointsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required DateTime timestampUtc,
    required double longitude,
    required double latitude,
    this.accuracyMeters = const Value.absent(),
    this.speedMetersPerSecond = const Value.absent(),
  }) : sessionId = Value(sessionId),
       timestampUtc = Value(timestampUtc),
       longitude = Value(longitude),
       latitude = Value(latitude);
  static Insertable<GpsPoint> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? timestampUtc,
    Expression<double>? longitude,
    Expression<double>? latitude,
    Expression<double>? accuracyMeters,
    Expression<double>? speedMetersPerSecond,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (longitude != null) 'longitude': longitude,
      if (latitude != null) 'latitude': latitude,
      if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
      if (speedMetersPerSecond != null)
        'speed_meters_per_second': speedMetersPerSecond,
    });
  }

  GpsPointsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<DateTime>? timestampUtc,
    Value<double>? longitude,
    Value<double>? latitude,
    Value<double?>? accuracyMeters,
    Value<double?>? speedMetersPerSecond,
  }) {
    return GpsPointsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<DateTime>(timestampUtc.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (accuracyMeters.present) {
      map['accuracy_meters'] = Variable<double>(accuracyMeters.value);
    }
    if (speedMetersPerSecond.present) {
      map['speed_meters_per_second'] = Variable<double>(
        speedMetersPerSecond.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GpsPointsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('longitude: $longitude, ')
          ..write('latitude: $latitude, ')
          ..write('accuracyMeters: $accuracyMeters, ')
          ..write('speedMetersPerSecond: $speedMetersPerSecond')
          ..write(')'))
        .toString();
  }
}

class $ImuChunksTable extends ImuChunks
    with TableInfo<$ImuChunksTable, ImuChunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImuChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions (id)',
    ),
  );
  static const VerificationMeta _capturedAtUtcMeta = const VerificationMeta(
    'capturedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAtUtc =
      GeneratedColumn<DateTime>(
        'captured_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _chunkStartMonotonicNsMeta =
      const VerificationMeta('chunkStartMonotonicNs');
  @override
  late final GeneratedColumn<int> chunkStartMonotonicNs = GeneratedColumn<int>(
    'chunk_start_monotonic_ns',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _samplingHzMeta = const VerificationMeta(
    'samplingHz',
  );
  @override
  late final GeneratedColumn<int> samplingHz = GeneratedColumn<int>(
    'sampling_hz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadFormatMeta = const VerificationMeta(
    'payloadFormat',
  );
  @override
  late final GeneratedColumn<String> payloadFormat = GeneratedColumn<String>(
    'payload_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('imu-int16-le-v1'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    capturedAtUtc,
    chunkStartMonotonicNs,
    sampleCount,
    samplingHz,
    payloadFormat,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imu_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImuChunk> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('captured_at_utc')) {
      context.handle(
        _capturedAtUtcMeta,
        capturedAtUtc.isAcceptableOrUnknown(
          data['captured_at_utc']!,
          _capturedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capturedAtUtcMeta);
    }
    if (data.containsKey('chunk_start_monotonic_ns')) {
      context.handle(
        _chunkStartMonotonicNsMeta,
        chunkStartMonotonicNs.isAcceptableOrUnknown(
          data['chunk_start_monotonic_ns']!,
          _chunkStartMonotonicNsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chunkStartMonotonicNsMeta);
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
    }
    if (data.containsKey('sampling_hz')) {
      context.handle(
        _samplingHzMeta,
        samplingHz.isAcceptableOrUnknown(data['sampling_hz']!, _samplingHzMeta),
      );
    } else if (isInserting) {
      context.missing(_samplingHzMeta);
    }
    if (data.containsKey('payload_format')) {
      context.handle(
        _payloadFormatMeta,
        payloadFormat.isAcceptableOrUnknown(
          data['payload_format']!,
          _payloadFormatMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImuChunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImuChunk(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      capturedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at_utc'],
      )!,
      chunkStartMonotonicNs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chunk_start_monotonic_ns'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      samplingHz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sampling_hz'],
      )!,
      payloadFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_format'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ImuChunksTable createAlias(String alias) {
    return $ImuChunksTable(attachedDatabase, alias);
  }
}

class ImuChunk extends DataClass implements Insertable<ImuChunk> {
  final int id;
  final int sessionId;
  final DateTime capturedAtUtc;
  final int chunkStartMonotonicNs;
  final int sampleCount;
  final int samplingHz;
  final String payloadFormat;
  final Uint8List payload;
  const ImuChunk({
    required this.id,
    required this.sessionId,
    required this.capturedAtUtc,
    required this.chunkStartMonotonicNs,
    required this.sampleCount,
    required this.samplingHz,
    required this.payloadFormat,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['captured_at_utc'] = Variable<DateTime>(capturedAtUtc);
    map['chunk_start_monotonic_ns'] = Variable<int>(chunkStartMonotonicNs);
    map['sample_count'] = Variable<int>(sampleCount);
    map['sampling_hz'] = Variable<int>(samplingHz);
    map['payload_format'] = Variable<String>(payloadFormat);
    map['payload'] = Variable<Uint8List>(payload);
    return map;
  }

  ImuChunksCompanion toCompanion(bool nullToAbsent) {
    return ImuChunksCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      capturedAtUtc: Value(capturedAtUtc),
      chunkStartMonotonicNs: Value(chunkStartMonotonicNs),
      sampleCount: Value(sampleCount),
      samplingHz: Value(samplingHz),
      payloadFormat: Value(payloadFormat),
      payload: Value(payload),
    );
  }

  factory ImuChunk.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImuChunk(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      capturedAtUtc: serializer.fromJson<DateTime>(json['capturedAtUtc']),
      chunkStartMonotonicNs: serializer.fromJson<int>(
        json['chunkStartMonotonicNs'],
      ),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      samplingHz: serializer.fromJson<int>(json['samplingHz']),
      payloadFormat: serializer.fromJson<String>(json['payloadFormat']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'capturedAtUtc': serializer.toJson<DateTime>(capturedAtUtc),
      'chunkStartMonotonicNs': serializer.toJson<int>(chunkStartMonotonicNs),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'samplingHz': serializer.toJson<int>(samplingHz),
      'payloadFormat': serializer.toJson<String>(payloadFormat),
      'payload': serializer.toJson<Uint8List>(payload),
    };
  }

  ImuChunk copyWith({
    int? id,
    int? sessionId,
    DateTime? capturedAtUtc,
    int? chunkStartMonotonicNs,
    int? sampleCount,
    int? samplingHz,
    String? payloadFormat,
    Uint8List? payload,
  }) => ImuChunk(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    capturedAtUtc: capturedAtUtc ?? this.capturedAtUtc,
    chunkStartMonotonicNs: chunkStartMonotonicNs ?? this.chunkStartMonotonicNs,
    sampleCount: sampleCount ?? this.sampleCount,
    samplingHz: samplingHz ?? this.samplingHz,
    payloadFormat: payloadFormat ?? this.payloadFormat,
    payload: payload ?? this.payload,
  );
  ImuChunk copyWithCompanion(ImuChunksCompanion data) {
    return ImuChunk(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      capturedAtUtc: data.capturedAtUtc.present
          ? data.capturedAtUtc.value
          : this.capturedAtUtc,
      chunkStartMonotonicNs: data.chunkStartMonotonicNs.present
          ? data.chunkStartMonotonicNs.value
          : this.chunkStartMonotonicNs,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      samplingHz: data.samplingHz.present
          ? data.samplingHz.value
          : this.samplingHz,
      payloadFormat: data.payloadFormat.present
          ? data.payloadFormat.value
          : this.payloadFormat,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImuChunk(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('capturedAtUtc: $capturedAtUtc, ')
          ..write('chunkStartMonotonicNs: $chunkStartMonotonicNs, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('samplingHz: $samplingHz, ')
          ..write('payloadFormat: $payloadFormat, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    capturedAtUtc,
    chunkStartMonotonicNs,
    sampleCount,
    samplingHz,
    payloadFormat,
    $driftBlobEquality.hash(payload),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImuChunk &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.capturedAtUtc == this.capturedAtUtc &&
          other.chunkStartMonotonicNs == this.chunkStartMonotonicNs &&
          other.sampleCount == this.sampleCount &&
          other.samplingHz == this.samplingHz &&
          other.payloadFormat == this.payloadFormat &&
          $driftBlobEquality.equals(other.payload, this.payload));
}

class ImuChunksCompanion extends UpdateCompanion<ImuChunk> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<DateTime> capturedAtUtc;
  final Value<int> chunkStartMonotonicNs;
  final Value<int> sampleCount;
  final Value<int> samplingHz;
  final Value<String> payloadFormat;
  final Value<Uint8List> payload;
  const ImuChunksCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.capturedAtUtc = const Value.absent(),
    this.chunkStartMonotonicNs = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.samplingHz = const Value.absent(),
    this.payloadFormat = const Value.absent(),
    this.payload = const Value.absent(),
  });
  ImuChunksCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required DateTime capturedAtUtc,
    required int chunkStartMonotonicNs,
    required int sampleCount,
    required int samplingHz,
    this.payloadFormat = const Value.absent(),
    required Uint8List payload,
  }) : sessionId = Value(sessionId),
       capturedAtUtc = Value(capturedAtUtc),
       chunkStartMonotonicNs = Value(chunkStartMonotonicNs),
       sampleCount = Value(sampleCount),
       samplingHz = Value(samplingHz),
       payload = Value(payload);
  static Insertable<ImuChunk> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? capturedAtUtc,
    Expression<int>? chunkStartMonotonicNs,
    Expression<int>? sampleCount,
    Expression<int>? samplingHz,
    Expression<String>? payloadFormat,
    Expression<Uint8List>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (capturedAtUtc != null) 'captured_at_utc': capturedAtUtc,
      if (chunkStartMonotonicNs != null)
        'chunk_start_monotonic_ns': chunkStartMonotonicNs,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (samplingHz != null) 'sampling_hz': samplingHz,
      if (payloadFormat != null) 'payload_format': payloadFormat,
      if (payload != null) 'payload': payload,
    });
  }

  ImuChunksCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<DateTime>? capturedAtUtc,
    Value<int>? chunkStartMonotonicNs,
    Value<int>? sampleCount,
    Value<int>? samplingHz,
    Value<String>? payloadFormat,
    Value<Uint8List>? payload,
  }) {
    return ImuChunksCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      capturedAtUtc: capturedAtUtc ?? this.capturedAtUtc,
      chunkStartMonotonicNs:
          chunkStartMonotonicNs ?? this.chunkStartMonotonicNs,
      sampleCount: sampleCount ?? this.sampleCount,
      samplingHz: samplingHz ?? this.samplingHz,
      payloadFormat: payloadFormat ?? this.payloadFormat,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (capturedAtUtc.present) {
      map['captured_at_utc'] = Variable<DateTime>(capturedAtUtc.value);
    }
    if (chunkStartMonotonicNs.present) {
      map['chunk_start_monotonic_ns'] = Variable<int>(
        chunkStartMonotonicNs.value,
      );
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (samplingHz.present) {
      map['sampling_hz'] = Variable<int>(samplingHz.value);
    }
    if (payloadFormat.present) {
      map['payload_format'] = Variable<String>(payloadFormat.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImuChunksCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('capturedAtUtc: $capturedAtUtc, ')
          ..write('chunkStartMonotonicNs: $chunkStartMonotonicNs, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('samplingHz: $samplingHz, ')
          ..write('payloadFormat: $payloadFormat, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $DerivedMetricsTable extends DerivedMetrics
    with TableInfo<$DerivedMetricsTable, DerivedMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DerivedMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions (id)',
    ),
  );
  static const VerificationMeta _timestampUtcMeta = const VerificationMeta(
    'timestampUtc',
  );
  @override
  late final GeneratedColumn<DateTime> timestampUtc = GeneratedColumn<DateTime>(
    'timestamp_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricTypeMeta = const VerificationMeta(
    'metricType',
  );
  @override
  late final GeneratedColumn<String> metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metricValueMeta = const VerificationMeta(
    'metricValue',
  );
  @override
  late final GeneratedColumn<double> metricValue = GeneratedColumn<double>(
    'metric_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestampUtc,
    metricType,
    metricValue,
    unit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'derived_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DerivedMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp_utc')) {
      context.handle(
        _timestampUtcMeta,
        timestampUtc.isAcceptableOrUnknown(
          data['timestamp_utc']!,
          _timestampUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timestampUtcMeta);
    }
    if (data.containsKey('metric_type')) {
      context.handle(
        _metricTypeMeta,
        metricType.isAcceptableOrUnknown(data['metric_type']!, _metricTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricTypeMeta);
    }
    if (data.containsKey('metric_value')) {
      context.handle(
        _metricValueMeta,
        metricValue.isAcceptableOrUnknown(
          data['metric_value']!,
          _metricValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metricValueMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DerivedMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DerivedMetric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      timestampUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp_utc'],
      )!,
      metricType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_type'],
      )!,
      metricValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}metric_value'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
    );
  }

  @override
  $DerivedMetricsTable createAlias(String alias) {
    return $DerivedMetricsTable(attachedDatabase, alias);
  }
}

class DerivedMetric extends DataClass implements Insertable<DerivedMetric> {
  final int id;
  final int sessionId;
  final DateTime timestampUtc;
  final String metricType;
  final double metricValue;
  final String? unit;
  const DerivedMetric({
    required this.id,
    required this.sessionId,
    required this.timestampUtc,
    required this.metricType,
    required this.metricValue,
    this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['timestamp_utc'] = Variable<DateTime>(timestampUtc);
    map['metric_type'] = Variable<String>(metricType);
    map['metric_value'] = Variable<double>(metricValue);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    return map;
  }

  DerivedMetricsCompanion toCompanion(bool nullToAbsent) {
    return DerivedMetricsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestampUtc: Value(timestampUtc),
      metricType: Value(metricType),
      metricValue: Value(metricValue),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
    );
  }

  factory DerivedMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DerivedMetric(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      timestampUtc: serializer.fromJson<DateTime>(json['timestampUtc']),
      metricType: serializer.fromJson<String>(json['metricType']),
      metricValue: serializer.fromJson<double>(json['metricValue']),
      unit: serializer.fromJson<String?>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'timestampUtc': serializer.toJson<DateTime>(timestampUtc),
      'metricType': serializer.toJson<String>(metricType),
      'metricValue': serializer.toJson<double>(metricValue),
      'unit': serializer.toJson<String?>(unit),
    };
  }

  DerivedMetric copyWith({
    int? id,
    int? sessionId,
    DateTime? timestampUtc,
    String? metricType,
    double? metricValue,
    Value<String?> unit = const Value.absent(),
  }) => DerivedMetric(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestampUtc: timestampUtc ?? this.timestampUtc,
    metricType: metricType ?? this.metricType,
    metricValue: metricValue ?? this.metricValue,
    unit: unit.present ? unit.value : this.unit,
  );
  DerivedMetric copyWithCompanion(DerivedMetricsCompanion data) {
    return DerivedMetric(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestampUtc: data.timestampUtc.present
          ? data.timestampUtc.value
          : this.timestampUtc,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      metricValue: data.metricValue.present
          ? data.metricValue.value
          : this.metricValue,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DerivedMetric(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('metricType: $metricType, ')
          ..write('metricValue: $metricValue, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, timestampUtc, metricType, metricValue, unit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DerivedMetric &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestampUtc == this.timestampUtc &&
          other.metricType == this.metricType &&
          other.metricValue == this.metricValue &&
          other.unit == this.unit);
}

class DerivedMetricsCompanion extends UpdateCompanion<DerivedMetric> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<DateTime> timestampUtc;
  final Value<String> metricType;
  final Value<double> metricValue;
  final Value<String?> unit;
  const DerivedMetricsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestampUtc = const Value.absent(),
    this.metricType = const Value.absent(),
    this.metricValue = const Value.absent(),
    this.unit = const Value.absent(),
  });
  DerivedMetricsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required DateTime timestampUtc,
    required String metricType,
    required double metricValue,
    this.unit = const Value.absent(),
  }) : sessionId = Value(sessionId),
       timestampUtc = Value(timestampUtc),
       metricType = Value(metricType),
       metricValue = Value(metricValue);
  static Insertable<DerivedMetric> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? timestampUtc,
    Expression<String>? metricType,
    Expression<double>? metricValue,
    Expression<String>? unit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestampUtc != null) 'timestamp_utc': timestampUtc,
      if (metricType != null) 'metric_type': metricType,
      if (metricValue != null) 'metric_value': metricValue,
      if (unit != null) 'unit': unit,
    });
  }

  DerivedMetricsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<DateTime>? timestampUtc,
    Value<String>? metricType,
    Value<double>? metricValue,
    Value<String?>? unit,
  }) {
    return DerivedMetricsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestampUtc: timestampUtc ?? this.timestampUtc,
      metricType: metricType ?? this.metricType,
      metricValue: metricValue ?? this.metricValue,
      unit: unit ?? this.unit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (timestampUtc.present) {
      map['timestamp_utc'] = Variable<DateTime>(timestampUtc.value);
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(metricType.value);
    }
    if (metricValue.present) {
      map['metric_value'] = Variable<double>(metricValue.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DerivedMetricsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestampUtc: $timestampUtc, ')
          ..write('metricType: $metricType, ')
          ..write('metricValue: $metricValue, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions (id)',
    ),
  );
  static const VerificationMeta _jobTypeMeta = const VerificationMeta(
    'jobType',
  );
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
    'job_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableAtUtcMeta = const VerificationMeta(
    'availableAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> availableAtUtc =
      GeneratedColumn<DateTime>(
        'available_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    jobType,
    state,
    payloadJson,
    attemptCount,
    createdAtUtc,
    availableAtUtc,
    lastError,
    priority,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('job_type')) {
      context.handle(
        _jobTypeMeta,
        jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('available_at_utc')) {
      context.handle(
        _availableAtUtcMeta,
        availableAtUtc.isAcceptableOrUnknown(
          data['available_at_utc']!,
          _availableAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_availableAtUtcMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      jobType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_type'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      availableAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}available_at_utc'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final int? sessionId;
  final String jobType;
  final String state;
  final String? payloadJson;
  final int attemptCount;
  final DateTime createdAtUtc;
  final DateTime availableAtUtc;
  final String? lastError;
  final int priority;
  const SyncQueueData({
    required this.id,
    this.sessionId,
    required this.jobType,
    required this.state,
    this.payloadJson,
    required this.attemptCount,
    required this.createdAtUtc,
    required this.availableAtUtc,
    this.lastError,
    required this.priority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['job_type'] = Variable<String>(jobType);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['attempt_count'] = Variable<int>(attemptCount);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['available_at_utc'] = Variable<DateTime>(availableAtUtc);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['priority'] = Variable<int>(priority);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      jobType: Value(jobType),
      state: Value(state),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      attemptCount: Value(attemptCount),
      createdAtUtc: Value(createdAtUtc),
      availableAtUtc: Value(availableAtUtc),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      priority: Value(priority),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      jobType: serializer.fromJson<String>(json['jobType']),
      state: serializer.fromJson<String>(json['state']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      availableAtUtc: serializer.fromJson<DateTime>(json['availableAtUtc']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'jobType': serializer.toJson<String>(jobType),
      'state': serializer.toJson<String>(state),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'availableAtUtc': serializer.toJson<DateTime>(availableAtUtc),
      'lastError': serializer.toJson<String?>(lastError),
      'priority': serializer.toJson<int>(priority),
    };
  }

  SyncQueueData copyWith({
    String? id,
    Value<int?> sessionId = const Value.absent(),
    String? jobType,
    String? state,
    Value<String?> payloadJson = const Value.absent(),
    int? attemptCount,
    DateTime? createdAtUtc,
    DateTime? availableAtUtc,
    Value<String?> lastError = const Value.absent(),
    int? priority,
  }) => SyncQueueData(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    jobType: jobType ?? this.jobType,
    state: state ?? this.state,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    attemptCount: attemptCount ?? this.attemptCount,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    availableAtUtc: availableAtUtc ?? this.availableAtUtc,
    lastError: lastError.present ? lastError.value : this.lastError,
    priority: priority ?? this.priority,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      state: data.state.present ? data.state.value : this.state,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      availableAtUtc: data.availableAtUtc.present
          ? data.availableAtUtc.value
          : this.availableAtUtc,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('jobType: $jobType, ')
          ..write('state: $state, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('availableAtUtc: $availableAtUtc, ')
          ..write('lastError: $lastError, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    jobType,
    state,
    payloadJson,
    attemptCount,
    createdAtUtc,
    availableAtUtc,
    lastError,
    priority,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.jobType == this.jobType &&
          other.state == this.state &&
          other.payloadJson == this.payloadJson &&
          other.attemptCount == this.attemptCount &&
          other.createdAtUtc == this.createdAtUtc &&
          other.availableAtUtc == this.availableAtUtc &&
          other.lastError == this.lastError &&
          other.priority == this.priority);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<int?> sessionId;
  final Value<String> jobType;
  final Value<String> state;
  final Value<String?> payloadJson;
  final Value<int> attemptCount;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> availableAtUtc;
  final Value<String?> lastError;
  final Value<int> priority;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.jobType = const Value.absent(),
    this.state = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.availableAtUtc = const Value.absent(),
    this.lastError = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    this.sessionId = const Value.absent(),
    required String jobType,
    required String state,
    this.payloadJson = const Value.absent(),
    this.attemptCount = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime availableAtUtc,
    this.lastError = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobType = Value(jobType),
       state = Value(state),
       createdAtUtc = Value(createdAtUtc),
       availableAtUtc = Value(availableAtUtc);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<int>? sessionId,
    Expression<String>? jobType,
    Expression<String>? state,
    Expression<String>? payloadJson,
    Expression<int>? attemptCount,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? availableAtUtc,
    Expression<String>? lastError,
    Expression<int>? priority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (jobType != null) 'job_type': jobType,
      if (state != null) 'state': state,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (availableAtUtc != null) 'available_at_utc': availableAtUtc,
      if (lastError != null) 'last_error': lastError,
      if (priority != null) 'priority': priority,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<int?>? sessionId,
    Value<String>? jobType,
    Value<String>? state,
    Value<String?>? payloadJson,
    Value<int>? attemptCount,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? availableAtUtc,
    Value<String?>? lastError,
    Value<int>? priority,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      jobType: jobType ?? this.jobType,
      state: state ?? this.state,
      payloadJson: payloadJson ?? this.payloadJson,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      availableAtUtc: availableAtUtc ?? this.availableAtUtc,
      lastError: lastError ?? this.lastError,
      priority: priority ?? this.priority,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (availableAtUtc.present) {
      map['available_at_utc'] = Variable<DateTime>(availableAtUtc.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('jobType: $jobType, ')
          ..write('state: $state, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('availableAtUtc: $availableAtUtc, ')
          ..write('lastError: $lastError, ')
          ..write('priority: $priority, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JudgeActionsTable extends JudgeActions
    with TableInfo<$JudgeActionsTable, JudgeAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JudgeActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions (id)',
    ),
  );
  static const VerificationMeta _raceIdMeta = const VerificationMeta('raceId');
  @override
  late final GeneratedColumn<int> raceId = GeneratedColumn<int>(
    'race_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    raceId,
    actionType,
    payloadJson,
    occurredAtUtc,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'judge_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<JudgeAction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('race_id')) {
      context.handle(
        _raceIdMeta,
        raceId.isAcceptableOrUnknown(data['race_id']!, _raceIdMeta),
      );
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JudgeAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JudgeAction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      raceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}race_id'],
      ),
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      )!,
    );
  }

  @override
  $JudgeActionsTable createAlias(String alias) {
    return $JudgeActionsTable(attachedDatabase, alias);
  }
}

class JudgeAction extends DataClass implements Insertable<JudgeAction> {
  final int id;
  final int? sessionId;
  final int? raceId;
  final String actionType;
  final String payloadJson;
  final DateTime occurredAtUtc;
  final String syncState;
  const JudgeAction({
    required this.id,
    this.sessionId,
    this.raceId,
    required this.actionType,
    required this.payloadJson,
    required this.occurredAtUtc,
    required this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    if (!nullToAbsent || raceId != null) {
      map['race_id'] = Variable<int>(raceId);
    }
    map['action_type'] = Variable<String>(actionType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  JudgeActionsCompanion toCompanion(bool nullToAbsent) {
    return JudgeActionsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      raceId: raceId == null && nullToAbsent
          ? const Value.absent()
          : Value(raceId),
      actionType: Value(actionType),
      payloadJson: Value(payloadJson),
      occurredAtUtc: Value(occurredAtUtc),
      syncState: Value(syncState),
    );
  }

  factory JudgeAction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JudgeAction(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      raceId: serializer.fromJson<int?>(json['raceId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'raceId': serializer.toJson<int?>(raceId),
      'actionType': serializer.toJson<String>(actionType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  JudgeAction copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    Value<int?> raceId = const Value.absent(),
    String? actionType,
    String? payloadJson,
    DateTime? occurredAtUtc,
    String? syncState,
  }) => JudgeAction(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    raceId: raceId.present ? raceId.value : this.raceId,
    actionType: actionType ?? this.actionType,
    payloadJson: payloadJson ?? this.payloadJson,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    syncState: syncState ?? this.syncState,
  );
  JudgeAction copyWithCompanion(JudgeActionsCompanion data) {
    return JudgeAction(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      raceId: data.raceId.present ? data.raceId.value : this.raceId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JudgeAction(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('raceId: $raceId, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    raceId,
    actionType,
    payloadJson,
    occurredAtUtc,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JudgeAction &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.raceId == this.raceId &&
          other.actionType == this.actionType &&
          other.payloadJson == this.payloadJson &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.syncState == this.syncState);
}

class JudgeActionsCompanion extends UpdateCompanion<JudgeAction> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<int?> raceId;
  final Value<String> actionType;
  final Value<String> payloadJson;
  final Value<DateTime> occurredAtUtc;
  final Value<String> syncState;
  const JudgeActionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.raceId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  JudgeActionsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.raceId = const Value.absent(),
    required String actionType,
    required String payloadJson,
    required DateTime occurredAtUtc,
    this.syncState = const Value.absent(),
  }) : actionType = Value(actionType),
       payloadJson = Value(payloadJson),
       occurredAtUtc = Value(occurredAtUtc);
  static Insertable<JudgeAction> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? raceId,
    Expression<String>? actionType,
    Expression<String>? payloadJson,
    Expression<DateTime>? occurredAtUtc,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (raceId != null) 'race_id': raceId,
      if (actionType != null) 'action_type': actionType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  JudgeActionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<int?>? raceId,
    Value<String>? actionType,
    Value<String>? payloadJson,
    Value<DateTime>? occurredAtUtc,
    Value<String>? syncState,
  }) {
    return JudgeActionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      raceId: raceId ?? this.raceId,
      actionType: actionType ?? this.actionType,
      payloadJson: payloadJson ?? this.payloadJson,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (raceId.present) {
      map['race_id'] = Variable<int>(raceId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JudgeActionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('raceId: $raceId, ')
          ..write('actionType: $actionType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $CourseDefinitionsTable extends CourseDefinitions
    with TableInfo<$CourseDefinitionsTable, CourseDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CourseDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _raceIdMeta = const VerificationMeta('raceId');
  @override
  late final GeneratedColumn<int> raceId = GeneratedColumn<int>(
    'race_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    raceId,
    name,
    payloadJson,
    updatedAtUtc,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'course_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CourseDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('race_id')) {
      context.handle(
        _raceIdMeta,
        raceId.isAcceptableOrUnknown(data['race_id']!, _raceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CourseDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CourseDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      raceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}race_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $CourseDefinitionsTable createAlias(String alias) {
    return $CourseDefinitionsTable(attachedDatabase, alias);
  }
}

class CourseDefinition extends DataClass
    implements Insertable<CourseDefinition> {
  final int id;
  final int? raceId;
  final String name;
  final String payloadJson;
  final DateTime updatedAtUtc;
  final int version;
  const CourseDefinition({
    required this.id,
    this.raceId,
    required this.name,
    required this.payloadJson,
    required this.updatedAtUtc,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || raceId != null) {
      map['race_id'] = Variable<int>(raceId);
    }
    map['name'] = Variable<String>(name);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    map['version'] = Variable<int>(version);
    return map;
  }

  CourseDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CourseDefinitionsCompanion(
      id: Value(id),
      raceId: raceId == null && nullToAbsent
          ? const Value.absent()
          : Value(raceId),
      name: Value(name),
      payloadJson: Value(payloadJson),
      updatedAtUtc: Value(updatedAtUtc),
      version: Value(version),
    );
  }

  factory CourseDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CourseDefinition(
      id: serializer.fromJson<int>(json['id']),
      raceId: serializer.fromJson<int?>(json['raceId']),
      name: serializer.fromJson<String>(json['name']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'raceId': serializer.toJson<int?>(raceId),
      'name': serializer.toJson<String>(name),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'version': serializer.toJson<int>(version),
    };
  }

  CourseDefinition copyWith({
    int? id,
    Value<int?> raceId = const Value.absent(),
    String? name,
    String? payloadJson,
    DateTime? updatedAtUtc,
    int? version,
  }) => CourseDefinition(
    id: id ?? this.id,
    raceId: raceId.present ? raceId.value : this.raceId,
    name: name ?? this.name,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    version: version ?? this.version,
  );
  CourseDefinition copyWithCompanion(CourseDefinitionsCompanion data) {
    return CourseDefinition(
      id: data.id.present ? data.id.value : this.id,
      raceId: data.raceId.present ? data.raceId.value : this.raceId,
      name: data.name.present ? data.name.value : this.name,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CourseDefinition(')
          ..write('id: $id, ')
          ..write('raceId: $raceId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, raceId, name, payloadJson, updatedAtUtc, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CourseDefinition &&
          other.id == this.id &&
          other.raceId == this.raceId &&
          other.name == this.name &&
          other.payloadJson == this.payloadJson &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.version == this.version);
}

class CourseDefinitionsCompanion extends UpdateCompanion<CourseDefinition> {
  final Value<int> id;
  final Value<int?> raceId;
  final Value<String> name;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAtUtc;
  final Value<int> version;
  const CourseDefinitionsCompanion({
    this.id = const Value.absent(),
    this.raceId = const Value.absent(),
    this.name = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.version = const Value.absent(),
  });
  CourseDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    this.raceId = const Value.absent(),
    required String name,
    required String payloadJson,
    required DateTime updatedAtUtc,
    this.version = const Value.absent(),
  }) : name = Value(name),
       payloadJson = Value(payloadJson),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<CourseDefinition> custom({
    Expression<int>? id,
    Expression<int>? raceId,
    Expression<String>? name,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (raceId != null) 'race_id': raceId,
      if (name != null) 'name': name,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (version != null) 'version': version,
    });
  }

  CourseDefinitionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? raceId,
    Value<String>? name,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAtUtc,
    Value<int>? version,
  }) {
    return CourseDefinitionsCompanion(
      id: id ?? this.id,
      raceId: raceId ?? this.raceId,
      name: name ?? this.name,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (raceId.present) {
      map['race_id'] = Variable<int>(raceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CourseDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('raceId: $raceId, ')
          ..write('name: $name, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class $ExportJobsTable extends ExportJobs
    with TableInfo<$ExportJobsTable, ExportJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExportJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tracking_sessions (id)',
    ),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diagnosticsTagMeta = const VerificationMeta(
    'diagnosticsTag',
  );
  @override
  late final GeneratedColumn<String> diagnosticsTag = GeneratedColumn<String>(
    'diagnostics_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    format,
    state,
    createdAtUtc,
    completedAtUtc,
    filePath,
    errorMessage,
    diagnosticsTag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'export_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExportJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('diagnostics_tag')) {
      context.handle(
        _diagnosticsTagMeta,
        diagnosticsTag.isAcceptableOrUnknown(
          data['diagnostics_tag']!,
          _diagnosticsTagMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExportJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExportJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      diagnosticsTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnostics_tag'],
      ),
    );
  }

  @override
  $ExportJobsTable createAlias(String alias) {
    return $ExportJobsTable(attachedDatabase, alias);
  }
}

class ExportJob extends DataClass implements Insertable<ExportJob> {
  final int id;
  final int? sessionId;
  final String format;
  final String state;
  final DateTime createdAtUtc;
  final DateTime? completedAtUtc;
  final String? filePath;
  final String? errorMessage;
  final String? diagnosticsTag;
  const ExportJob({
    required this.id,
    this.sessionId,
    required this.format,
    required this.state,
    required this.createdAtUtc,
    this.completedAtUtc,
    this.filePath,
    this.errorMessage,
    this.diagnosticsTag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['format'] = Variable<String>(format);
    map['state'] = Variable<String>(state);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || diagnosticsTag != null) {
      map['diagnostics_tag'] = Variable<String>(diagnosticsTag);
    }
    return map;
  }

  ExportJobsCompanion toCompanion(bool nullToAbsent) {
    return ExportJobsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      format: Value(format),
      state: Value(state),
      createdAtUtc: Value(createdAtUtc),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      diagnosticsTag: diagnosticsTag == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosticsTag),
    );
  }

  factory ExportJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExportJob(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      format: serializer.fromJson<String>(json['format']),
      state: serializer.fromJson<String>(json['state']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      diagnosticsTag: serializer.fromJson<String?>(json['diagnosticsTag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'format': serializer.toJson<String>(format),
      'state': serializer.toJson<String>(state),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'filePath': serializer.toJson<String?>(filePath),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'diagnosticsTag': serializer.toJson<String?>(diagnosticsTag),
    };
  }

  ExportJob copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    String? format,
    String? state,
    DateTime? createdAtUtc,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> diagnosticsTag = const Value.absent(),
  }) => ExportJob(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    format: format ?? this.format,
    state: state ?? this.state,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    filePath: filePath.present ? filePath.value : this.filePath,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    diagnosticsTag: diagnosticsTag.present
        ? diagnosticsTag.value
        : this.diagnosticsTag,
  );
  ExportJob copyWithCompanion(ExportJobsCompanion data) {
    return ExportJob(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      format: data.format.present ? data.format.value : this.format,
      state: data.state.present ? data.state.value : this.state,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      diagnosticsTag: data.diagnosticsTag.present
          ? data.diagnosticsTag.value
          : this.diagnosticsTag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExportJob(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('format: $format, ')
          ..write('state: $state, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('filePath: $filePath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('diagnosticsTag: $diagnosticsTag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    format,
    state,
    createdAtUtc,
    completedAtUtc,
    filePath,
    errorMessage,
    diagnosticsTag,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExportJob &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.format == this.format &&
          other.state == this.state &&
          other.createdAtUtc == this.createdAtUtc &&
          other.completedAtUtc == this.completedAtUtc &&
          other.filePath == this.filePath &&
          other.errorMessage == this.errorMessage &&
          other.diagnosticsTag == this.diagnosticsTag);
}

class ExportJobsCompanion extends UpdateCompanion<ExportJob> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<String> format;
  final Value<String> state;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime?> completedAtUtc;
  final Value<String?> filePath;
  final Value<String?> errorMessage;
  final Value<String?> diagnosticsTag;
  const ExportJobsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.format = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.filePath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.diagnosticsTag = const Value.absent(),
  });
  ExportJobsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String format,
    required String state,
    required DateTime createdAtUtc,
    this.completedAtUtc = const Value.absent(),
    this.filePath = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.diagnosticsTag = const Value.absent(),
  }) : format = Value(format),
       state = Value(state),
       createdAtUtc = Value(createdAtUtc);
  static Insertable<ExportJob> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? format,
    Expression<String>? state,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? completedAtUtc,
    Expression<String>? filePath,
    Expression<String>? errorMessage,
    Expression<String>? diagnosticsTag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (format != null) 'format': format,
      if (state != null) 'state': state,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (filePath != null) 'file_path': filePath,
      if (errorMessage != null) 'error_message': errorMessage,
      if (diagnosticsTag != null) 'diagnostics_tag': diagnosticsTag,
    });
  }

  ExportJobsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<String>? format,
    Value<String>? state,
    Value<DateTime>? createdAtUtc,
    Value<DateTime?>? completedAtUtc,
    Value<String?>? filePath,
    Value<String?>? errorMessage,
    Value<String?>? diagnosticsTag,
  }) {
    return ExportJobsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      format: format ?? this.format,
      state: state ?? this.state,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
      diagnosticsTag: diagnosticsTag ?? this.diagnosticsTag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (diagnosticsTag.present) {
      map['diagnostics_tag'] = Variable<String>(diagnosticsTag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExportJobsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('format: $format, ')
          ..write('state: $state, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('filePath: $filePath, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('diagnosticsTag: $diagnosticsTag')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAtUtc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String? value;
  final DateTime updatedAtUtc;
  const AppSetting({required this.key, this.value, required this.updatedAtUtc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  AppSetting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
    DateTime? updatedAtUtc,
  }) => AppSetting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAtUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrackingSessionsTable trackingSessions = $TrackingSessionsTable(
    this,
  );
  late final $GpsPointsTable gpsPoints = $GpsPointsTable(this);
  late final $ImuChunksTable imuChunks = $ImuChunksTable(this);
  late final $DerivedMetricsTable derivedMetrics = $DerivedMetricsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $JudgeActionsTable judgeActions = $JudgeActionsTable(this);
  late final $CourseDefinitionsTable courseDefinitions =
      $CourseDefinitionsTable(this);
  late final $ExportJobsTable exportJobs = $ExportJobsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final TrackingSessionDao trackingSessionDao = TrackingSessionDao(
    this as AppDatabase,
  );
  late final TrackingPointDao trackingPointDao = TrackingPointDao(
    this as AppDatabase,
  );
  late final ImuChunkDao imuChunkDao = ImuChunkDao(this as AppDatabase);
  late final DerivedMetricDao derivedMetricDao = DerivedMetricDao(
    this as AppDatabase,
  );
  late final CourseDefinitionDao courseDefinitionDao = CourseDefinitionDao(
    this as AppDatabase,
  );
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final JudgeActionDao judgeActionDao = JudgeActionDao(
    this as AppDatabase,
  );
  late final AppSettingsDao appSettingsDao = AppSettingsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trackingSessions,
    gpsPoints,
    imuChunks,
    derivedMetrics,
    syncQueue,
    judgeActions,
    courseDefinitions,
    exportJobs,
    appSettings,
  ];
}

typedef $$TrackingSessionsTableCreateCompanionBuilder =
    TrackingSessionsCompanion Function({
      Value<int> id,
      required int raceId,
      required String role,
      required String state,
      required int intervalSeconds,
      required DateTime startedAtUtc,
      Value<DateTime?> endedAtUtc,
      Value<String?> failureReason,
      Value<DateTime?> lastSyncAtUtc,
      Value<String?> sensorHealthSnapshot,
    });
typedef $$TrackingSessionsTableUpdateCompanionBuilder =
    TrackingSessionsCompanion Function({
      Value<int> id,
      Value<int> raceId,
      Value<String> role,
      Value<String> state,
      Value<int> intervalSeconds,
      Value<DateTime> startedAtUtc,
      Value<DateTime?> endedAtUtc,
      Value<String?> failureReason,
      Value<DateTime?> lastSyncAtUtc,
      Value<String?> sensorHealthSnapshot,
    });

final class $$TrackingSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TrackingSessionsTable, TrackingSession> {
  $$TrackingSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$GpsPointsTable, List<GpsPoint>>
  _gpsPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gpsPoints,
    aliasName: $_aliasNameGenerator(
      db.trackingSessions.id,
      db.gpsPoints.sessionId,
    ),
  );

  $$GpsPointsTableProcessedTableManager get gpsPointsRefs {
    final manager = $$GpsPointsTableTableManager(
      $_db,
      $_db.gpsPoints,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gpsPointsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImuChunksTable, List<ImuChunk>>
  _imuChunksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.imuChunks,
    aliasName: $_aliasNameGenerator(
      db.trackingSessions.id,
      db.imuChunks.sessionId,
    ),
  );

  $$ImuChunksTableProcessedTableManager get imuChunksRefs {
    final manager = $$ImuChunksTableTableManager(
      $_db,
      $_db.imuChunks,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_imuChunksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DerivedMetricsTable, List<DerivedMetric>>
  _derivedMetricsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.derivedMetrics,
    aliasName: $_aliasNameGenerator(
      db.trackingSessions.id,
      db.derivedMetrics.sessionId,
    ),
  );

  $$DerivedMetricsTableProcessedTableManager get derivedMetricsRefs {
    final manager = $$DerivedMetricsTableTableManager(
      $_db,
      $_db.derivedMetrics,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_derivedMetricsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SyncQueueTable, List<SyncQueueData>>
  _syncQueueRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.syncQueue,
    aliasName: $_aliasNameGenerator(
      db.trackingSessions.id,
      db.syncQueue.sessionId,
    ),
  );

  $$SyncQueueTableProcessedTableManager get syncQueueRefs {
    final manager = $$SyncQueueTableTableManager(
      $_db,
      $_db.syncQueue,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_syncQueueRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$JudgeActionsTable, List<JudgeAction>>
  _judgeActionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.judgeActions,
    aliasName: $_aliasNameGenerator(
      db.trackingSessions.id,
      db.judgeActions.sessionId,
    ),
  );

  $$JudgeActionsTableProcessedTableManager get judgeActionsRefs {
    final manager = $$JudgeActionsTableTableManager(
      $_db,
      $_db.judgeActions,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_judgeActionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExportJobsTable, List<ExportJob>>
  _exportJobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exportJobs,
    aliasName: $_aliasNameGenerator(
      db.trackingSessions.id,
      db.exportJobs.sessionId,
    ),
  );

  $$ExportJobsTableProcessedTableManager get exportJobsRefs {
    final manager = $$ExportJobsTableTableManager(
      $_db,
      $_db.exportJobs,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exportJobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTable> {
  $$TrackingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalSeconds => $composableBuilder(
    column: $table.intervalSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAtUtc => $composableBuilder(
    column: $table.lastSyncAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sensorHealthSnapshot => $composableBuilder(
    column: $table.sensorHealthSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gpsPointsRefs(
    Expression<bool> Function($$GpsPointsTableFilterComposer f) f,
  ) {
    final $$GpsPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gpsPoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GpsPointsTableFilterComposer(
            $db: $db,
            $table: $db.gpsPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imuChunksRefs(
    Expression<bool> Function($$ImuChunksTableFilterComposer f) f,
  ) {
    final $$ImuChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imuChunks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImuChunksTableFilterComposer(
            $db: $db,
            $table: $db.imuChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> derivedMetricsRefs(
    Expression<bool> Function($$DerivedMetricsTableFilterComposer f) f,
  ) {
    final $$DerivedMetricsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.derivedMetrics,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DerivedMetricsTableFilterComposer(
            $db: $db,
            $table: $db.derivedMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> syncQueueRefs(
    Expression<bool> Function($$SyncQueueTableFilterComposer f) f,
  ) {
    final $$SyncQueueTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncQueue,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncQueueTableFilterComposer(
            $db: $db,
            $table: $db.syncQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> judgeActionsRefs(
    Expression<bool> Function($$JudgeActionsTableFilterComposer f) f,
  ) {
    final $$JudgeActionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.judgeActions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JudgeActionsTableFilterComposer(
            $db: $db,
            $table: $db.judgeActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exportJobsRefs(
    Expression<bool> Function($$ExportJobsTableFilterComposer f) f,
  ) {
    final $$ExportJobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportJobs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportJobsTableFilterComposer(
            $db: $db,
            $table: $db.exportJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTable> {
  $$TrackingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalSeconds => $composableBuilder(
    column: $table.intervalSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAtUtc => $composableBuilder(
    column: $table.lastSyncAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sensorHealthSnapshot => $composableBuilder(
    column: $table.sensorHealthSnapshot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackingSessionsTable> {
  $$TrackingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get raceId =>
      $composableBuilder(column: $table.raceId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get intervalSeconds => $composableBuilder(
    column: $table.intervalSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAtUtc => $composableBuilder(
    column: $table.lastSyncAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sensorHealthSnapshot => $composableBuilder(
    column: $table.sensorHealthSnapshot,
    builder: (column) => column,
  );

  Expression<T> gpsPointsRefs<T extends Object>(
    Expression<T> Function($$GpsPointsTableAnnotationComposer a) f,
  ) {
    final $$GpsPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gpsPoints,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GpsPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.gpsPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> imuChunksRefs<T extends Object>(
    Expression<T> Function($$ImuChunksTableAnnotationComposer a) f,
  ) {
    final $$ImuChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.imuChunks,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImuChunksTableAnnotationComposer(
            $db: $db,
            $table: $db.imuChunks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> derivedMetricsRefs<T extends Object>(
    Expression<T> Function($$DerivedMetricsTableAnnotationComposer a) f,
  ) {
    final $$DerivedMetricsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.derivedMetrics,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DerivedMetricsTableAnnotationComposer(
            $db: $db,
            $table: $db.derivedMetrics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> syncQueueRefs<T extends Object>(
    Expression<T> Function($$SyncQueueTableAnnotationComposer a) f,
  ) {
    final $$SyncQueueTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.syncQueue,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SyncQueueTableAnnotationComposer(
            $db: $db,
            $table: $db.syncQueue,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> judgeActionsRefs<T extends Object>(
    Expression<T> Function($$JudgeActionsTableAnnotationComposer a) f,
  ) {
    final $$JudgeActionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.judgeActions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$JudgeActionsTableAnnotationComposer(
            $db: $db,
            $table: $db.judgeActions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exportJobsRefs<T extends Object>(
    Expression<T> Function($$ExportJobsTableAnnotationComposer a) f,
  ) {
    final $$ExportJobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exportJobs,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExportJobsTableAnnotationComposer(
            $db: $db,
            $table: $db.exportJobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackingSessionsTable,
          TrackingSession,
          $$TrackingSessionsTableFilterComposer,
          $$TrackingSessionsTableOrderingComposer,
          $$TrackingSessionsTableAnnotationComposer,
          $$TrackingSessionsTableCreateCompanionBuilder,
          $$TrackingSessionsTableUpdateCompanionBuilder,
          (TrackingSession, $$TrackingSessionsTableReferences),
          TrackingSession,
          PrefetchHooks Function({
            bool gpsPointsRefs,
            bool imuChunksRefs,
            bool derivedMetricsRefs,
            bool syncQueueRefs,
            bool judgeActionsRefs,
            bool exportJobsRefs,
          })
        > {
  $$TrackingSessionsTableTableManager(
    _$AppDatabase db,
    $TrackingSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> raceId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> intervalSeconds = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime?> endedAtUtc = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime?> lastSyncAtUtc = const Value.absent(),
                Value<String?> sensorHealthSnapshot = const Value.absent(),
              }) => TrackingSessionsCompanion(
                id: id,
                raceId: raceId,
                role: role,
                state: state,
                intervalSeconds: intervalSeconds,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
                failureReason: failureReason,
                lastSyncAtUtc: lastSyncAtUtc,
                sensorHealthSnapshot: sensorHealthSnapshot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int raceId,
                required String role,
                required String state,
                required int intervalSeconds,
                required DateTime startedAtUtc,
                Value<DateTime?> endedAtUtc = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<DateTime?> lastSyncAtUtc = const Value.absent(),
                Value<String?> sensorHealthSnapshot = const Value.absent(),
              }) => TrackingSessionsCompanion.insert(
                id: id,
                raceId: raceId,
                role: role,
                state: state,
                intervalSeconds: intervalSeconds,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
                failureReason: failureReason,
                lastSyncAtUtc: lastSyncAtUtc,
                sensorHealthSnapshot: sensorHealthSnapshot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TrackingSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gpsPointsRefs = false,
                imuChunksRefs = false,
                derivedMetricsRefs = false,
                syncQueueRefs = false,
                judgeActionsRefs = false,
                exportJobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gpsPointsRefs) db.gpsPoints,
                    if (imuChunksRefs) db.imuChunks,
                    if (derivedMetricsRefs) db.derivedMetrics,
                    if (syncQueueRefs) db.syncQueue,
                    if (judgeActionsRefs) db.judgeActions,
                    if (exportJobsRefs) db.exportJobs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gpsPointsRefs)
                        await $_getPrefetchedData<
                          TrackingSession,
                          $TrackingSessionsTable,
                          GpsPoint
                        >(
                          currentTable: table,
                          referencedTable: $$TrackingSessionsTableReferences
                              ._gpsPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).gpsPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imuChunksRefs)
                        await $_getPrefetchedData<
                          TrackingSession,
                          $TrackingSessionsTable,
                          ImuChunk
                        >(
                          currentTable: table,
                          referencedTable: $$TrackingSessionsTableReferences
                              ._imuChunksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).imuChunksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (derivedMetricsRefs)
                        await $_getPrefetchedData<
                          TrackingSession,
                          $TrackingSessionsTable,
                          DerivedMetric
                        >(
                          currentTable: table,
                          referencedTable: $$TrackingSessionsTableReferences
                              ._derivedMetricsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).derivedMetricsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (syncQueueRefs)
                        await $_getPrefetchedData<
                          TrackingSession,
                          $TrackingSessionsTable,
                          SyncQueueData
                        >(
                          currentTable: table,
                          referencedTable: $$TrackingSessionsTableReferences
                              ._syncQueueRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).syncQueueRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (judgeActionsRefs)
                        await $_getPrefetchedData<
                          TrackingSession,
                          $TrackingSessionsTable,
                          JudgeAction
                        >(
                          currentTable: table,
                          referencedTable: $$TrackingSessionsTableReferences
                              ._judgeActionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).judgeActionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exportJobsRefs)
                        await $_getPrefetchedData<
                          TrackingSession,
                          $TrackingSessionsTable,
                          ExportJob
                        >(
                          currentTable: table,
                          referencedTable: $$TrackingSessionsTableReferences
                              ._exportJobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TrackingSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).exportJobsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TrackingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackingSessionsTable,
      TrackingSession,
      $$TrackingSessionsTableFilterComposer,
      $$TrackingSessionsTableOrderingComposer,
      $$TrackingSessionsTableAnnotationComposer,
      $$TrackingSessionsTableCreateCompanionBuilder,
      $$TrackingSessionsTableUpdateCompanionBuilder,
      (TrackingSession, $$TrackingSessionsTableReferences),
      TrackingSession,
      PrefetchHooks Function({
        bool gpsPointsRefs,
        bool imuChunksRefs,
        bool derivedMetricsRefs,
        bool syncQueueRefs,
        bool judgeActionsRefs,
        bool exportJobsRefs,
      })
    >;
typedef $$GpsPointsTableCreateCompanionBuilder =
    GpsPointsCompanion Function({
      Value<int> id,
      required int sessionId,
      required DateTime timestampUtc,
      required double longitude,
      required double latitude,
      Value<double?> accuracyMeters,
      Value<double?> speedMetersPerSecond,
    });
typedef $$GpsPointsTableUpdateCompanionBuilder =
    GpsPointsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<DateTime> timestampUtc,
      Value<double> longitude,
      Value<double> latitude,
      Value<double?> accuracyMeters,
      Value<double?> speedMetersPerSecond,
    });

final class $$GpsPointsTableReferences
    extends BaseReferences<_$AppDatabase, $GpsPointsTable, GpsPoint> {
  $$GpsPointsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessions.createAlias(
        $_aliasNameGenerator(db.gpsPoints.sessionId, db.trackingSessions.id),
      );

  $$TrackingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrackingSessionsTableTableManager(
      $_db,
      $_db.trackingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GpsPointsTableFilterComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableFilterComposer get sessionId {
    final $$TrackingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GpsPointsTable> {
  $$GpsPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get accuracyMeters => $composableBuilder(
    column: $table.accuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => column,
  );

  $$TrackingSessionsTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GpsPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GpsPointsTable,
          GpsPoint,
          $$GpsPointsTableFilterComposer,
          $$GpsPointsTableOrderingComposer,
          $$GpsPointsTableAnnotationComposer,
          $$GpsPointsTableCreateCompanionBuilder,
          $$GpsPointsTableUpdateCompanionBuilder,
          (GpsPoint, $$GpsPointsTableReferences),
          GpsPoint,
          PrefetchHooks Function({bool sessionId})
        > {
  $$GpsPointsTableTableManager(_$AppDatabase db, $GpsPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GpsPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GpsPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GpsPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> timestampUtc = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double?> accuracyMeters = const Value.absent(),
                Value<double?> speedMetersPerSecond = const Value.absent(),
              }) => GpsPointsCompanion(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                longitude: longitude,
                latitude: latitude,
                accuracyMeters: accuracyMeters,
                speedMetersPerSecond: speedMetersPerSecond,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required DateTime timestampUtc,
                required double longitude,
                required double latitude,
                Value<double?> accuracyMeters = const Value.absent(),
                Value<double?> speedMetersPerSecond = const Value.absent(),
              }) => GpsPointsCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                longitude: longitude,
                latitude: latitude,
                accuracyMeters: accuracyMeters,
                speedMetersPerSecond: speedMetersPerSecond,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GpsPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$GpsPointsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$GpsPointsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GpsPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GpsPointsTable,
      GpsPoint,
      $$GpsPointsTableFilterComposer,
      $$GpsPointsTableOrderingComposer,
      $$GpsPointsTableAnnotationComposer,
      $$GpsPointsTableCreateCompanionBuilder,
      $$GpsPointsTableUpdateCompanionBuilder,
      (GpsPoint, $$GpsPointsTableReferences),
      GpsPoint,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$ImuChunksTableCreateCompanionBuilder =
    ImuChunksCompanion Function({
      Value<int> id,
      required int sessionId,
      required DateTime capturedAtUtc,
      required int chunkStartMonotonicNs,
      required int sampleCount,
      required int samplingHz,
      Value<String> payloadFormat,
      required Uint8List payload,
    });
typedef $$ImuChunksTableUpdateCompanionBuilder =
    ImuChunksCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<DateTime> capturedAtUtc,
      Value<int> chunkStartMonotonicNs,
      Value<int> sampleCount,
      Value<int> samplingHz,
      Value<String> payloadFormat,
      Value<Uint8List> payload,
    });

final class $$ImuChunksTableReferences
    extends BaseReferences<_$AppDatabase, $ImuChunksTable, ImuChunk> {
  $$ImuChunksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessions.createAlias(
        $_aliasNameGenerator(db.imuChunks.sessionId, db.trackingSessions.id),
      );

  $$TrackingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrackingSessionsTableTableManager(
      $_db,
      $_db.trackingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImuChunksTableFilterComposer
    extends Composer<_$AppDatabase, $ImuChunksTable> {
  $$ImuChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chunkStartMonotonicNs => $composableBuilder(
    column: $table.chunkStartMonotonicNs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get samplingHz => $composableBuilder(
    column: $table.samplingHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadFormat => $composableBuilder(
    column: $table.payloadFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableFilterComposer get sessionId {
    final $$TrackingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImuChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $ImuChunksTable> {
  $$ImuChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chunkStartMonotonicNs => $composableBuilder(
    column: $table.chunkStartMonotonicNs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get samplingHz => $composableBuilder(
    column: $table.samplingHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadFormat => $composableBuilder(
    column: $table.payloadFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImuChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImuChunksTable> {
  $$ImuChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAtUtc => $composableBuilder(
    column: $table.capturedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chunkStartMonotonicNs => $composableBuilder(
    column: $table.chunkStartMonotonicNs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get samplingHz => $composableBuilder(
    column: $table.samplingHz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadFormat => $composableBuilder(
    column: $table.payloadFormat,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  $$TrackingSessionsTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImuChunksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImuChunksTable,
          ImuChunk,
          $$ImuChunksTableFilterComposer,
          $$ImuChunksTableOrderingComposer,
          $$ImuChunksTableAnnotationComposer,
          $$ImuChunksTableCreateCompanionBuilder,
          $$ImuChunksTableUpdateCompanionBuilder,
          (ImuChunk, $$ImuChunksTableReferences),
          ImuChunk,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ImuChunksTableTableManager(_$AppDatabase db, $ImuChunksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImuChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImuChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImuChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> capturedAtUtc = const Value.absent(),
                Value<int> chunkStartMonotonicNs = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<int> samplingHz = const Value.absent(),
                Value<String> payloadFormat = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
              }) => ImuChunksCompanion(
                id: id,
                sessionId: sessionId,
                capturedAtUtc: capturedAtUtc,
                chunkStartMonotonicNs: chunkStartMonotonicNs,
                sampleCount: sampleCount,
                samplingHz: samplingHz,
                payloadFormat: payloadFormat,
                payload: payload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required DateTime capturedAtUtc,
                required int chunkStartMonotonicNs,
                required int sampleCount,
                required int samplingHz,
                Value<String> payloadFormat = const Value.absent(),
                required Uint8List payload,
              }) => ImuChunksCompanion.insert(
                id: id,
                sessionId: sessionId,
                capturedAtUtc: capturedAtUtc,
                chunkStartMonotonicNs: chunkStartMonotonicNs,
                sampleCount: sampleCount,
                samplingHz: samplingHz,
                payloadFormat: payloadFormat,
                payload: payload,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImuChunksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ImuChunksTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ImuChunksTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImuChunksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImuChunksTable,
      ImuChunk,
      $$ImuChunksTableFilterComposer,
      $$ImuChunksTableOrderingComposer,
      $$ImuChunksTableAnnotationComposer,
      $$ImuChunksTableCreateCompanionBuilder,
      $$ImuChunksTableUpdateCompanionBuilder,
      (ImuChunk, $$ImuChunksTableReferences),
      ImuChunk,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$DerivedMetricsTableCreateCompanionBuilder =
    DerivedMetricsCompanion Function({
      Value<int> id,
      required int sessionId,
      required DateTime timestampUtc,
      required String metricType,
      required double metricValue,
      Value<String?> unit,
    });
typedef $$DerivedMetricsTableUpdateCompanionBuilder =
    DerivedMetricsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<DateTime> timestampUtc,
      Value<String> metricType,
      Value<double> metricValue,
      Value<String?> unit,
    });

final class $$DerivedMetricsTableReferences
    extends BaseReferences<_$AppDatabase, $DerivedMetricsTable, DerivedMetric> {
  $$DerivedMetricsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TrackingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessions.createAlias(
        $_aliasNameGenerator(
          db.derivedMetrics.sessionId,
          db.trackingSessions.id,
        ),
      );

  $$TrackingSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$TrackingSessionsTableTableManager(
      $_db,
      $_db.trackingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DerivedMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $DerivedMetricsTable> {
  $$DerivedMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get metricValue => $composableBuilder(
    column: $table.metricValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableFilterComposer get sessionId {
    final $$TrackingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DerivedMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $DerivedMetricsTable> {
  $$DerivedMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get metricValue => $composableBuilder(
    column: $table.metricValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DerivedMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DerivedMetricsTable> {
  $$DerivedMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestampUtc => $composableBuilder(
    column: $table.timestampUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get metricValue => $composableBuilder(
    column: $table.metricValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  $$TrackingSessionsTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DerivedMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DerivedMetricsTable,
          DerivedMetric,
          $$DerivedMetricsTableFilterComposer,
          $$DerivedMetricsTableOrderingComposer,
          $$DerivedMetricsTableAnnotationComposer,
          $$DerivedMetricsTableCreateCompanionBuilder,
          $$DerivedMetricsTableUpdateCompanionBuilder,
          (DerivedMetric, $$DerivedMetricsTableReferences),
          DerivedMetric,
          PrefetchHooks Function({bool sessionId})
        > {
  $$DerivedMetricsTableTableManager(
    _$AppDatabase db,
    $DerivedMetricsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DerivedMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DerivedMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DerivedMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> timestampUtc = const Value.absent(),
                Value<String> metricType = const Value.absent(),
                Value<double> metricValue = const Value.absent(),
                Value<String?> unit = const Value.absent(),
              }) => DerivedMetricsCompanion(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                metricType: metricType,
                metricValue: metricValue,
                unit: unit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required DateTime timestampUtc,
                required String metricType,
                required double metricValue,
                Value<String?> unit = const Value.absent(),
              }) => DerivedMetricsCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestampUtc: timestampUtc,
                metricType: metricType,
                metricValue: metricValue,
                unit: unit,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DerivedMetricsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$DerivedMetricsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn:
                                    $$DerivedMetricsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DerivedMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DerivedMetricsTable,
      DerivedMetric,
      $$DerivedMetricsTableFilterComposer,
      $$DerivedMetricsTableOrderingComposer,
      $$DerivedMetricsTableAnnotationComposer,
      $$DerivedMetricsTableCreateCompanionBuilder,
      $$DerivedMetricsTableUpdateCompanionBuilder,
      (DerivedMetric, $$DerivedMetricsTableReferences),
      DerivedMetric,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      required String id,
      Value<int?> sessionId,
      required String jobType,
      required String state,
      Value<String?> payloadJson,
      Value<int> attemptCount,
      required DateTime createdAtUtc,
      required DateTime availableAtUtc,
      Value<String?> lastError,
      Value<int> priority,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<int?> sessionId,
      Value<String> jobType,
      Value<String> state,
      Value<String?> payloadJson,
      Value<int> attemptCount,
      Value<DateTime> createdAtUtc,
      Value<DateTime> availableAtUtc,
      Value<String?> lastError,
      Value<int> priority,
      Value<int> rowid,
    });

final class $$SyncQueueTableReferences
    extends BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData> {
  $$SyncQueueTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessions.createAlias(
        $_aliasNameGenerator(db.syncQueue.sessionId, db.trackingSessions.id),
      );

  $$TrackingSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$TrackingSessionsTableTableManager(
      $_db,
      $_db.trackingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get availableAtUtc => $composableBuilder(
    column: $table.availableAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableFilterComposer get sessionId {
    final $$TrackingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get availableAtUtc => $composableBuilder(
    column: $table.availableAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get availableAtUtc => $composableBuilder(
    column: $table.availableAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  $$TrackingSessionsTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (SyncQueueData, $$SyncQueueTableReferences),
          SyncQueueData,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> availableAtUtc = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                sessionId: sessionId,
                jobType: jobType,
                state: state,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                createdAtUtc: createdAtUtc,
                availableAtUtc: availableAtUtc,
                lastError: lastError,
                priority: priority,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> sessionId = const Value.absent(),
                required String jobType,
                required String state,
                Value<String?> payloadJson = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime availableAtUtc,
                Value<String?> lastError = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                sessionId: sessionId,
                jobType: jobType,
                state: state,
                payloadJson: payloadJson,
                attemptCount: attemptCount,
                createdAtUtc: createdAtUtc,
                availableAtUtc: availableAtUtc,
                lastError: lastError,
                priority: priority,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SyncQueueTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$SyncQueueTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$SyncQueueTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (SyncQueueData, $$SyncQueueTableReferences),
      SyncQueueData,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$JudgeActionsTableCreateCompanionBuilder =
    JudgeActionsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<int?> raceId,
      required String actionType,
      required String payloadJson,
      required DateTime occurredAtUtc,
      Value<String> syncState,
    });
typedef $$JudgeActionsTableUpdateCompanionBuilder =
    JudgeActionsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<int?> raceId,
      Value<String> actionType,
      Value<String> payloadJson,
      Value<DateTime> occurredAtUtc,
      Value<String> syncState,
    });

final class $$JudgeActionsTableReferences
    extends BaseReferences<_$AppDatabase, $JudgeActionsTable, JudgeAction> {
  $$JudgeActionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessions.createAlias(
        $_aliasNameGenerator(db.judgeActions.sessionId, db.trackingSessions.id),
      );

  $$TrackingSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$TrackingSessionsTableTableManager(
      $_db,
      $_db.trackingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$JudgeActionsTableFilterComposer
    extends Composer<_$AppDatabase, $JudgeActionsTable> {
  $$JudgeActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableFilterComposer get sessionId {
    final $$TrackingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JudgeActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $JudgeActionsTable> {
  $$JudgeActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JudgeActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $JudgeActionsTable> {
  $$JudgeActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get raceId =>
      $composableBuilder(column: $table.raceId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$TrackingSessionsTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$JudgeActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JudgeActionsTable,
          JudgeAction,
          $$JudgeActionsTableFilterComposer,
          $$JudgeActionsTableOrderingComposer,
          $$JudgeActionsTableAnnotationComposer,
          $$JudgeActionsTableCreateCompanionBuilder,
          $$JudgeActionsTableUpdateCompanionBuilder,
          (JudgeAction, $$JudgeActionsTableReferences),
          JudgeAction,
          PrefetchHooks Function({bool sessionId})
        > {
  $$JudgeActionsTableTableManager(_$AppDatabase db, $JudgeActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JudgeActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JudgeActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JudgeActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> raceId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<String> syncState = const Value.absent(),
              }) => JudgeActionsCompanion(
                id: id,
                sessionId: sessionId,
                raceId: raceId,
                actionType: actionType,
                payloadJson: payloadJson,
                occurredAtUtc: occurredAtUtc,
                syncState: syncState,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> raceId = const Value.absent(),
                required String actionType,
                required String payloadJson,
                required DateTime occurredAtUtc,
                Value<String> syncState = const Value.absent(),
              }) => JudgeActionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                raceId: raceId,
                actionType: actionType,
                payloadJson: payloadJson,
                occurredAtUtc: occurredAtUtc,
                syncState: syncState,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$JudgeActionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$JudgeActionsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$JudgeActionsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$JudgeActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JudgeActionsTable,
      JudgeAction,
      $$JudgeActionsTableFilterComposer,
      $$JudgeActionsTableOrderingComposer,
      $$JudgeActionsTableAnnotationComposer,
      $$JudgeActionsTableCreateCompanionBuilder,
      $$JudgeActionsTableUpdateCompanionBuilder,
      (JudgeAction, $$JudgeActionsTableReferences),
      JudgeAction,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$CourseDefinitionsTableCreateCompanionBuilder =
    CourseDefinitionsCompanion Function({
      Value<int> id,
      Value<int?> raceId,
      required String name,
      required String payloadJson,
      required DateTime updatedAtUtc,
      Value<int> version,
    });
typedef $$CourseDefinitionsTableUpdateCompanionBuilder =
    CourseDefinitionsCompanion Function({
      Value<int> id,
      Value<int?> raceId,
      Value<String> name,
      Value<String> payloadJson,
      Value<DateTime> updatedAtUtc,
      Value<int> version,
    });

class $$CourseDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CourseDefinitionsTable> {
  $$CourseDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CourseDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CourseDefinitionsTable> {
  $$CourseDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get raceId => $composableBuilder(
    column: $table.raceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CourseDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CourseDefinitionsTable> {
  $$CourseDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get raceId =>
      $composableBuilder(column: $table.raceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$CourseDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CourseDefinitionsTable,
          CourseDefinition,
          $$CourseDefinitionsTableFilterComposer,
          $$CourseDefinitionsTableOrderingComposer,
          $$CourseDefinitionsTableAnnotationComposer,
          $$CourseDefinitionsTableCreateCompanionBuilder,
          $$CourseDefinitionsTableUpdateCompanionBuilder,
          (
            CourseDefinition,
            BaseReferences<
              _$AppDatabase,
              $CourseDefinitionsTable,
              CourseDefinition
            >,
          ),
          CourseDefinition,
          PrefetchHooks Function()
        > {
  $$CourseDefinitionsTableTableManager(
    _$AppDatabase db,
    $CourseDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CourseDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CourseDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CourseDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> raceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> version = const Value.absent(),
              }) => CourseDefinitionsCompanion(
                id: id,
                raceId: raceId,
                name: name,
                payloadJson: payloadJson,
                updatedAtUtc: updatedAtUtc,
                version: version,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> raceId = const Value.absent(),
                required String name,
                required String payloadJson,
                required DateTime updatedAtUtc,
                Value<int> version = const Value.absent(),
              }) => CourseDefinitionsCompanion.insert(
                id: id,
                raceId: raceId,
                name: name,
                payloadJson: payloadJson,
                updatedAtUtc: updatedAtUtc,
                version: version,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CourseDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CourseDefinitionsTable,
      CourseDefinition,
      $$CourseDefinitionsTableFilterComposer,
      $$CourseDefinitionsTableOrderingComposer,
      $$CourseDefinitionsTableAnnotationComposer,
      $$CourseDefinitionsTableCreateCompanionBuilder,
      $$CourseDefinitionsTableUpdateCompanionBuilder,
      (
        CourseDefinition,
        BaseReferences<
          _$AppDatabase,
          $CourseDefinitionsTable,
          CourseDefinition
        >,
      ),
      CourseDefinition,
      PrefetchHooks Function()
    >;
typedef $$ExportJobsTableCreateCompanionBuilder =
    ExportJobsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      required String format,
      required String state,
      required DateTime createdAtUtc,
      Value<DateTime?> completedAtUtc,
      Value<String?> filePath,
      Value<String?> errorMessage,
      Value<String?> diagnosticsTag,
    });
typedef $$ExportJobsTableUpdateCompanionBuilder =
    ExportJobsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<String> format,
      Value<String> state,
      Value<DateTime> createdAtUtc,
      Value<DateTime?> completedAtUtc,
      Value<String?> filePath,
      Value<String?> errorMessage,
      Value<String?> diagnosticsTag,
    });

final class $$ExportJobsTableReferences
    extends BaseReferences<_$AppDatabase, $ExportJobsTable, ExportJob> {
  $$ExportJobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TrackingSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.trackingSessions.createAlias(
        $_aliasNameGenerator(db.exportJobs.sessionId, db.trackingSessions.id),
      );

  $$TrackingSessionsTableProcessedTableManager? get sessionId {
    final $_column = $_itemColumn<int>('session_id');
    if ($_column == null) return null;
    final manager = $$TrackingSessionsTableTableManager(
      $_db,
      $_db.trackingSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExportJobsTableFilterComposer
    extends Composer<_$AppDatabase, $ExportJobsTable> {
  $$ExportJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosticsTag => $composableBuilder(
    column: $table.diagnosticsTag,
    builder: (column) => ColumnFilters(column),
  );

  $$TrackingSessionsTableFilterComposer get sessionId {
    final $$TrackingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExportJobsTable> {
  $$ExportJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosticsTag => $composableBuilder(
    column: $table.diagnosticsTag,
    builder: (column) => ColumnOrderings(column),
  );

  $$TrackingSessionsTableOrderingComposer get sessionId {
    final $$TrackingSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExportJobsTable> {
  $$ExportJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diagnosticsTag => $composableBuilder(
    column: $table.diagnosticsTag,
    builder: (column) => column,
  );

  $$TrackingSessionsTableAnnotationComposer get sessionId {
    final $$TrackingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.trackingSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.trackingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExportJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExportJobsTable,
          ExportJob,
          $$ExportJobsTableFilterComposer,
          $$ExportJobsTableOrderingComposer,
          $$ExportJobsTableAnnotationComposer,
          $$ExportJobsTableCreateCompanionBuilder,
          $$ExportJobsTableUpdateCompanionBuilder,
          (ExportJob, $$ExportJobsTableReferences),
          ExportJob,
          PrefetchHooks Function({bool sessionId})
        > {
  $$ExportJobsTableTableManager(_$AppDatabase db, $ExportJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExportJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExportJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExportJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> diagnosticsTag = const Value.absent(),
              }) => ExportJobsCompanion(
                id: id,
                sessionId: sessionId,
                format: format,
                state: state,
                createdAtUtc: createdAtUtc,
                completedAtUtc: completedAtUtc,
                filePath: filePath,
                errorMessage: errorMessage,
                diagnosticsTag: diagnosticsTag,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                required String format,
                required String state,
                required DateTime createdAtUtc,
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> diagnosticsTag = const Value.absent(),
              }) => ExportJobsCompanion.insert(
                id: id,
                sessionId: sessionId,
                format: format,
                state: state,
                createdAtUtc: createdAtUtc,
                completedAtUtc: completedAtUtc,
                filePath: filePath,
                errorMessage: errorMessage,
                diagnosticsTag: diagnosticsTag,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExportJobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$ExportJobsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$ExportJobsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExportJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExportJobsTable,
      ExportJob,
      $$ExportJobsTableFilterComposer,
      $$ExportJobsTableOrderingComposer,
      $$ExportJobsTableAnnotationComposer,
      $$ExportJobsTableCreateCompanionBuilder,
      $$ExportJobsTableUpdateCompanionBuilder,
      (ExportJob, $$ExportJobsTableReferences),
      ExportJob,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String?> value,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(_db, _db.trackingSessions);
  $$GpsPointsTableTableManager get gpsPoints =>
      $$GpsPointsTableTableManager(_db, _db.gpsPoints);
  $$ImuChunksTableTableManager get imuChunks =>
      $$ImuChunksTableTableManager(_db, _db.imuChunks);
  $$DerivedMetricsTableTableManager get derivedMetrics =>
      $$DerivedMetricsTableTableManager(_db, _db.derivedMetrics);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$JudgeActionsTableTableManager get judgeActions =>
      $$JudgeActionsTableTableManager(_db, _db.judgeActions);
  $$CourseDefinitionsTableTableManager get courseDefinitions =>
      $$CourseDefinitionsTableTableManager(_db, _db.courseDefinitions);
  $$ExportJobsTableTableManager get exportJobs =>
      $$ExportJobsTableTableManager(_db, _db.exportJobs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}

mixin _$TrackingSessionDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTable get trackingSessions =>
      attachedDatabase.trackingSessions;
  TrackingSessionDaoManager get managers => TrackingSessionDaoManager(this);
}

class TrackingSessionDaoManager {
  final _$TrackingSessionDaoMixin _db;
  TrackingSessionDaoManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessions,
      );
}

mixin _$TrackingPointDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTable get trackingSessions =>
      attachedDatabase.trackingSessions;
  $GpsPointsTable get gpsPoints => attachedDatabase.gpsPoints;
  TrackingPointDaoManager get managers => TrackingPointDaoManager(this);
}

class TrackingPointDaoManager {
  final _$TrackingPointDaoMixin _db;
  TrackingPointDaoManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessions,
      );
  $$GpsPointsTableTableManager get gpsPoints =>
      $$GpsPointsTableTableManager(_db.attachedDatabase, _db.gpsPoints);
}

mixin _$ImuChunkDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTable get trackingSessions =>
      attachedDatabase.trackingSessions;
  $ImuChunksTable get imuChunks => attachedDatabase.imuChunks;
  ImuChunkDaoManager get managers => ImuChunkDaoManager(this);
}

class ImuChunkDaoManager {
  final _$ImuChunkDaoMixin _db;
  ImuChunkDaoManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessions,
      );
  $$ImuChunksTableTableManager get imuChunks =>
      $$ImuChunksTableTableManager(_db.attachedDatabase, _db.imuChunks);
}

mixin _$DerivedMetricDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTable get trackingSessions =>
      attachedDatabase.trackingSessions;
  $DerivedMetricsTable get derivedMetrics => attachedDatabase.derivedMetrics;
  DerivedMetricDaoManager get managers => DerivedMetricDaoManager(this);
}

class DerivedMetricDaoManager {
  final _$DerivedMetricDaoMixin _db;
  DerivedMetricDaoManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessions,
      );
  $$DerivedMetricsTableTableManager get derivedMetrics =>
      $$DerivedMetricsTableTableManager(
        _db.attachedDatabase,
        _db.derivedMetrics,
      );
}

mixin _$CourseDefinitionDaoMixin on DatabaseAccessor<AppDatabase> {
  $CourseDefinitionsTable get courseDefinitions =>
      attachedDatabase.courseDefinitions;
  CourseDefinitionDaoManager get managers => CourseDefinitionDaoManager(this);
}

class CourseDefinitionDaoManager {
  final _$CourseDefinitionDaoMixin _db;
  CourseDefinitionDaoManager(this._db);
  $$CourseDefinitionsTableTableManager get courseDefinitions =>
      $$CourseDefinitionsTableTableManager(
        _db.attachedDatabase,
        _db.courseDefinitions,
      );
}

mixin _$SyncQueueDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTable get trackingSessions =>
      attachedDatabase.trackingSessions;
  $SyncQueueTable get syncQueue => attachedDatabase.syncQueue;
  SyncQueueDaoManager get managers => SyncQueueDaoManager(this);
}

class SyncQueueDaoManager {
  final _$SyncQueueDaoMixin _db;
  SyncQueueDaoManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessions,
      );
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db.attachedDatabase, _db.syncQueue);
}

mixin _$JudgeActionDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrackingSessionsTable get trackingSessions =>
      attachedDatabase.trackingSessions;
  $JudgeActionsTable get judgeActions => attachedDatabase.judgeActions;
  JudgeActionDaoManager get managers => JudgeActionDaoManager(this);
}

class JudgeActionDaoManager {
  final _$JudgeActionDaoMixin _db;
  JudgeActionDaoManager(this._db);
  $$TrackingSessionsTableTableManager get trackingSessions =>
      $$TrackingSessionsTableTableManager(
        _db.attachedDatabase,
        _db.trackingSessions,
      );
  $$JudgeActionsTableTableManager get judgeActions =>
      $$JudgeActionsTableTableManager(_db.attachedDatabase, _db.judgeActions);
}

mixin _$AppSettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsTable get appSettings => attachedDatabase.appSettings;
  AppSettingsDaoManager get managers => AppSettingsDaoManager(this);
}

class AppSettingsDaoManager {
  final _$AppSettingsDaoMixin _db;
  AppSettingsDaoManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db.attachedDatabase, _db.appSettings);
}
