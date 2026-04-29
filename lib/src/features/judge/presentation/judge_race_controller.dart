import 'package:flutter/foundation.dart';

import '../../api/models/api_models.dart';
import '../application/judge_race_flow_service.dart';
import '../domain/judge_action_entity.dart';
import '../domain/judge_flow_failure.dart';
import '../domain/judge_race_context_entity.dart';
import '../domain/judge_race_status.dart';

class JudgeRaceController extends ChangeNotifier {
  JudgeRaceController({required JudgeRaceFlowService judgeRaceFlowService})
    : _judgeRaceFlowService = judgeRaceFlowService;

  final JudgeRaceFlowService _judgeRaceFlowService;

  bool _loading = false;
  String? _error;
  String? _message;
  JudgeRaceContextEntity _context = JudgeRaceContextEntity.empty;
  List<JudgeActionEntity> _recentActions = const <JudgeActionEntity>[];
  List<UserSummaryDto> _availableParticipants = const <UserSummaryDto>[];
  List<UserSummaryDto> _availableJudges = const <UserSummaryDto>[];
  List<RaceSummaryDto> _myRaces = const <RaceSummaryDto>[];

  bool get loading => _loading;
  String? get error => _error;
  String? get message => _message;
  JudgeRaceContextEntity get context => _context;
  List<JudgeActionEntity> get recentActions => _recentActions;
  List<UserSummaryDto> get availableParticipants => _availableParticipants;
  List<UserSummaryDto> get availableJudges => _availableJudges;
  List<RaceSummaryDto> get myRaces => _myRaces;
  int? get currentRaceId => _context.lastRaceId;
  JudgeRaceStatus get currentStatus => _context.status;

  Future<void> restore() async {
    _context = await _judgeRaceFlowService.restoreContext();
    _recentActions = await _judgeRaceFlowService.loadRecentActions();
    await loadRaceCatalog();
    notifyListeners();
  }

  Future<void> loadRaceCatalog({String? participantQuery, String? judgeQuery}) {
    return _runBusy<void>(() async {
      _availableParticipants = await _judgeRaceFlowService.searchUsers(
        role: UserRole.participant,
        query: participantQuery,
      );
      _availableJudges = await _judgeRaceFlowService.searchUsers(
        role: UserRole.judge,
        query: judgeQuery,
      );
      _myRaces = await _judgeRaceFlowService.loadMyRaces();
    });
  }

  Future<int?> createRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) async {
    return _runBusy<int?>(() async {
      final result = await _judgeRaceFlowService.createRace(
        participantIds: participantIds,
        judgeIds: judgeIds,
      );
      _context = result.context;
      _message = result.message;
      await _reloadActions();
      return result.value;
    });
  }

  Future<void> startRace({required int raceId}) async {
    await _runBusy<void>(() async {
      final result = await _judgeRaceFlowService.startRace(raceId: raceId);
      _context = result.context;
      _message = result.message;
      await _reloadActions();
    });
  }

  Future<void> endRace({required int raceId}) async {
    await _runBusy<void>(() async {
      final result = await _judgeRaceFlowService.endRace(raceId: raceId);
      _context = result.context;
      _message = result.message;
      await _reloadActions();
    });
  }

  Future<void> recordStartProcedureSignal({
    required int raceId,
    required String signalType,
  }) async {
    await _runBusy<void>(() async {
      final result = await _judgeRaceFlowService.recordStartProcedureSignal(
        raceId: raceId,
        signalType: signalType,
      );
      _context = result.context;
      _message = result.message;
      await _reloadActions();
    });
  }

  Future<void> scheduleStartProcedure({
    required int raceId,
    required Duration duration,
  }) async {
    await _runBusy<void>(() async {
      final result = await _judgeRaceFlowService.scheduleStartProcedure(
        raceId: raceId,
        duration: duration,
      );
      _context = result.context;
      _message = result.message;
      await _reloadActions();
    });
  }

  void clearMessage() {
    _message = null;
    _error = null;
    notifyListeners();
  }

  Future<T?> _runBusy<T>(Future<T> Function() action) async {
    _setLoading(true);
    _error = null;
    _message = null;
    try {
      return await action();
    } on JudgeFlowFailure catch (error) {
      _error = error.message;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<void> _reloadActions() async {
    _recentActions = await _judgeRaceFlowService.loadRecentActions();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
