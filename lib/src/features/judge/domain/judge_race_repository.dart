import '../../api/models/api_models.dart';

abstract class JudgeRaceRepository {
  Future<int> createRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  });

  Future<String> startRace({required int raceId});

  Future<String> endRace({required int raceId});

  Future<List<UserSummaryDto>> searchUsers({
    required UserRole role,
    String? query,
  });

  Future<List<RaceSummaryDto>> loadMyRaces();

  Future<RaceDetailDto> loadRaceDetails({required int raceId});
  Future<RaceResultsResponseDto> loadRaceResults({required int raceId});

  Future<void> publishRaceEvent({
    required int raceId,
    required String eventId,
    required String eventType,
    required Map<String, Object?> payload,
  });
}
