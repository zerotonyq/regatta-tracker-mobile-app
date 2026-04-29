import '../domain/judge_race_repository.dart';

class StartRaceUseCase {
  const StartRaceUseCase(this._judgeRaceRepository);

  final JudgeRaceRepository _judgeRaceRepository;

  Future<String> execute({required int raceId}) {
    return _judgeRaceRepository.startRace(raceId: raceId);
  }
}
