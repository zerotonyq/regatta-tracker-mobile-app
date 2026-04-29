import '../domain/judge_race_repository.dart';

class EndRaceUseCase {
  const EndRaceUseCase(this._judgeRaceRepository);

  final JudgeRaceRepository _judgeRaceRepository;

  Future<String> execute({required int raceId}) {
    return _judgeRaceRepository.endRace(raceId: raceId);
  }
}
