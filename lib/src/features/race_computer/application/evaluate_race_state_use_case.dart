import '../domain/race_computer_repository.dart';
import '../domain/race_state_entity.dart';

class EvaluateRaceStateUseCase {
  const EvaluateRaceStateUseCase(this._raceComputerRepository);

  final RaceComputerRepository _raceComputerRepository;

  Future<RaceStateEntity> execute({
    required int sessionId,
    required int raceId,
  }) {
    return _raceComputerRepository.loadCurrentState(
      sessionId: sessionId,
      raceId: raceId,
    );
  }
}
