import '../../management/data/management_remote_data_source.dart';
import '../../api/models/api_models.dart';
import '../domain/judge_race_repository.dart';

class JudgeRaceRepositoryImpl implements JudgeRaceRepository {
  const JudgeRaceRepositoryImpl(this._managementRemoteDataSource);

  final ManagementRemoteDataSource _managementRemoteDataSource;

  @override
  Future<int> createRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) async {
    final response = await _managementRemoteDataSource.createRace(
      participantIds: participantIds,
      judgeIds: judgeIds,
    );
    return response.id;
  }

  @override
  Future<String> endRace({required int raceId}) async {
    final response = await _managementRemoteDataSource.endRace(raceId: raceId);
    return response.message;
  }

  @override
  Future<String> startRace({required int raceId}) async {
    final response = await _managementRemoteDataSource.startRace(
      raceId: raceId,
    );
    return response.message;
  }

  @override
  Future<List<UserSummaryDto>> searchUsers({
    required UserRole role,
    String? query,
  }) async {
    final response = await _managementRemoteDataSource.searchUsers(
      role: role,
      query: query,
    );
    return response.items;
  }

  @override
  Future<List<RaceSummaryDto>> loadMyRaces() async {
    final response = await _managementRemoteDataSource.getMyRaces();
    return response.items;
  }

  @override
  Future<RaceDetailDto> loadRaceDetails({required int raceId}) {
    return _managementRemoteDataSource.getRace(raceId: raceId);
  }

  @override
  Future<RaceResultsResponseDto> loadRaceResults({required int raceId}) {
    return _managementRemoteDataSource.getRaceResults(raceId: raceId);
  }

  @override
  Future<void> publishRaceEvent({
    required int raceId,
    required String eventId,
    required String eventType,
    required Map<String, Object?> payload,
  }) async {
    await _managementRemoteDataSource.createRaceEvent(
      raceId: raceId,
      eventId: eventId,
      eventType: eventType,
      payload: payload,
    );
  }
}
