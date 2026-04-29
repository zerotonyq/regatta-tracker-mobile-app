import '../domain/race_computer_repository.dart';

class CreateReferenceCourseUseCase {
  const CreateReferenceCourseUseCase(this._raceComputerRepository);

  final RaceComputerRepository _raceComputerRepository;

  Future<void> execute({required int sessionId, required int raceId}) {
    return _raceComputerRepository.createReferenceCourse(
      sessionId: sessionId,
      raceId: raceId,
    );
  }
}
