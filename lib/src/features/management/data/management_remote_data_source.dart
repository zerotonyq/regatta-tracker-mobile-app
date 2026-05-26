import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../api/management_api.dart';
import '../../api/models/api_models.dart';

class ManagementRemoteDataSource {
  ManagementRemoteDataSource({
    required ManagementApi? managementApi,
    bool useMockApi = false,
  }) : _managementApi = managementApi;

  final ManagementApi? _managementApi;

  Future<IdResponseDto> createRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.createRace(
        CreateRaceRequestDto(participants: participantIds, judges: judgeIds),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<StatusMessageResponseDto> startRace({required int raceId}) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.startRace(RaceIdRequestDto(raceId: raceId));
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<StatusMessageResponseDto> endRace({required int raceId}) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.endRace(RaceIdRequestDto(raceId: raceId));
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<UserListResponseDto> searchUsers({
    UserRole? role,
    String? query,
  }) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.searchUsers(
        role: role?.wireName,
        query: query,
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceSummaryListResponseDto> getMyRaces() async {
    final managementApi = _requireApi();

    try {
      return await managementApi.getMyRaces();
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceDetailDto> getRace({required int raceId}) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.getRace(raceId);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceEventListResponseDto> getRaceEvents({required int raceId}) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.getRaceEvents(raceId);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceEventDto> createRaceEvent({
    required int raceId,
    required String eventId,
    required String eventType,
    Map<String, Object?> payload = const <String, Object?>{},
  }) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.createRaceEvent(
        raceId,
        CreateRaceEventRequestDto(
          eventId: eventId,
          eventType: eventType,
          payload: payload,
        ),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceCourseResponseDto> getRaceCourse({required int raceId}) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.getRaceCourse(raceId);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceCourseResponseDto> upsertRaceCourse({
    required int raceId,
    required Map<String, Object?> payload,
  }) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.upsertRaceCourse(
        raceId,
        UpsertRaceCourseRequestDto(payload: payload),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<RaceResultsResponseDto> getRaceResults({required int raceId}) async {
    final managementApi = _requireApi();

    try {
      return await managementApi.getRaceResults(raceId);
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<ActiveRaceResponseDto> getActiveRace() async {
    final managementApi = _requireApi();

    try {
      return await managementApi.getActiveRace();
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  ManagementApi _requireApi() {
    final managementApi = _managementApi;
    if (managementApi == null) {
      throw ApiException(
        statusCode: null,
        message: 'Management API is not configured.',
      );
    }
    return managementApi;
  }
}

extension on UserRole {
  String get wireName {
    return switch (this) {
      UserRole.participant => 'participant',
      UserRole.judge => 'judge',
    };
  }
}
