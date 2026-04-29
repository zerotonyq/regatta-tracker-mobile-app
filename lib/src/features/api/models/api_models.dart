import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

enum UserRole {
  @JsonValue('participant')
  participant,
  @JsonValue('judge')
  judge,
}

enum RaceStatus {
  @JsonValue('not_started')
  notStarted,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('finished')
  finished,
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class LoginRequestDto {
  LoginRequestDto({
    required this.login,
    required this.password,
    this.fingerprint,
  });

  final String login;
  final String password;
  final String? fingerprint;

  Map<String, dynamic> toJson() => _$LoginRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class RegisterRequestDto {
  RegisterRequestDto({
    required this.name,
    required this.surname,
    required this.role,
    required this.login,
    required this.password,
  });

  final String name;
  final String surname;
  final UserRole role;
  final String login;
  final String password;

  Map<String, dynamic> toJson() => _$RegisterRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class RefreshRequestDto {
  RefreshRequestDto({
    @JsonKey(name: 'refresh_token') this.refreshToken,
    this.fingerprint,
  });

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  final String? fingerprint;

  Map<String, dynamic> toJson() => _$RefreshRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class UploadLocationRequestDto {
  UploadLocationRequestDto({
    required this.time,
    required this.longitude,
    required this.latitude,
  });

  final String time;
  final double longitude;
  final double latitude;

  Map<String, dynamic> toJson() => _$UploadLocationRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class UploadBatchPointDto {
  UploadBatchPointDto({
    required this.clientTaskId,
    required this.sessionId,
    required this.timestampUtc,
    required this.longitude,
    required this.latitude,
    this.accuracyMeters,
    this.speedMetersPerSecond,
  });

  @JsonKey(name: 'client_task_id')
  final String clientTaskId;
  @JsonKey(name: 'session_id')
  final int sessionId;
  @JsonKey(name: 'timestamp_utc')
  final String timestampUtc;
  final double longitude;
  final double latitude;
  @JsonKey(name: 'accuracy_meters')
  final double? accuracyMeters;
  @JsonKey(name: 'speed_meters_per_second')
  final double? speedMetersPerSecond;

  Map<String, dynamic> toJson() => _$UploadBatchPointDtoToJson(this);
}

@JsonSerializable(createFactory: false, includeIfNull: false)
class UploadBatchRequestDto {
  UploadBatchRequestDto({
    required this.requestId,
    required this.points,
    this.raceId,
  });

  @JsonKey(name: 'request_id')
  final String requestId;
  @JsonKey(name: 'race_id')
  final int? raceId;
  final List<UploadBatchPointDto> points;

  Map<String, dynamic> toJson() => _$UploadBatchRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class CreateRaceRequestDto {
  CreateRaceRequestDto({required this.participants, required this.judges});

  final List<int> participants;
  final List<int> judges;

  Map<String, dynamic> toJson() => _$CreateRaceRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class RaceIdRequestDto {
  RaceIdRequestDto({@JsonKey(name: 'race_id') required this.raceId});

  @JsonKey(name: 'race_id')
  final int raceId;

  Map<String, dynamic> toJson() => _$RaceIdRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class CreateRaceEventRequestDto {
  CreateRaceEventRequestDto({
    required this.eventId,
    required this.eventType,
    Map<String, Object?>? payload,
  }) : payload = payload ?? const <String, Object?>{};

  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'event_type')
  final String eventType;
  final Map<String, Object?> payload;

  Map<String, dynamic> toJson() => _$CreateRaceEventRequestDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class UpsertRaceCourseRequestDto {
  UpsertRaceCourseRequestDto({required this.payload});

  final Map<String, Object?> payload;

  Map<String, dynamic> toJson() => _$UpsertRaceCourseRequestDtoToJson(this);
}

@JsonSerializable(createToJson: false)
class AuthTokensResponseDto {
  AuthTokensResponseDto({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokensResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensResponseDtoFromJson(json);

  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
}

@JsonSerializable(createToJson: false)
class IdResponseDto {
  IdResponseDto({required this.id});

  factory IdResponseDto.fromJson(Map<String, dynamic> json) =>
      _$IdResponseDtoFromJson(json);

  final int id;
}

@JsonSerializable(createToJson: false)
class StatusMessageResponseDto {
  StatusMessageResponseDto({required this.status, required this.message});

  factory StatusMessageResponseDto.fromJson(Map<String, dynamic> json) =>
      _$StatusMessageResponseDtoFromJson(json);

  final String status;
  final String message;
}

@JsonSerializable(createToJson: false)
class UploadBatchItemResultDto {
  UploadBatchItemResultDto({
    required this.clientTaskId,
    required this.sessionId,
    required this.status,
    required this.message,
  });

  factory UploadBatchItemResultDto.fromJson(Map<String, dynamic> json) =>
      _$UploadBatchItemResultDtoFromJson(json);

  @JsonKey(name: 'client_task_id')
  final String clientTaskId;
  @JsonKey(name: 'session_id')
  final int sessionId;
  final String status;
  final String message;
}

@JsonSerializable(createToJson: false)
class UploadBatchResponseDto {
  UploadBatchResponseDto({
    required this.requestId,
    required this.savedCount,
    required this.skippedCount,
    required this.items,
  });

  factory UploadBatchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UploadBatchResponseDtoFromJson(json);

  @JsonKey(name: 'request_id')
  final String requestId;
  @JsonKey(name: 'saved_count')
  final int savedCount;
  @JsonKey(name: 'skipped_count')
  final int skippedCount;
  final List<UploadBatchItemResultDto> items;
}

@JsonSerializable(createToJson: false)
class UserSummaryDto {
  UserSummaryDto({
    required this.id,
    required this.name,
    required this.surname,
    required this.login,
    required this.role,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryDtoFromJson(json);

  final int id;
  final String name;
  final String surname;
  final String login;
  final UserRole role;
}

@JsonSerializable(createToJson: false)
class UserListResponseDto {
  UserListResponseDto({required this.items});

  factory UserListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserListResponseDtoFromJson(json);

  final List<UserSummaryDto> items;
}

@JsonSerializable(createToJson: false)
class RaceSummaryDto {
  RaceSummaryDto({
    required this.raceId,
    required this.status,
    required this.role,
    this.startedAt,
    this.endedAt,
  });

  factory RaceSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$RaceSummaryDtoFromJson(json);

  @JsonKey(name: 'race_id')
  final int raceId;
  final RaceStatus status;
  final UserRole role;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'ended_at')
  final String? endedAt;
}

@JsonSerializable(createToJson: false)
class RaceSummaryListResponseDto {
  RaceSummaryListResponseDto({required this.items});

  factory RaceSummaryListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RaceSummaryListResponseDtoFromJson(json);

  final List<RaceSummaryDto> items;
}

@JsonSerializable(createToJson: false)
class RaceDetailDto {
  RaceDetailDto({
    required this.raceId,
    required this.status,
    required this.participants,
    required this.judges,
    this.startedAt,
    this.endedAt,
  });

  factory RaceDetailDto.fromJson(Map<String, dynamic> json) =>
      _$RaceDetailDtoFromJson(json);

  @JsonKey(name: 'race_id')
  final int raceId;
  final RaceStatus status;
  final List<UserSummaryDto> participants;
  final List<UserSummaryDto> judges;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'ended_at')
  final String? endedAt;
}

@JsonSerializable(createToJson: false)
class RaceEventDto {
  RaceEventDto({
    required this.eventId,
    required this.raceId,
    required this.eventType,
    required this.createdAt,
    required this.userId,
    required this.payload,
  });

  factory RaceEventDto.fromJson(Map<String, dynamic> json) =>
      _$RaceEventDtoFromJson(json);

  @JsonKey(name: 'event_id')
  final String eventId;
  @JsonKey(name: 'race_id')
  final int raceId;
  @JsonKey(name: 'event_type')
  final String eventType;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'user_id')
  final int userId;
  final Map<String, Object?> payload;
}

@JsonSerializable(createToJson: false)
class RaceEventListResponseDto {
  RaceEventListResponseDto({required this.items});

  factory RaceEventListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RaceEventListResponseDtoFromJson(json);

  final List<RaceEventDto> items;
}

@JsonSerializable(createToJson: false)
class RaceCourseResponseDto {
  RaceCourseResponseDto({
    required this.raceId,
    required this.updatedAt,
    required this.payload,
  });

  factory RaceCourseResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RaceCourseResponseDtoFromJson(json);

  @JsonKey(name: 'race_id')
  final int raceId;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final Map<String, Object?> payload;
}

@JsonSerializable(createToJson: false)
class ActiveRaceResponseDto {
  ActiveRaceResponseDto({
    required this.active,
    this.raceId,
    this.status,
    this.startedAt,
    this.endedAt,
  });

  factory ActiveRaceResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ActiveRaceResponseDtoFromJson(json);

  final bool active;
  @JsonKey(name: 'race_id')
  final int? raceId;
  final RaceStatus? status;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'ended_at')
  final String? endedAt;
}

@JsonSerializable(createToJson: false)
class RaceResultsResponseDto {
  RaceResultsResponseDto({
    required this.raceId,
    required this.status,
    required this.eventsCount,
    required this.hasCourse,
    this.startedAt,
    this.endedAt,
  });

  factory RaceResultsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RaceResultsResponseDtoFromJson(json);

  @JsonKey(name: 'race_id')
  final int raceId;
  final RaceStatus status;
  @JsonKey(name: 'events_count')
  final int eventsCount;
  @JsonKey(name: 'has_course')
  final bool hasCourse;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'ended_at')
  final String? endedAt;
}

@JsonSerializable(createToJson: false)
class ErrorResponseDto {
  ErrorResponseDto({required this.status, required this.message});

  factory ErrorResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseDtoFromJson(json);

  final String status;
  final String message;
}
