import 'judge_action_entity.dart';
import 'judge_race_context_entity.dart';

abstract class JudgeLocalRepository {
  Future<JudgeRaceContextEntity> loadContext();

  Future<void> saveContext(JudgeRaceContextEntity context);

  Future<void> appendAction(JudgeActionEntity action);

  Future<List<JudgeActionEntity>> loadRecentActions({int limit = 20});
}
