// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$LoginRequestDtoToJson(LoginRequestDto instance) =>
    <String, dynamic>{
      'login': instance.login,
      'password': instance.password,
      'fingerprint': ?instance.fingerprint,
    };

Map<String, dynamic> _$RegisterRequestDtoToJson(RegisterRequestDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'surname': instance.surname,
      'role': _$UserRoleEnumMap[instance.role]!,
      'login': instance.login,
      'password': instance.password,
    };

const _$UserRoleEnumMap = {
  UserRole.participant: 'participant',
  UserRole.judge: 'judge',
};

Map<String, dynamic> _$RefreshRequestDtoToJson(RefreshRequestDto instance) =>
    <String, dynamic>{
      'refresh_token': ?instance.refreshToken,
      'fingerprint': ?instance.fingerprint,
    };

Map<String, dynamic> _$UploadLocationRequestDtoToJson(
  UploadLocationRequestDto instance,
) => <String, dynamic>{
  'time': instance.time,
  'longitude': instance.longitude,
  'latitude': instance.latitude,
};

Map<String, dynamic> _$UploadBatchPointDtoToJson(
  UploadBatchPointDto instance,
) => <String, dynamic>{
  'client_task_id': instance.clientTaskId,
  'session_id': instance.sessionId,
  'timestamp_utc': instance.timestampUtc,
  'longitude': instance.longitude,
  'latitude': instance.latitude,
  'accuracy_meters': ?instance.accuracyMeters,
  'speed_meters_per_second': ?instance.speedMetersPerSecond,
};

Map<String, dynamic> _$UploadBatchRequestDtoToJson(
  UploadBatchRequestDto instance,
) => <String, dynamic>{
  'request_id': instance.requestId,
  'race_id': ?instance.raceId,
  'points': instance.points,
};

Map<String, dynamic> _$CreateRaceRequestDtoToJson(
  CreateRaceRequestDto instance,
) => <String, dynamic>{
  'participants': instance.participants,
  'judges': instance.judges,
};

Map<String, dynamic> _$RaceIdRequestDtoToJson(RaceIdRequestDto instance) =>
    <String, dynamic>{'race_id': instance.raceId};

Map<String, dynamic> _$CreateRaceEventRequestDtoToJson(
  CreateRaceEventRequestDto instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'event_type': instance.eventType,
  'payload': instance.payload,
};

Map<String, dynamic> _$UpsertRaceCourseRequestDtoToJson(
  UpsertRaceCourseRequestDto instance,
) => <String, dynamic>{'payload': instance.payload};

AuthTokensResponseDto _$AuthTokensResponseDtoFromJson(
  Map<String, dynamic> json,
) => AuthTokensResponseDto(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

IdResponseDto _$IdResponseDtoFromJson(Map<String, dynamic> json) =>
    IdResponseDto(id: (json['id'] as num).toInt());

StatusMessageResponseDto _$StatusMessageResponseDtoFromJson(
  Map<String, dynamic> json,
) => StatusMessageResponseDto(
  status: json['status'] as String,
  message: json['message'] as String,
);

UploadBatchItemResultDto _$UploadBatchItemResultDtoFromJson(
  Map<String, dynamic> json,
) => UploadBatchItemResultDto(
  clientTaskId: json['client_task_id'] as String,
  sessionId: (json['session_id'] as num).toInt(),
  status: json['status'] as String,
  message: json['message'] as String,
);

UploadBatchResponseDto _$UploadBatchResponseDtoFromJson(
  Map<String, dynamic> json,
) => UploadBatchResponseDto(
  requestId: json['request_id'] as String,
  savedCount: (json['saved_count'] as num).toInt(),
  skippedCount: (json['skipped_count'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => UploadBatchItemResultDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

UserSummaryDto _$UserSummaryDtoFromJson(Map<String, dynamic> json) =>
    UserSummaryDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      surname: json['surname'] as String,
      login: json['login'] as String,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
    );

UserListResponseDto _$UserListResponseDtoFromJson(Map<String, dynamic> json) =>
    UserListResponseDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => UserSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

RaceSummaryDto _$RaceSummaryDtoFromJson(Map<String, dynamic> json) =>
    RaceSummaryDto(
      raceId: (json['race_id'] as num).toInt(),
      status: $enumDecode(_$RaceStatusEnumMap, json['status']),
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      startedAt: json['started_at'] as String?,
      endedAt: json['ended_at'] as String?,
    );

const _$RaceStatusEnumMap = {
  RaceStatus.notStarted: 'not_started',
  RaceStatus.inProgress: 'in_progress',
  RaceStatus.finished: 'finished',
};

RaceSummaryListResponseDto _$RaceSummaryListResponseDtoFromJson(
  Map<String, dynamic> json,
) => RaceSummaryListResponseDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => RaceSummaryDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

RaceDetailDto _$RaceDetailDtoFromJson(Map<String, dynamic> json) =>
    RaceDetailDto(
      raceId: (json['race_id'] as num).toInt(),
      status: $enumDecode(_$RaceStatusEnumMap, json['status']),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => UserSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      judges: (json['judges'] as List<dynamic>)
          .map((e) => UserSummaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      startedAt: json['started_at'] as String?,
      endedAt: json['ended_at'] as String?,
    );

RaceEventDto _$RaceEventDtoFromJson(Map<String, dynamic> json) => RaceEventDto(
  eventId: json['event_id'] as String,
  raceId: (json['race_id'] as num).toInt(),
  eventType: json['event_type'] as String,
  createdAt: json['created_at'] as String,
  userId: (json['user_id'] as num).toInt(),
  payload: json['payload'] as Map<String, dynamic>,
);

RaceEventListResponseDto _$RaceEventListResponseDtoFromJson(
  Map<String, dynamic> json,
) => RaceEventListResponseDto(
  items: (json['items'] as List<dynamic>)
      .map((e) => RaceEventDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

RaceCourseResponseDto _$RaceCourseResponseDtoFromJson(
  Map<String, dynamic> json,
) => RaceCourseResponseDto(
  raceId: (json['race_id'] as num).toInt(),
  updatedAt: json['updated_at'] as String,
  payload: json['payload'] as Map<String, dynamic>,
);

ActiveRaceResponseDto _$ActiveRaceResponseDtoFromJson(
  Map<String, dynamic> json,
) => ActiveRaceResponseDto(
  active: json['active'] as bool,
  raceId: (json['race_id'] as num?)?.toInt(),
  status: $enumDecodeNullable(_$RaceStatusEnumMap, json['status']),
  startedAt: json['started_at'] as String?,
  endedAt: json['ended_at'] as String?,
);

RaceResultsResponseDto _$RaceResultsResponseDtoFromJson(
  Map<String, dynamic> json,
) => RaceResultsResponseDto(
  raceId: (json['race_id'] as num).toInt(),
  status: $enumDecode(_$RaceStatusEnumMap, json['status']),
  eventsCount: (json['events_count'] as num).toInt(),
  hasCourse: json['has_course'] as bool,
  startedAt: json['started_at'] as String?,
  endedAt: json['ended_at'] as String?,
);

ErrorResponseDto _$ErrorResponseDtoFromJson(Map<String, dynamic> json) =>
    ErrorResponseDto(
      status: json['status'] as String,
      message: json['message'] as String,
    );
