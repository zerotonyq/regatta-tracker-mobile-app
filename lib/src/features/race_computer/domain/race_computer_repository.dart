import 'course_entity.dart';
import 'race_state_entity.dart';

abstract class RaceComputerRepository {
  Future<RaceStateEntity> loadCurrentState({
    required int sessionId,
    required int raceId,
  });

  Future<void> createReferenceCourse({
    required int sessionId,
    required int raceId,
  });

  Future<CourseEntity?> loadCourse({required int raceId});
}
