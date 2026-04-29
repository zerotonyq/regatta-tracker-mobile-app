import 'package:flutter/foundation.dart';

import '../application/create_reference_course_use_case.dart';
import '../application/evaluate_race_state_use_case.dart';
import '../domain/race_state_entity.dart';

class RaceComputerController extends ChangeNotifier {
  RaceComputerController({
    required EvaluateRaceStateUseCase evaluateRaceStateUseCase,
    required CreateReferenceCourseUseCase createReferenceCourseUseCase,
  }) : _evaluateRaceStateUseCase = evaluateRaceStateUseCase,
       _createReferenceCourseUseCase = createReferenceCourseUseCase;

  final EvaluateRaceStateUseCase _evaluateRaceStateUseCase;
  final CreateReferenceCourseUseCase _createReferenceCourseUseCase;

  RaceStateEntity? _state;
  bool _loading = false;
  String? _error;

  RaceStateEntity? get state => _state;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> refresh({required int sessionId, required int raceId}) async {
    await _runBusy(() async {
      _state = await _evaluateRaceStateUseCase.execute(
        sessionId: sessionId,
        raceId: raceId,
      );
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
