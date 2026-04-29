import 'package:flutter/material.dart';

import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/judge/domain/judge_action_entity.dart';
import '../../features/judge/domain/judge_race_context_entity.dart';
import '../../features/judge/domain/judge_race_status.dart';
import '../../features/judge/domain/judge_start_sequence_state.dart';
import '../../features/judge/presentation/judge_race_controller.dart';
import '../widgets/app_button.dart';

class JudgeDashboardPage extends StatefulWidget {
  const JudgeDashboardPage({
    required this.authController,
    required this.controller,
    required this.onCreateRaceTap,
    required this.onLogoutTap,
    super.key,
  });

  final AuthSessionController authController;
  final JudgeRaceController controller;
  final VoidCallback onCreateRaceTap;
  final VoidCallback onLogoutTap;

  @override
  State<JudgeDashboardPage> createState() => _JudgeDashboardPageState();
}

class _JudgeDashboardPageState extends State<JudgeDashboardPage> {
  final _raceIdController = TextEditingController();

  @override
  void dispose() {
    _raceIdController.dispose();
    super.dispose();
  }

  int? get _typedRaceId => int.tryParse(_raceIdController.text.trim());

  int? _resolveRaceId() {
    return _typedRaceId ?? widget.controller.currentRaceId;
  }

  JudgeStartSequenceState _sequenceState(int raceId) {
    return JudgeStartSequenceState.fromActions(
      raceId: raceId,
      actions: widget.controller.recentActions,
    );
  }

  Future<void> _startRace() async {
    final raceId = _resolveRaceId();
    if (raceId == null) {
      return;
    }
    await widget.controller.startRace(raceId: raceId);
  }

  Future<void> _endRace() async {
    final raceId = _resolveRaceId();
    if (raceId == null) {
      return;
    }
    await widget.controller.endRace(raceId: raceId);
  }

  Future<void> _recordSignal(String signalType) async {
    final raceId = _resolveRaceId();
    if (raceId == null) {
      return;
    }
    await widget.controller.recordStartProcedureSignal(
      raceId: raceId,
      signalType: signalType,
    );
  }

  Future<void> _scheduleStartProcedure(Duration duration) async {
    final raceId = _resolveRaceId();
    if (raceId == null) {
      return;
    }
    await widget.controller.scheduleStartProcedure(
      raceId: raceId,
      duration: duration,
    );
  }

  bool _canStart(JudgeRaceContextEntity context, int? raceId) {
    if (raceId == null) {
      return false;
    }
    final sequence = _sequenceState(raceId);
    if (!sequence.canStartRace) {
      return false;
    }
    if (context.lastRaceId != raceId) {
      return true;
    }
    return context.status == JudgeRaceStatus.idle ||
        context.status == JudgeRaceStatus.created;
  }

  bool _canFinish(JudgeRaceContextEntity context, int? raceId) {
    if (raceId == null) {
      return false;
    }
    return context.lastRaceId == raceId &&
        context.status == JudgeRaceStatus.started;
  }

  String _procedureHint(JudgeStartSequenceState sequence) {
    if (sequence.canScheduleFiveMinute) {
      return 'Сначала выберите стартовую процедуру: 5 мин или 1 мин.';
    }
    if (sequence.canSendWarning) {
      return 'Следующий шаг: предупредительный сигнал.';
    }
    if (sequence.canSendPreparatory) {
      return 'Следующий шаг: подготовительный сигнал.';
    }
    if (sequence.canSendStart) {
      return 'Следующий шаг: сигнал старт.';
    }
    if (sequence.canStartRace) {
      return 'Сигнал старт подан. Теперь можно начать гонку.';
    }
    return 'Порядок процедуры уже завершен или недоступен для этой гонки.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель судьи'),
        actions: [
          IconButton(
            onPressed: widget.onLogoutTap,
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final flowController = widget.controller;
          final raceId = _resolveRaceId();
          final sequence = raceId == null
              ? JudgeStartSequenceState.empty
              : _sequenceState(raceId);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _StatusCard(
                  context: flowController.context,
                  userId: widget.authController.userId,
                  message: flowController.message,
                  error: flowController.error,
                ),
                const SizedBox(height: 16),
                _MyRacesCard(races: flowController.myRaces),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Создать гонку',
                  icon: Icons.add,
                  fullWidth: true,
                  onPressed: widget.onCreateRaceTap,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _raceIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ID гонки',
                    border: const OutlineInputBorder(),
                    helperText: flowController.currentRaceId == null
                        ? 'Введите id гонки, чтобы управлять стартовой процедурой и состоянием гонки.'
                        : 'Можно оставить поле пустым и использовать гонку ${flowController.currentRaceId}.',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (raceId != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _procedureHint(sequence),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Начать гонку',
                        variant: AppButtonVariant.success,
                        loading: flowController.loading,
                        onPressed: _canStart(flowController.context, raceId)
                            ? _startRace
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Завершить гонку',
                        variant: AppButtonVariant.danger,
                        loading: flowController.loading,
                        onPressed: _canFinish(flowController.context, raceId)
                            ? _endRace
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SignalButton(
                      label: 'Стартовая процедура 5 мин',
                      onPressed: raceId == null ||
                              flowController.loading ||
                              !sequence.canScheduleFiveMinute
                          ? null
                          : () => _scheduleStartProcedure(
                              const Duration(minutes: 5),
                            ),
                    ),
                    _SignalButton(
                      label: 'Стартовая процедура 1 мин',
                      onPressed: raceId == null ||
                              flowController.loading ||
                              !sequence.canScheduleOneMinute
                          ? null
                          : () => _scheduleStartProcedure(
                              const Duration(minutes: 1),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SignalButton(
                      label: 'Сигнал: предупредительный',
                      onPressed: raceId == null ||
                              flowController.loading ||
                              !sequence.canSendWarning
                          ? null
                          : () => _recordSignal('warning'),
                    ),
                    _SignalButton(
                      label: 'Сигнал: подготовительный',
                      onPressed: raceId == null ||
                              flowController.loading ||
                              !sequence.canSendPreparatory
                          ? null
                          : () => _recordSignal('preparatory'),
                    ),
                    _SignalButton(
                      label: 'Сигнал: старт',
                      onPressed: raceId == null ||
                              flowController.loading ||
                              !sequence.canSendStart
                          ? null
                          : () => _recordSignal('start'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Последние действия судьи',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (flowController.recentActions.isEmpty)
                  const Text('Действий пока нет.')
                else
                  ...flowController.recentActions.map(_ActionTile.new),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MyRacesCard extends StatelessWidget {
  const _MyRacesCard({required this.races});

  final List<RaceSummaryDto> races;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Назначенные гонки',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (races.isEmpty)
              const Text('Сервис управления пока не вернул гонки.')
            else
              ...races.map(
                (race) => Text(
                  'id=${race.raceId} | статус=${race.status.wireNameRu}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension on RaceStatus {
  String get wireNameRu {
    return switch (this) {
      RaceStatus.notStarted => 'не началась',
      RaceStatus.inProgress => 'идет',
      RaceStatus.finished => 'завершена',
    };
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.context,
    required this.userId,
    required this.message,
    required this.error,
  });

  final JudgeRaceContextEntity context;
  final int? userId;
  final String? message;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastActionAt = this.context.lastJudgeActionAtUtc;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Контекст судьи',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Ваш id судьи: ${userId?.toString() ?? 'неизвестно'}'),
            Text('Последняя гонка: ${this.context.lastRaceId ?? 'нет'}'),
            Text('Локальный статус: ${_statusLabel(this.context.status)}'),
            Text(
              'Последнее действие: ${lastActionAt?.toIso8601String() ?? 'не зафиксировано'}',
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                'Последний результат: $message',
                style: TextStyle(color: Colors.green.shade700),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                'Последняя ошибка: $error',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _statusLabel(JudgeRaceStatus status) {
    return switch (status) {
      JudgeRaceStatus.idle => 'ожидание',
      JudgeRaceStatus.created => 'гонка создана',
      JudgeRaceStatus.started => 'гонка начата',
      JudgeRaceStatus.finished => 'гонка завершена',
    };
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(this.action);

  final JudgeActionEntity action;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(_eventTypeLabel(action.eventType)),
        subtitle: Text(
          'гонка=${action.raceId ?? '-'} | синхронизация=${_syncStatusLabel(action.syncStatus)}\n${action.createdAtUtc.toIso8601String()}',
        ),
        trailing: action.payloadJson == null
            ? null
            : Tooltip(
                message: action.payloadJson!,
                child: const Icon(Icons.info_outline),
              ),
      ),
    );
  }

  static String _eventTypeLabel(String value) {
    return switch (value) {
      'race_created' => 'Гонка создана',
      'start_requested' => 'Запрошен старт гонки',
      'race_started' => 'Гонка начата',
      'end_requested' => 'Запрошено завершение гонки',
      'race_finished' => 'Гонка завершена',
      'start_procedure_signal' => 'Сигнал стартовой процедуры',
      'start_procedure_configured' => 'Стартовая процедура запланирована',
      _ => value,
    };
  }

  static String _syncStatusLabel(String value) {
    return switch (value) {
      'pending' => 'ожидает отправки',
      'in_progress' => 'отправляется',
      'synced' => 'отправлено',
      'failed_retryable' => 'будет повторено',
      'failed_terminal' => 'ошибка отправки',
      _ => value,
    };
  }
}

class _SignalButton extends StatelessWidget {
  const _SignalButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      size: AppButtonSize.sm,
      variant: AppButtonVariant.outline,
      onPressed: onPressed,
    );
  }
}
