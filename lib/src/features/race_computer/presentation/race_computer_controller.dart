import 'package:flutter/foundation.dart';

import '../application/create_reference_course_use_case.dart';
import '../application/evaluate_race_state_use_case.dart';
import '../domain/course_entity.dart';
import '../domain/race_computer_repository.dart';
import '../domain/race_state_entity.dart';

class RaceComputerController extends ChangeNotifier {
  RaceComputerController({
    required EvaluateRaceStateUseCase evaluateRaceStateUseCase,
    required CreateReferenceCourseUseCase createReferenceCourseUseCase,
    required RaceComputerRepository raceComputerRepository,
  }) : _evaluateRaceStateUseCase = evaluateRaceStateUseCase,
       _createReferenceCourseUseCase = createReferenceCourseUseCase,
       _raceComputerRepository = raceComputerRepository;

  final EvaluateRaceStateUseCase _evaluateRaceStateUseCase;
  final CreateReferenceCourseUseCase _createReferenceCourseUseCase;
  final RaceComputerRepository _raceComputerRepository;

  RaceStateEntity? _state;
  CourseEntity? _course;
  bool _loading = false;
  String? _error;

  RaceStateEntity? get state => _state;
  CourseEntity? get course => _course ?? _state?.course;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh({required int sessionId, required int raceId}) async {
    await _runBusy(() async {
      _state = await _evaluateRaceStateUseCase.execute(
        sessionId: sessionId,
        raceId: raceId,
      );
      _course = _state?.course;
    });
  }

  Future<void> createReferenceCourse({
    required int sessionId,
    required int raceId,
  }) async {
    await _runBusy(() async {
      await _createReferenceCourseUseCase.execute(
        sessionId: sessionId,
        raceId: raceId,
      );
      _state = await _evaluateRaceStateUseCase.execute(
        sessionId: sessionId,
        raceId: raceId,
      );
      _course = _state?.course;
    });
  }

  Future<void> loadCourse({required int raceId}) async {
    await _runBusy(() async {
      _course = await _raceComputerRepository.loadCourse(raceId: raceId);
    });
  }

  Future<void> syncCourse({required int raceId}) async {
    await _runBusy(() async {
      _course = await _raceComputerRepository.syncCourseFromRemote(
        raceId: raceId,
      );
    });
  }

  Future<void> saveCourse(
    CourseEntity course, {
    bool publishRemote = false,
  }) async {
    await _runBusy(() async {
      await _raceComputerRepository.saveCourse(
        course,
        publishRemote: publishRemote,
      );
      _course = await _raceComputerRepository.loadCourse(raceId: course.raceId);
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
