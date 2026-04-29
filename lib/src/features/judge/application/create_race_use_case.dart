import '../domain/judge_race_repository.dart';

class CreateRaceUseCase {
  const CreateRaceUseCase(this._judgeRaceRepository);

  final JudgeRaceRepository _judgeRaceRepository;

  Future<int> execute({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) {
    return _judgeRaceRepository.createRace(
      participantIds: participantIds,
      judgeIds: judgeIds,
    );
  }
}
