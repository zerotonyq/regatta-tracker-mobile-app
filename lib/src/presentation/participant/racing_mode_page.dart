import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../features/race_computer/domain/race_state_entity.dart';
import '../../features/race_computer/domain/start_procedure_entity.dart';
import '../../features/race_computer/presentation/race_computer_controller.dart';
import '../../features/tracking/domain/tracking_session_entity.dart';
import '../../features/tracking/presentation/tracking_session_controller.dart';
import '../widgets/app_button.dart';
import 'participant_dashboard_page.dart';

class RacingModePage extends StatefulWidget {
  const RacingModePage({
    required this.controller,
    required this.raceComputerController,
    required this.onBack,
    super.key,
  });

  final TrackingSessionController controller;
  final RaceComputerController raceComputerController;
  final VoidCallback onBack;

  @override
  State<RacingModePage> createState() => _RacingModePageState();
}

class _RacingModePageState extends State<RacingModePage> {
  int? _lastSessionId;
  int? _referenceCourseAttemptedSessionId;
  int? _resumeRequestedSessionId;
  TrackingProfile? _lastPublishedProfile;
  String? _lastCueToken;
  Timer? _refreshTimer;
  bool _controllerEffectsScheduled = false;
  bool _raceComputerEffectsScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChange);
    widget.raceComputerController.addListener(_handleRaceComputerChange);
    _refreshRaceComputerIfNeeded();
    _syncRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant RacingModePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChange);
      widget.controller.addListener(_handleControllerChange);
    }
    if (oldWidget.raceComputerController != widget.raceComputerController) {
      oldWidget.raceComputerController.removeListener(
        _handleRaceComputerChange,
      );
      widget.raceComputerController.addListener(_handleRaceComputerChange);
    }
    _refreshRaceComputerIfNeeded();
    _syncRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    widget.controller.removeListener(_handleControllerChange);
    widget.raceComputerController.removeListener(_handleRaceComputerChange);
    super.dispose();
  }

  void _handleControllerChange() {
    _refreshRaceComputerIfNeeded();
    _syncRefreshTimer();
    if (_controllerEffectsScheduled) {
      return;
    }
    _controllerEffectsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerEffectsScheduled = false;
      if (!mounted) {
        return;
      }
      unawaited(_ensureTrackingActive());
      unawaited(_syncRecommendedTrackingProfile());
    });
  }

  void _handleRaceComputerChange() {
    final startProcedure = widget.raceComputerController.state?.startProcedure;
    _triggerCueIfNeeded(startProcedure);
    if (_raceComputerEffectsScheduled) {
      return;
    }
    _raceComputerEffectsScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _raceComputerEffectsScheduled = false;
      if (!mounted) {
        return;
      }
      unawaited(_syncRecommendedTrackingProfile());
      unawaited(_ensureReferenceCourseIfNeeded());
    });
  }

  void _refreshRaceComputerIfNeeded() {
    final session = widget.controller.session;
    if (session == null || session.id == _lastSessionId) {
      return;
    }
    _lastSessionId = session.id;
    _referenceCourseAttemptedSessionId = null;
    unawaited(_refreshRaceComputer());
  }

  void _syncRefreshTimer() {
    final session = widget.controller.session;
    final shouldRefresh =
        session != null &&
        widget.controller.state != TrackingSessionState.completed &&
        widget.controller.state != TrackingSessionState.failed &&
        widget.controller.state != TrackingSessionState.idle;
    if (!shouldRefresh) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }
    if (_refreshTimer != null) {
      return;
    }
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_refreshRaceComputer());
    });
  }

  Future<void> _syncRecommendedTrackingProfile() async {
    final session = widget.controller.session;
    final recommended =
        widget.raceComputerController.state?.recommendedTrackingProfile;
    if (session == null || recommended == null) {
      return;
    }
    if (_lastPublishedProfile == recommended ||
        widget.controller.activeTrackingProfile == recommended) {
      return;
    }
    _lastPublishedProfile = recommended;
    await widget.controller.setTrackingProfile(recommended);
  }

  Future<void> _ensureTrackingActive() async {
    final session = widget.controller.session;
    if (session == null) {
      return;
    }
    if (widget.controller.state != TrackingSessionState.paused) {
      return;
    }
    if (!widget.controller.health.canStartTracking) {
      return;
    }
    if (_resumeRequestedSessionId == session.id || widget.controller.loading) {
      return;
    }

    _resumeRequestedSessionId = session.id;
    try {
      await widget.controller.resume();
    } finally {
      if (_resumeRequestedSessionId == session.id) {
        _resumeRequestedSessionId = null;
      }
    }
  }

  Future<void> _ensureReferenceCourseIfNeeded() async {
    final session = widget.controller.session;
    final state = widget.raceComputerController.state;
    if (session == null || state == null) {
      return;
    }
    if (state.course != null || state.phase == 'awaiting_gps') {
      return;
    }
    if (_referenceCourseAttemptedSessionId == session.id) {
      return;
    }

    _referenceCourseAttemptedSessionId = session.id;
    try {
      await widget.raceComputerController.createReferenceCourse(
        sessionId: session.id,
        raceId: session.raceId,
      );
    } catch (_) {
      // Ошибку покажет сам controller, здесь важно только не зациклиться.
    }
  }

  void _triggerCueIfNeeded(StartProcedureEntity? startProcedure) {
    if (startProcedure == null ||
        startProcedure.cue == StartProcedureCue.none) {
      return;
    }
    final token = '${startProcedure.cue.name}-${startProcedure.phase}';
    if (_lastCueToken == token) {
      return;
    }
    _lastCueToken = token;
    SystemSound.play(SystemSoundType.alert);
    if (startProcedure.cue == StartProcedureCue.warning) {
      HapticFeedback.mediumImpact();
      return;
    }
    if (startProcedure.cue == StartProcedureCue.preparatory) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (startProcedure.cue == StartProcedureCue.oneMinute) {
      HapticFeedback.vibrate();
      return;
    }
    if (startProcedure.cue == StartProcedureCue.start) {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _refreshRaceComputer() async {
    final session = widget.controller.session;
    if (session == null || widget.raceComputerController.loading) {
      return;
    }
    await widget.raceComputerController.refresh(
      sessionId: session.id,
      raceId: session.raceId,
    );
  }

  String _formatCountdown(int remainingSeconds) {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _profileLabel(TrackingProfile profile) {
    return switch (profile) {
      TrackingProfile.prestartPrecision => 'точный предстарт',
      TrackingProfile.raceCruise => 'гонка',
      TrackingProfile.markRoundingPrecision => 'огибание знака',
      TrackingProfile.paused => 'пауза',
    };
  }

  String _cueLabel(StartProcedureCue cue) {
    return switch (cue) {
      StartProcedureCue.none => 'нет',
      StartProcedureCue.warning => 'предупредительный',
      StartProcedureCue.preparatory => 'подготовительный',
      StartProcedureCue.oneMinute => 'одна минута',
      StartProcedureCue.start => 'старт',
    };
  }

  String _trackingProfileLabel() {
    final active = widget.controller.activeTrackingProfile;
    if (active != null) {
      return _profileLabel(active);
    }
    final recommended =
        widget.raceComputerController.state?.recommendedTrackingProfile;
    return recommended == null
        ? 'нет данных'
        : '${_profileLabel(recommended)} (ожидает применения)';
  }

  String _formatSampleAge(int? valueMs) {
    if (valueMs == null) {
      return 'н/д';
    }
    if (valueMs < 1000) {
      return '$valueMs мс';
    }
    return '${(valueMs / 1000).toStringAsFixed(1)} с';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Режим гонки')),
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          widget.controller,
          widget.raceComputerController,
        ]),
        builder: (context, _) {
          final session = widget.controller.session;
          final health = widget.controller.health;
          final raceState = widget.raceComputerController.state;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Гонка: ${session?.raceId ?? '-'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Состояние сессии: ${sessionStateLabel(widget.controller.state)}',
                ),
                const SizedBox(height: 8),
                Text('Ожидают досылки: ${health.pendingSyncCount}'),
                const SizedBox(height: 8),
                Text(
                  'Последний GPS-сэмпл: ${_formatSampleAge(health.lastGpsSampleAgeMs)} назад',
                ),
                const SizedBox(height: 8),
                Text(
                  'Точность GPS: ${health.gpsAccuracyMeters?.toStringAsFixed(1) ?? 'н/д'} м',
                ),
                const SizedBox(height: 8),
                Text(
                  'Частота GPS: ${_formatRate(health.averageGpsRateHz)} / ${_formatRate(health.targetGpsHz)}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Частота IMU: ${_formatRate(health.averageImuRateHz)} / ${_formatRate(health.targetImuHz)}',
                ),
                if (health.hasTelemetryWarning) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Фактическая частота датчиков ниже целевой.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text('Профиль трекинга: ${_trackingProfileLabel()}'),
                const SizedBox(height: 8),
                Text('GPS: ${health.gpsEnabled ? 'включен' : 'выключен'}'),
                const SizedBox(height: 8),
                Text(
                  'Доступ к геолокации: ${permissionLabel(health.locationPermission)}',
                ),
                if (widget.controller.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Ошибка трекинга: ${widget.controller.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (widget.raceComputerController.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Ошибка расчета гонки: ${widget.raceComputerController.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _RaceComputerCard(
                        raceState: raceState,
                        formatCountdown: _formatCountdown,
                        cueLabel: _cueLabel,
                        profileLabel: _profileLabel,
                      ),
                    ],
                  ),
                ),
                if (widget.controller.state == TrackingSessionState.tracking ||
                    widget.controller.state == TrackingSessionState.preparing ||
                    widget.controller.state == TrackingSessionState.syncing ||
                    widget.controller.state == TrackingSessionState.paused)
                  AppButton(
                    label: 'Завершить трекинг',
                    variant: AppButtonVariant.danger,
                    fullWidth: true,
                    loading: widget.controller.loading,
                    onPressed: () async {
                      await widget.controller.stop();
                      widget.onBack();
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatRate(double? value) {
    return value == null ? 'н/д' : '${value.toStringAsFixed(1)} Гц';
  }
}

class _RaceComputerCard extends StatelessWidget {
  const _RaceComputerCard({
    required this.raceState,
    required this.formatCountdown,
    required this.cueLabel,
    required this.profileLabel,
  });

  final RaceStateEntity? raceState;
  final String Function(int) formatCountdown;
  final String Function(StartProcedureCue) cueLabel;
  final String Function(TrackingProfile) profileLabel;

  @override
  Widget build(BuildContext context) {
    final state = raceState;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Расчет состояния гонки',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              state == null
                  ? 'Данные о состоянии гонки еще не рассчитаны.'
                  : state.statusMessage,
            ),
            if (state != null) ...[
              const SizedBox(height: 12),
              Text('Фаза: ${_phaseLabel(state.phase)}'),
              Text(
                'Уверенность: ${(state.confidence * 100).toStringAsFixed(0)}%',
              ),
              Text('Курс: ${state.course?.name ?? 'не настроен'}'),
              if (state.startLine != null) ...[
                Text(
                  'Дистанция до линии: ${state.startLine!.distanceToLineMeters.toStringAsFixed(1)} м',
                ),
                Text(
                  'Предпочтительный конец линии: ${_favoredEndLabel(state.startLine!.favoredEnd)}',
                ),
                Text(
                  'Боковое смещение: ${state.startLine!.lateralOffsetMeters.toStringAsFixed(1)} м',
                ),
                Text(
                  'Скорость сближения: ${state.startLine!.lineClosingSpeedMetersPerSecond.toStringAsFixed(2)} м/с',
                ),
              ],
              if (state.startProcedure != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Стартовый таймер: T-${formatCountdown(state.startProcedure!.remainingSeconds)}',
                ),
                Text(
                  'Фаза старта: ${_phaseLabel(state.startProcedure!.phase)}',
                ),
                Text(
                  'Прогресс старта: ${(state.startProcedure!.progress * 100).toStringAsFixed(0)}%',
                ),
                Text(
                  'Последний сигнал: ${cueLabel(state.startProcedure!.cue)}',
                ),
                if (state.startProcedure!.lastSignalType != null)
                  Text(
                    'Сигнал судьи: ${_signalTypeLabel(state.startProcedure!.lastSignalType!)}',
                  ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: state.startProcedure!.progress),
              ],
              if (state.nextMark != null) ...[
                const SizedBox(height: 8),
                Text('Следующий знак: ${state.nextMark!.markName}'),
                Text(
                  'Дистанция до знака: ${state.nextMark!.distanceMeters.toStringAsFixed(1)} м',
                ),
                Text(
                  'Пеленг на знак: ${state.nextMark!.bearingDegrees.toStringAsFixed(0)}°',
                ),
                Text(
                  'ETA: ${state.nextMark!.etaSeconds?.toString() ?? 'н/д'} с',
                ),
              ],
              if (state.windEstimate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Оценка ветра: ${state.windEstimate!.directionDegrees.toStringAsFixed(0)}°',
                ),
                Text(
                  'Качество оценки: ${state.windEstimate!.qualityLabel ?? 'н/д'}',
                ),
              ],
              if (state.laylineHint != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Рекомендованный галс: ${_tackLabel(state.laylineHint!.targetTack)}',
                ),
                Text(
                  'Рекомендованный пеленг: ${state.laylineHint!.bearingDegrees.toStringAsFixed(0)}°',
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Рекомендуемый профиль моста: ${profileLabel(state.recommendedTrackingProfile)}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _signalTypeLabel(String signalType) {
    return switch (signalType) {
      'warning' => 'предупредительный',
      'preparatory' => 'подготовительный',
      'start' => 'старт',
      'configured' => 'процедура запланирована',
      _ => signalType,
    };
  }

  static String _phaseLabel(String phase) {
    return switch (phase) {
      'awaiting_gps' => 'ожидание GPS',
      'awaiting_course' => 'ожидание опорного курса',
      'prestart_countdown' => 'предстартовый отсчет',
      'prestart_geometry' => 'выход на старт',
      'racing' => 'гонка',
      'warning' => 'предупредительный сигнал',
      'preparatory' => 'подготовительный сигнал',
      'final_minute' => 'последняя минута до старта',
      'started' => 'старт дан',
      _ => phase,
    };
  }

  static String _favoredEndLabel(String favoredEnd) {
    return switch (favoredEnd) {
      'port' => 'левый конец',
      'starboard' => 'правый конец',
      _ => favoredEnd,
    };
  }

  static String _tackLabel(String targetTack) {
    return switch (targetTack) {
      'port' => 'левый галс',
      'starboard' => 'правый галс',
      _ => targetTack,
    };
  }
}
