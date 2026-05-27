import 'dart:convert';

import '../../../core/network/api_exception.dart';
import '../../api/models/api_models.dart';
import '../../sync/domain/sync_job_state.dart';
import '../domain/judge_action_entity.dart';
import '../domain/judge_flow_failure.dart';
import '../domain/judge_local_repository.dart';
import '../domain/judge_race_context_entity.dart';
import '../domain/judge_race_repository.dart';
import '../domain/judge_race_status.dart';
import '../domain/judge_start_sequence_state.dart';
import 'judge_flow_result.dart';
import 'judge_flow_validator.dart';

class JudgeRaceFlowService {
  const JudgeRaceFlowService({
    required JudgeRaceRepository judgeRaceRepository,
    required JudgeLocalRepository judgeLocalRepository,
    JudgeFlowValidator judgeFlowValidator = const JudgeFlowValidator(),
  }) : _judgeRaceRepository = judgeRaceRepository,
       _judgeLocalRepository = judgeLocalRepository,
       _judgeFlowValidator = judgeFlowValidator;

  final JudgeRaceRepository _judgeRaceRepository;
  final JudgeLocalRepository _judgeLocalRepository;
  final JudgeFlowValidator _judgeFlowValidator;

  Future<JudgeRaceContextEntity> restoreContext() {
    return _judgeLocalRepository.loadContext();
  }

  Future<List<JudgeActionEntity>> loadRecentActions({int limit = 20}) {
    return _judgeLocalRepository.loadRecentActions(limit: limit);
  }

  Future<List<UserSummaryDto>> searchUsers({
    required UserRole role,
    String? query,
  }) {
    return _judgeRaceRepository.searchUsers(role: role, query: query);
  }

  Future<List<RaceSummaryDto>> loadMyRaces() {
    return _judgeRaceRepository.loadMyRaces();
  }

  Future<RaceResultsResponseDto> loadRaceResults({required int raceId}) {
    return _judgeRaceRepository.loadRaceResults(raceId: raceId);
  }

  Future<JudgeFlowResult<int>> createRace({
    required List<int> participantIds,
    required List<int> judgeIds,
  }) async {
    _judgeFlowValidator.validateCreateRace(
      participantIds: participantIds,
      judgeIds: judgeIds,
    );

    try {
      final raceId = await _judgeRaceRepository.createRace(
        participantIds: participantIds,
        judgeIds: judgeIds,
      );
      final occurredAt = DateTime.now().toUtc();
      final context = JudgeRaceContextEntity(
        lastRaceId: raceId,
        status: JudgeRaceStatus.created,
        lastJudgeActionAtUtc: occurredAt,
      );
      await _judgeLocalRepository.saveContext(context);
      await _appendAction(
        raceId: raceId,
        eventType: 'race_created',
        occurredAtUtc: occurredAt,
        payloadJson: jsonEncode(<String, Object>{
          'participantCount': participantIds.length,
          'judgeCount': judgeIds.length,
        }),
      );
      return JudgeFlowResult<int>(
        value: raceId,
        context: context,
        message: 'Гонка создана. ID: $raceId',
      );
    } on ApiException catch (error) {
      throw JudgeFlowFailure(_mapApiException(error));
    }
  }

  Future<JudgeFlowResult<void>> startRace({required int raceId}) async {
    final currentContext = await _judgeLocalRepository.loadContext();
    final sequence = await _loadSequenceState(raceId);

    if (currentContext.status == JudgeRaceStatus.started &&
        currentContext.lastRaceId == raceId) {
      throw const JudgeFlowFailure(
        'Эта гонка уже запущена на этом устройстве.',
      );
    }
    if (currentContext.status == JudgeRaceStatus.finished &&
        currentContext.lastRaceId == raceId) {
      throw const JudgeFlowFailure(
        'Эта гонка уже завершена на этом устройстве.',
      );
    }
    if (!sequence.canStartRace) {
      throw const JudgeFlowFailure(
        'Гонку можно начать только после сигнала старт.',
      );
    }

    final requestedAt = DateTime.now().toUtc();
    await _appendAction(
      raceId: raceId,
      eventType: 'start_requested',
      occurredAtUtc: requestedAt,
      payloadJson: jsonEncode(<String, Object>{'raceId': raceId}),
    );

    try {
      final message = await _judgeRaceRepository.startRace(raceId: raceId);
      final occurredAt = DateTime.now().toUtc();
      final context = JudgeRaceContextEntity(
        lastRaceId: raceId,
        status: JudgeRaceStatus.started,
        lastJudgeActionAtUtc: occurredAt,
      );
      await _judgeLocalRepository.saveContext(context);
      await _appendAction(
        raceId: raceId,
        eventType: 'race_started',
        occurredAtUtc: occurredAt,
        payloadJson: jsonEncode(<String, Object>{'backendMessage': message}),
      );
      return JudgeFlowResult<void>(context: context, message: message);
    } on ApiException catch (error) {
      throw JudgeFlowFailure(_mapApiException(error));
    }
  }

  Future<JudgeFlowResult<void>> endRace({required int raceId}) async {
    final currentContext = await _judgeLocalRepository.loadContext();
    if (currentContext.status == JudgeRaceStatus.finished &&
        currentContext.lastRaceId == raceId) {
      throw const JudgeFlowFailure(
        'Эта гонка уже завершена на этом устройстве.',
      );
    }
    if (currentContext.status != JudgeRaceStatus.started ||
        currentContext.lastRaceId != raceId) {
      throw const JudgeFlowFailure('Завершить можно только уже начатую гонку.');
    }

    final requestedAt = DateTime.now().toUtc();
    await _appendAction(
      raceId: raceId,
      eventType: 'end_requested',
      occurredAtUtc: requestedAt,
      payloadJson: jsonEncode(<String, Object>{'raceId': raceId}),
    );

    try {
      final message = await _judgeRaceRepository.endRace(raceId: raceId);
      final occurredAt = DateTime.now().toUtc();
      final context = JudgeRaceContextEntity(
        lastRaceId: raceId,
        status: JudgeRaceStatus.finished,
        lastJudgeActionAtUtc: occurredAt,
      );
      await _judgeLocalRepository.saveContext(context);
      await _appendAction(
        raceId: raceId,
        eventType: 'race_finished',
        occurredAtUtc: occurredAt,
        payloadJson: jsonEncode(<String, Object>{'backendMessage': message}),
      );
      return JudgeFlowResult<void>(context: context, message: message);
    } on ApiException catch (error) {
      throw JudgeFlowFailure(_mapApiException(error));
    }
  }

  Future<JudgeFlowResult<void>> recordStartProcedureSignal({
    required int raceId,
    required String signalType,
  }) async {
    final context = await _judgeLocalRepository.loadContext();
    if (context.status == JudgeRaceStatus.started &&
        context.lastRaceId == raceId) {
      throw const JudgeFlowFailure(
        'После старта гонки нельзя подавать сигналы стартовой процедуры.',
      );
    }

    final sequence = await _loadSequenceState(raceId);
    final isAllowed = switch (signalType) {
      'warning' => sequence.canSendWarning,
      'preparatory' => sequence.canSendPreparatory,
      'start' => sequence.canSendStart,
      _ => false,
    };
    if (!isAllowed) {
      throw JudgeFlowFailure(_signalOrderMessage(signalType));
    }

    final occurredAt = DateTime.now().toUtc();
    final updatedContext = context.copyWith(
      lastRaceId: raceId,
      lastJudgeActionAtUtc: occurredAt,
    );
    await _judgeLocalRepository.saveContext(updatedContext);
    await _appendAction(
      raceId: raceId,
      eventType: 'start_procedure_signal',
      occurredAtUtc: occurredAt,
      payloadJson: jsonEncode(<String, Object>{'signalType': signalType}),
    );
    return JudgeFlowResult<void>(
      context: updatedContext,
      message: 'Сигнал стартовой процедуры сохранен: $signalType',
    );
  }

  Future<JudgeFlowResult<void>> scheduleStartProcedure({
    required int raceId,
    required Duration duration,
  }) async {
    final context = await _judgeLocalRepository.loadContext();
    if (context.status == JudgeRaceStatus.started &&
        context.lastRaceId == raceId) {
      throw const JudgeFlowFailure(
        'Нельзя заново запускать стартовую процедуру для уже начатой гонки.',
      );
    }

    final sequence = await _loadSequenceState(raceId);
    final isAllowed = switch (duration.inMinutes) {
      5 => sequence.canScheduleFiveMinute,
      1 => sequence.canScheduleOneMinute,
      _ => false,
    };
    if (!isAllowed) {
      throw JudgeFlowFailure(
        'Стартовая процедура уже выбрана или по ней уже были поданы сигналы. Менять порядок сейчас нельзя.',
      );
    }

    final occurredAt = DateTime.now().toUtc();
    final startAtUtc = occurredAt.add(duration);
    final updatedContext = context.copyWith(
      lastRaceId: raceId,
      lastJudgeActionAtUtc: occurredAt,
    );
    await _judgeLocalRepository.saveContext(updatedContext);
    await _appendAction(
      raceId: raceId,
      eventType: 'start_procedure_configured',
      occurredAtUtc: occurredAt,
      payloadJson: jsonEncode(<String, Object>{
        'durationSeconds': duration.inSeconds,
        'startAtUtc': startAtUtc.toIso8601String(),
      }),
    );
    return JudgeFlowResult<void>(
      context: updatedContext,
      message:
          'Стартовая процедура запланирована на ${duration.inMinutes} мин. Время старта: ${startAtUtc.toIso8601String()}.',
    );
  }

  Future<void> _appendAction({
    required int raceId,
    required String eventType,
    required DateTime occurredAtUtc,
    required String payloadJson,
  }) async {
    final eventId =
        '$eventType-$raceId-${occurredAtUtc.microsecondsSinceEpoch}';
    var syncStatus = SyncJobState.pending.wireName;
    try {
      final payload = Map<String, Object?>.from(jsonDecode(payloadJson) as Map);
      await _judgeRaceRepository.publishRaceEvent(
        raceId: raceId,
        eventId: eventId,
        eventType: eventType,
        payload: payload,
      );
      syncStatus = SyncJobState.synced.wireName;
    } catch (_) {
      syncStatus = SyncJobState.pending.wireName;
    }

    await _judgeLocalRepository.appendAction(
      JudgeActionEntity(
        eventId: eventId,
        raceId: raceId,
        eventType: eventType,
        payloadJson: payloadJson,
        createdAtUtc: occurredAtUtc,
        syncStatus: syncStatus,
      ),
    );
  }

  Future<JudgeStartSequenceState> _loadSequenceState(int raceId) async {
    final actions = await _judgeLocalRepository.loadRecentActions(limit: 100);
    return JudgeStartSequenceState.fromActions(
      raceId: raceId,
      actions: actions,
    );
  }

  String _signalOrderMessage(String signalType) {
    return switch (signalType) {
      'warning' =>
        'Предупредительный сигнал можно подать только после выбора стартовой процедуры на 5 мин.',
      'preparatory' =>
        'Подготовительный сигнал можно подать только после предупредительного.',
      'start' =>
        'Сигнал старт можно подать только в корректной последовательности процедуры старта.',
      _ => 'Некорректный порядок сигналов.',
    };
  }

  String _mapApiException(ApiException error) {
    final statusCode = error.statusCode;
    if (statusCode == 401) {
      return 'Сессия судьи истекла. Войдите снова.';
    }
    if (statusCode == 403) {
      return 'Недостаточно прав для этого действия судьи.';
    }
    if (statusCode == 409) {
      return 'Гонка уже находится в запрошенном состоянии на сервере.';
    }
    return error.message;
  }
}
