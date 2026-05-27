import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/judge/domain/judge_action_entity.dart';
import '../../features/judge/domain/judge_race_context_entity.dart';
import '../../features/judge/domain/judge_race_status.dart';
import '../../features/judge/domain/judge_start_sequence_state.dart';
import '../../features/judge/presentation/judge_race_controller.dart';

class JudgeDashboardPage extends StatefulWidget {
  const JudgeDashboardPage({
    required this.authController,
    required this.controller,
    required this.onCreateRaceTap,
    required this.onEditCourseTap,
    required this.onLogoutTap,
    super.key,
  });

  final AuthSessionController authController;
  final JudgeRaceController controller;
  final VoidCallback onCreateRaceTap;
  final ValueChanged<int> onEditCourseTap;
  final VoidCallback onLogoutTap;

  @override
  State<JudgeDashboardPage> createState() => _JudgeDashboardPageState();
}

class _JudgeDashboardPageState extends State<JudgeDashboardPage> {
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  int? _resolveRaceId() {
    return widget.controller.currentRaceId;
  }

  JudgeStartSequenceState _sequenceState(int raceId) {
    return JudgeStartSequenceState.fromActions(
      raceId: raceId,
      actions: widget.controller.recentActions,
    );
  }

  Future<void> _startRace() async {
    final raceId = _resolveRaceId();
    if (raceId != null) {
      await widget.controller.startRace(raceId: raceId);
    }
  }

  Future<void> _endRace() async {
    final raceId = _resolveRaceId();
    if (raceId != null) {
      await widget.controller.endRace(raceId: raceId);
    }
  }

  Future<void> _recordSignal(String signalType) async {
    final raceId = _resolveRaceId();
    if (raceId != null) {
      await widget.controller.recordStartProcedureSignal(
        raceId: raceId,
        signalType: signalType,
      );
    }
  }

  Future<void> _scheduleStartProcedure(Duration duration) async {
    final raceId = _resolveRaceId();
    if (raceId != null) {
      await widget.controller.scheduleStartProcedure(
        raceId: raceId,
        duration: duration,
      );
    }
  }

  Future<void> _loadResults() async {
    final raceId = _resolveRaceId();
    if (raceId != null) {
      await widget.controller.loadRaceResults(raceId: raceId);
    }
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
    return raceId != null &&
        context.lastRaceId == raceId &&
        context.status == JudgeRaceStatus.started;
  }

  bool _canEditCourse(int? raceId) {
    if (raceId == null) {
      return false;
    }

    return widget.controller.context.lastRaceId == raceId ||
        widget.controller.myRaces.any((race) => race.raceId == raceId);
  }

  String _procedureHint(JudgeStartSequenceState sequence) {
    if (sequence.canScheduleFiveMinute) {
      return 'Выберите стартовую процедуру: 5 минут или 1 минута.';
    }
    if (sequence.canSendWarning) {
      return 'Следующий шаг: warning signal.';
    }
    if (sequence.canSendPreparatory) {
      return 'Следующий шаг: preparatory signal.';
    }
    if (sequence.canSendStart) {
      return 'Следующий шаг: start signal.';
    }
    if (sequence.canStartRace) {
      return 'Start signal подан. Можно запускать гонку.';
    }
    return 'Стартовая процедура завершена или недоступна.';
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FBFD);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final flowController = widget.controller;
            final raceId = _resolveRaceId();
            final participantLabels = <int, String>{
              for (final participant in flowController.availableParticipants)
                participant.id: '${participant.name} (${participant.login})',
            };

            final sequence = raceId == null
                ? JudgeStartSequenceState.empty
                : _sequenceState(raceId);

            final statusCard = _StatusCard(
              judgeContext: flowController.context,
              userId: widget.authController.userId,
              message: flowController.message,
              error: flowController.error,
            );

            final controlPanel = _RaceControlPanel(
              flowController: flowController,
              raceId: raceId,
              sequence: sequence,
              procedureHint: _procedureHint(sequence),
              canStart: _canStart(flowController.context, raceId),
              canFinish: _canFinish(flowController.context, raceId),
              canEditCourse: _canEditCourse(raceId),
              onCreateRaceTap: widget.onCreateRaceTap,
              onEditCourseTap: () {
                final selectedRaceId = raceId;
                if (selectedRaceId != null) {
                  widget.onEditCourseTap(selectedRaceId);
                }
              },
              onStartRace: _startRace,
              onEndRace: _endRace,
              onScheduleFive: () {
                _scheduleStartProcedure(const Duration(minutes: 5));
              },
              onScheduleOne: () {
                _scheduleStartProcedure(const Duration(minutes: 1));
              },
              onLoadResults: _loadResults,
              onWarning: () => _recordSignal('warning'),
              onPreparatory: () => _recordSignal('preparatory'),
              onStartSignal: () => _recordSignal('start'),
            );
            final resultsCard = _ResultsCard(
              results: flowController.raceResults,
              participantLabels: participantLabels,
            );
            final actionsCard = _RecentActionsTimeline(
              actions: flowController.recentActions,
            );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 980;

                    if (isWide) {
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                        children: [
                          _Header(
                            logoAsset: _logoAsset,
                            onLogoutTap: widget.onLogoutTap,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    statusCard,
                                    const SizedBox(height: 16),
                                    resultsCard,
                                    const SizedBox(height: 16),
                                    actionsCard,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ],
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      children: [
                        _Header(
                          logoAsset: _logoAsset,
                          onLogoutTap: widget.onLogoutTap,
                        ),
                        const SizedBox(height: 24),
                        statusCard,
                        const SizedBox(height: 16),
                        controlPanel,
                        const SizedBox(height: 16),
                        resultsCard,
                        const SizedBox(height: 16),
                        actionsCard,
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.logoAsset,
    required this.onLogoutTap,
  });

  final String logoAsset;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          logoAsset,
          width: 54,
          height: 54,
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RegaTracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _AppColors.navy,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Панель судьи',
                style: TextStyle(
                  fontSize: 14,
                  color: _AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'Выйти',
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.judgeContext,
    required this.userId,
    required this.message,
    required this.error,
  });

  final JudgeRaceContextEntity judgeContext;
  final int? userId;
  final String? message;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.gavel_rounded,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Race Director',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.badge_outlined,
                text: 'ID судьи: ${userId?.toString() ?? 'неизвестно'}',
              ),
              _InfoChip(
                icon: Icons.flag_rounded,
                text: 'Гонка: ${judgeContext.lastRaceId ?? 'нет'}',
              ),
              _StatusBadge(
                text: _statusLabel(judgeContext.status),
                danger: judgeContext.status == JudgeRaceStatus.finished,
                active: judgeContext.status == JudgeRaceStatus.started,
              ),
            ],
          ),
          if (message != null && message!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _InlineBanner(
              icon: Icons.check_circle_outline_rounded,
              text: message!,
            ),
          ],
          if (error != null && error!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _InlineBanner(
              icon: Icons.error_outline_rounded,
              text: error!,
              danger: true,
            ),
          ],
        ],
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

class _RaceControlPanel extends StatelessWidget {
  const _RaceControlPanel({
    required this.flowController,
    required this.raceId,
    required this.sequence,
    required this.procedureHint,
    required this.canStart,
    required this.canFinish,
    required this.canEditCourse,
    required this.onCreateRaceTap,
    required this.onEditCourseTap,
    required this.onStartRace,
    required this.onEndRace,
    required this.onScheduleFive,
    required this.onScheduleOne,
    required this.onLoadResults,
    required this.onWarning,
    required this.onPreparatory,
    required this.onStartSignal,
  });

  final JudgeRaceController flowController;
  final int? raceId;
  final JudgeStartSequenceState sequence;
  final String procedureHint;
  final bool canStart;
  final bool canFinish;
  final bool canEditCourse;
  final VoidCallback onCreateRaceTap;
  final VoidCallback onEditCourseTap;
  final VoidCallback onStartRace;
  final VoidCallback onEndRace;
  final VoidCallback onScheduleFive;
  final VoidCallback onScheduleOne;
  final VoidCallback onLoadResults;
  final VoidCallback onWarning;
  final VoidCallback onPreparatory;
  final VoidCallback onStartSignal;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Управление гонкой',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Создайте гонку, настройте курс и проведите стартовую процедуру.',
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          _PrimaryActionButton(
            label: 'Создать гонку',
            icon: Icons.add_rounded,
            loading: flowController.loading,
            onPressed: onCreateRaceTap,
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _SecondaryActionButton(
                  label: 'Курс',
                  icon: Icons.map_outlined,
                  onPressed: canEditCourse ? onEditCourseTap : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SecondaryActionButton(
                  label: 'Результаты',
                  icon: Icons.refresh_rounded,
                  onPressed:
                  raceId == null || flowController.loading ? null : onLoadResults,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _InlineBanner(
            icon: Icons.info_outline_rounded,
            text: procedureHint,
          ),

          const SizedBox(height: 18),

          const Text(
            'Стартовая процедура',
            style: TextStyle(
              fontSize: 16,
              color: _AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (raceId != null &&
                  !flowController.loading &&
                  sequence.canScheduleFiveMinute)
                _SignalButton(
                  label: '5 минут',
                  onPressed: onScheduleFive,
                ),
              if (raceId != null &&
                  !flowController.loading &&
                  sequence.canScheduleOneMinute)
                _SignalButton(
                  label: '1 минута',
                  onPressed: onScheduleOne,
                ),
              if (raceId != null &&
                  !flowController.loading &&
                  sequence.canSendWarning)
                _SignalButton(
                  label: 'Предупреждение',
                  onPressed: onWarning,
                ),
              if (raceId != null &&
                  !flowController.loading &&
                  sequence.canSendPreparatory)
                _SignalButton(
                  label: 'Подготовительный',
                  onPressed: onPreparatory,
                ),
              if (raceId != null &&
                  !flowController.loading &&
                  sequence.canSendStart)
                _SignalButton(
                  label: 'Стартовый сигнал',
                  onPressed: onStartSignal,
                ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _PrimaryActionButton(
                  label: 'Начать',
                  icon: Icons.play_arrow_rounded,
                  loading: flowController.loading,
                  onPressed: canStart ? onStartRace : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DangerActionButton(
                  label: 'Финиш',
                  icon: Icons.stop_rounded,
                  loading: flowController.loading,
                  onPressed: canFinish ? onEndRace : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RaceTile extends StatelessWidget {
  const _RaceTile({
    required this.race,
  });

  final RaceSummaryDto race;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag_rounded,
            color: _AppColors.cyan,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Гонка ${race.raceId}',
              style: const TextStyle(
                fontSize: 15,
                color: _AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StatusBadge(
            text: race.status.wireNameRu,
            active: race.status == RaceStatus.inProgress,
            danger: race.status == RaceStatus.finished,
          ),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({
    required this.results,
    required this.participantLabels,
  });

  final RaceResultsResponseDto? results;
  final Map<int, String> participantLabels;

  @override
  Widget build(BuildContext context) {
    final data = results;

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.emoji_events_outlined,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Результаты',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (data == null)
            const _EmptyBlock(
              icon: Icons.leaderboard_outlined,
              title: 'Результаты не загружены',
              text: 'Выберите гонку и нажмите «Результаты».',
            )
          else ...[
            _InfoChip(
              icon: Icons.flag_rounded,
              text: 'Гонка #${data.raceId}',
            ),
            const SizedBox(height: 14),
            if (data.participants.isEmpty)
              const _EmptyBlock(
                icon: Icons.groups_outlined,
                title: 'Нет данных участников',
                text: 'Данные прогресса участников отсутствуют.',
              )
            else
              ...data.participants.map(
                    (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ParticipantResultTile(
                    item: item,
                    participantLabel: participantLabels[item.userId],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ParticipantResultTile extends StatelessWidget {
  const _ParticipantResultTile({
    required this.item,
    required this.participantLabel,
  });

  final ParticipantProgressDto item;
  final String? participantLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: _AppColors.cyan,
                size: 23,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  participantLabel ?? 'Участник (логин недоступен)',
                  style: const TextStyle(
                    color: _AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(
                text: _participantStatusLabel(item.status),
                active: item.status == ParticipantRaceProgressStatus.inRace,
                danger: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _KeyValueRow(
            label: 'Текущая отметка',
            value: _currentMarkLabel(item.currentMark),
            icon: Icons.place_rounded,
          ),
          const SizedBox(height: 8),
          _KeyValueRow(
            label: 'Старт',
            value: item.startedAt?.toString() ?? '—',
            icon: Icons.play_arrow_rounded,
          ),
          const SizedBox(height: 8),
          _KeyValueRow(
            label: 'Финиш',
            value: item.finishedAt?.toString() ?? '—',
            icon: Icons.stop_rounded,
          ),
        ],
      ),
    );
  }

  static String _participantStatusLabel(ParticipantRaceProgressStatus status) {
    return switch (status) {
      ParticipantRaceProgressStatus.notStarted => 'Не стартовал',
      ParticipantRaceProgressStatus.inRace => 'На дистанции',
      ParticipantRaceProgressStatus.finished => 'Финишировал',
    };
  }

  static String _currentMarkLabel(ParticipantCurrentMarkDto? currentMark) {
    if (currentMark == null) {
      return '—';
    }
    return '#${currentMark.index} (${currentMark.id})';
  }
}

class _RecentActionsTimeline extends StatelessWidget {
  const _RecentActionsTimeline({
    required this.actions,
  });

  final List<JudgeActionEntity> actions;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Журнал действий',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          if (actions.isEmpty)
            const _EmptyBlock(
              icon: Icons.timeline_rounded,
              title: 'Действий пока нет',
              text: 'После управления гонкой события появятся здесь.',
            )
          else
            ...actions.map(
                  (action) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ActionTile(action),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(this.action);

  final JudgeActionEntity action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.timeline_rounded,
            color: _AppColors.cyan,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _eventTypeLabel(action.eventType),
                  style: const TextStyle(
                    color: _AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Гонка: ${action.raceId ?? '-'} · ${_syncStatusLabel(action.syncStatus)}',
                  style: const TextStyle(
                    color: _AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  action.createdAtUtc.toIso8601String(),
                  style: const TextStyle(
                    color: _AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (action.payloadJson != null)
            Tooltip(
              message: action.payloadJson!,
              child: const Icon(
                Icons.info_outline_rounded,
                color: _AppColors.textMuted,
                size: 22,
              ),
            ),
        ],
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
  const _SignalButton({
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _AppColors.navy,
        disabledForegroundColor: _AppColors.textMuted,
        side: const BorderSide(color: _AppColors.border),
        backgroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(label),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(icon, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: _AppColors.cyan.withOpacity(0.28),
          backgroundColor: _AppColors.cyan,
          disabledBackgroundColor: _AppColors.cyan.withOpacity(0.45),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: _AppColors.navy,
          disabledForegroundColor: _AppColors.textMuted,
          side: const BorderSide(color: _AppColors.border),
          backgroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _DangerActionButton extends StatelessWidget {
  const _DangerActionButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const danger = Colors.redAccent;

    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(icon, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: danger.withOpacity(0.24),
          backgroundColor: danger,
          disabledBackgroundColor: danger.withOpacity(0.45),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _AppColors.border),
        boxShadow: [
          BoxShadow(
            color: _AppColors.navy.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _AppColors.navy,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.text,
    this.active = false,
    this.danger = false,
  });

  final String text;
  final bool active;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Colors.redAccent
        : active
        ? _AppColors.cyan
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: _AppColors.textMuted,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    color: _AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: _AppColors.navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({
    required this.icon,
    required this.text,
    this.danger = false,
  });

  final IconData icon;
  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : _AppColors.cyan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _AppColors.navy,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: _AppColors.cyan,
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AppColors.textMuted,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _AppColors.navy.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: _AppColors.navy,
            size: 23,
          ),
        ),
      ),
    );
  }
}

class _AppColors {
  static const navy = Color(0xFF061B3A);
  static const cyan = Color(0xFF00B8CC);
  static const textMuted = Color(0xFF667085);
  static const border = Color(0xFFD6DEE8);
  static const surface = Colors.white;
  static const lightSurface = Color(0xFFF2F6FA);
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
