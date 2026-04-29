import '../../local_storage/database/app_database.dart';
import '../domain/judge_action_entity.dart';
import '../domain/judge_local_repository.dart';
import '../domain/judge_race_context_entity.dart';
import '../domain/judge_race_status.dart';

class JudgeLocalRepositoryImpl implements JudgeLocalRepository {
  const JudgeLocalRepositoryImpl(this._appDatabase);

  static const _lastRaceIdKey = 'last_race_id';
  static const _lastRaceStatusKey = 'last_race_status';
  static const _lastJudgeActionAtKey = 'last_judge_action_at';

  final AppDatabase _appDatabase;

  @override
  Future<void> appendAction(JudgeActionEntity action) {
    return _appDatabase.judgeActionDao.insertAction(action);
  }

  @override
  Future<JudgeRaceContextEntity> loadContext() async {
    final lastRaceIdRaw = await _appDatabase.appSettingsDao.readValue(
      _lastRaceIdKey,
    );
    final lastRaceStatusRaw = await _appDatabase.appSettingsDao.readValue(
      _lastRaceStatusKey,
    );
    final lastJudgeActionAtRaw = await _appDatabase.appSettingsDao.readValue(
      _lastJudgeActionAtKey,
    );

    return JudgeRaceContextEntity(
      lastRaceId: int.tryParse(lastRaceIdRaw ?? ''),
      status: judgeRaceStatusFromWire(lastRaceStatusRaw),
      lastJudgeActionAtUtc: lastJudgeActionAtRaw == null
          ? null
          : DateTime.tryParse(lastJudgeActionAtRaw)?.toUtc(),
    );
  }

  @override
  Future<List<JudgeActionEntity>> loadRecentActions({int limit = 20}) {
    return _appDatabase.judgeActionDao.loadRecentActions(limit: limit);
  }

  @override
  Future<void> saveContext(JudgeRaceContextEntity context) async {
    final updatedAtUtc = DateTime.now().toUtc();
    await _appDatabase.appSettingsDao.writeValue(
      key: _lastRaceIdKey,
      value: context.lastRaceId?.toString(),
      updatedAtUtc: updatedAtUtc,
    );
    await _appDatabase.appSettingsDao.writeValue(
      key: _lastRaceStatusKey,
      value: context.status.wireName,
      updatedAtUtc: updatedAtUtc,
    );
    await _appDatabase.appSettingsDao.writeValue(
      key: _lastJudgeActionAtKey,
      value: context.lastJudgeActionAtUtc?.toUtc().toIso8601String(),
      updatedAtUtc: updatedAtUtc,
    );
  }
}
