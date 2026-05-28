import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../../features/race_computer/domain/race_state_entity.dart';
import '../../features/race_computer/domain/start_procedure_entity.dart';
import '../../features/race_computer/presentation/race_computer_controller.dart';
import '../../features/track_map/presentation/track_map_controller.dart';
import '../../features/tracking/domain/tracking_health.dart';
import '../../features/tracking/domain/tracking_session_entity.dart';
import '../../features/tracking/presentation/tracking_session_controller.dart';
import '../maps/regatta_map_view.dart';

class RacingModePage extends StatefulWidget {
  const RacingModePage({
    required this.controller,
    required this.raceComputerController,
    required this.trackMapController,
    required this.onBack,
    super.key,
  });

  final TrackingSessionController controller;
  final RaceComputerController raceComputerController;
  final TrackMapController trackMapController;
  final VoidCallback onBack;

  @override
  State<RacingModePage> createState() => _RacingModePageState();
}

class _RacingModePageState extends State<RacingModePage> {
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

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
    widget.trackMapController.addListener(_handleTrackMapChange);
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

    if (oldWidget.trackMapController != widget.trackMapController) {
      oldWidget.trackMapController.removeListener(_handleTrackMapChange);
      widget.trackMapController.addListener(_handleTrackMapChange);
    }

    _refreshRaceComputerIfNeeded();
    _syncRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    widget.controller.removeListener(_handleControllerChange);
    widget.raceComputerController.removeListener(_handleRaceComputerChange);
    widget.trackMapController.removeListener(_handleTrackMapChange);
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

  void _handleTrackMapChange() {
    if (mounted) {
      setState(() {});
    }
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
    final shouldRefresh = session != null &&
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
      // Ошибку покажет controller, здесь важно не зациклиться.
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
    await widget.trackMapController.load(sessionId: session.id);
  }

  Future<void> _stopTracking() async {
    await widget.controller.stop();
    if (mounted) {
      widget.onBack();
    }
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

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FBFD);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[
            widget.controller,
            widget.raceComputerController,
          ]),
          builder: (context, _) {
            final session = widget.controller.session;
            final health = widget.controller.health;
            final raceState = widget.raceComputerController.state;
            final trackPoints = widget.trackMapController.points;

            final isActiveSession =
                widget.controller.state == TrackingSessionState.tracking ||
                    widget.controller.state == TrackingSessionState.preparing ||
                    widget.controller.state == TrackingSessionState.syncing ||
                    widget.controller.state == TrackingSessionState.paused;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          _logoAsset,
                          width: 42,
                          height: 42,
                        ),
                        const SizedBox(width: 12),
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
                                'Режим гонки',
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
                          icon: Icons.refresh_rounded,
                          tooltip: 'Обновить',
                          onTap: () {
                            unawaited(_refreshRaceComputer());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _HeroRaceCard(
                      raceId: session?.raceId,
                      sessionState: widget.controller.state,
                      statusMessage: raceState?.statusMessage,
                    ),
                    const SizedBox(height: 16),
                    _MapCard(
                      child: SizedBox(
                        height: 260,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: RegattaMapView(
                            key: const ValueKey('racing-mode-map'),
                            trackPoints: trackPoints,
                            currentPoint: widget.trackMapController.currentPoint,
                            course: raceState?.course,
                            emptyMessage: 'Ждем GPS для построения трека',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TrackingStatusCard(
                      sessionState: widget.controller.state,
                      trackingProfileLabel: _trackingProfileLabel(),
                      health: health,
                      trackingError: widget.controller.error,
                      raceComputerError: widget.raceComputerController.error,
                    ),
                    const SizedBox(height: 16),
                    _RaceComputerCard(
                      raceState: raceState,
                      formatCountdown: _formatCountdown,
                      cueLabel: _cueLabel,
                      profileLabel: _profileLabel,
                    ),
                    if (isActiveSession) ...[
                      const SizedBox(height: 20),
                      _DangerActionButton(
                        label: 'Завершить трекинг',
                        loading: widget.controller.loading,
                        onPressed: _stopTracking,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
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

class _HeroRaceCard extends StatelessWidget {
  const _HeroRaceCard({
    required this.raceId,
    required this.sessionState,
    required this.statusMessage,
  });

  final int? raceId;
  final TrackingSessionState sessionState;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.sailing_rounded,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Гонка в процессе',
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
                icon: Icons.flag_rounded,
                text: 'Гонка #${raceId ?? '—'}',
              ),
              _InfoChip(
                icon: Icons.route_rounded,
                text: 'Сессия: ${sessionStateLabel(sessionState)}',
              ),
            ],
          ),
          if (statusMessage != null && statusMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _AppColors.cyan.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                statusMessage!,
                style: const TextStyle(
                  color: _AppColors.navy,
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 4, 6, 12),
            child: Text(
              'Карта и трек',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _AppColors.navy,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _TrackingStatusCard extends StatelessWidget {
  const _TrackingStatusCard({
    required this.sessionState,
    required this.trackingProfileLabel,
    required this.health,
    required this.trackingError,
    required this.raceComputerError,
  });

  final TrackingSessionState sessionState;
  final String trackingProfileLabel;
  final TrackingHealth health;
  final String? trackingError;
  final String? raceComputerError;

  @override
  Widget build(BuildContext context) {
    final warnings = <Widget>[];

    if (health.hasTelemetryWarning) {
      warnings.add(
        const _InlineBanner(
          icon: Icons.sensors_off_rounded,
          text: 'Фактическая частота датчиков ниже целевой.',
          danger: true,
        ),
      );
    }

    if (!health.gpsEnabled) {
      warnings.add(
        const _InlineBanner(
          icon: Icons.gps_off_rounded,
          text: 'GPS выключен.',
          danger: true,
        ),
      );
    }

    if (health.locationPermission == TrackingPermissionState.denied) {
      warnings.add(
        const _InlineBanner(
          icon: Icons.location_disabled_rounded,
          text: 'Доступ к геолокации не выдан.',
          danger: true,
        ),
      );
    }

    if (trackingError != null && trackingError!.isNotEmpty) {
      warnings.add(
        _InlineBanner(
          icon: Icons.error_outline_rounded,
          text: 'Ошибка трекинга: $trackingError',
          danger: true,
        ),
      );
    }

    if (raceComputerError != null && raceComputerError!.isNotEmpty) {
      warnings.add(
        _InlineBanner(
          icon: Icons.warning_amber_rounded,
          text: 'Ошибка расчета гонки: $raceComputerError',
          danger: true,
        ),
      );
    }

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статус трекинга',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          _KeyValueRow(
            label: 'Состояние',
            value: sessionStateLabel(sessionState),
            icon: Icons.timelapse_rounded,
          ),
          const SizedBox(height: 10),
          _KeyValueRow(
            label: 'Профиль трекинга',
            value: trackingProfileLabel,
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 10),
          _KeyValueRow(
            label: 'GPS',
            value: health.gpsEnabled ? 'включен' : 'выключен',
            icon: Icons.gps_fixed_rounded,
          ),
          const SizedBox(height: 10),
          _KeyValueRow(
            label: 'Доступ к геолокации',
            value: permissionLabel(health.locationPermission),
            icon: Icons.location_on_outlined,
          ),
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: 14),
            ..._withGaps(warnings, 10),
          ],
        ],
      ),
    );
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

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расчет состояния гонки',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state == null
                ? 'Данные о состоянии гонки еще не рассчитаны.'
                : state.statusMessage,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state != null) ...[
            const SizedBox(height: 18),
            _SectionTitle('Общие данные'),
            const SizedBox(height: 10),
            _KeyValueRow(
              label: 'Фаза',
              value: _phaseLabel(state.phase),
              icon: Icons.flag_circle_rounded,
            ),
            const SizedBox(height: 10),
            _KeyValueRow(
              label: 'Уверенность',
              value: '${(state.confidence * 100).toStringAsFixed(0)}%',
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 10),
            _KeyValueRow(
              label: 'Рекомендуемый профиль',
              value: profileLabel(state.recommendedTrackingProfile),
              icon: Icons.settings_suggest_rounded,
            ),
            if (state.startLine != null) ...[
              const SizedBox(height: 18),
              _SectionTitle('Стартовая линия'),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Дистанция до линии',
                value:
                '${state.startLine!.distanceToLineMeters.toStringAsFixed(1)} м',
                icon: Icons.swap_horiz_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Предпочтительный конец',
                value: _favoredEndLabel(state.startLine!.favoredEnd),
                icon: Icons.outlined_flag_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Боковое смещение',
                value:
                '${state.startLine!.lateralOffsetMeters.toStringAsFixed(1)} м',
                icon: Icons.open_in_full_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Скорость сближения',
                value:
                '${state.startLine!.lineClosingSpeedMetersPerSecond.toStringAsFixed(2)} м/с',
                icon: Icons.speed_rounded,
              ),
            ],
            if (state.startProcedure != null) ...[
              const SizedBox(height: 18),
              _SectionTitle('Стартовая процедура'),
              const SizedBox(height: 10),
              _CountdownPanel(
                text:
                'T-${formatCountdown(state.startProcedure!.remainingSeconds)}',
              ),
              const SizedBox(height: 12),
              _KeyValueRow(
                label: 'Фаза старта',
                value: _phaseLabel(state.startProcedure!.phase),
                icon: Icons.hourglass_top_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Последний сигнал',
                value: cueLabel(state.startProcedure!.cue),
                icon: Icons.notifications_active_rounded,
              ),
              if (state.startProcedure!.lastSignalType != null) ...[
                const SizedBox(height: 10),
                _KeyValueRow(
                  label: 'Сигнал судьи',
                  value: _signalTypeLabel(
                    state.startProcedure!.lastSignalType!,
                  ),
                  icon: Icons.campaign_rounded,
                ),
              ],
            ],
            if (state.nextMark != null) ...[
              const SizedBox(height: 18),
              _SectionTitle('Следующий знак'),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Название',
                value: state.nextMark!.markName,
                icon: Icons.place_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Дистанция',
                value: '${state.nextMark!.distanceMeters.toStringAsFixed(1)} м',
                icon: Icons.straighten_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Пеленг',
                value:
                '${state.nextMark!.bearingDegrees.toStringAsFixed(0)}°',
                icon: Icons.explore_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'ETA',
                value: '${state.nextMark!.etaSeconds?.toString() ?? 'н/д'} с',
                icon: Icons.schedule_rounded,
              ),
            ],
            if (state.windEstimate != null) ...[
              const SizedBox(height: 18),
              _SectionTitle('Оценка ветра'),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Направление',
                value:
                '${state.windEstimate!.directionDegrees.toStringAsFixed(0)}°',
                icon: Icons.air_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Качество оценки',
                value: state.windEstimate!.qualityLabel ?? 'н/д',
                icon: Icons.analytics_rounded,
              ),
            ],
            if (state.laylineHint != null) ...[
              const SizedBox(height: 18),
              _SectionTitle('Подсказка по галсу'),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Рекомендованный галс',
                value: _tackLabel(state.laylineHint!.targetTack),
                icon: Icons.compare_arrows_rounded,
              ),
              const SizedBox(height: 10),
              _KeyValueRow(
                label: 'Рекомендованный пеленг',
                value:
                '${state.laylineHint!.bearingDegrees.toStringAsFixed(0)}°',
                icon: Icons.navigation_rounded,
              ),
            ],
          ],
        ],
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

class _CountdownPanel extends StatelessWidget {
  const _CountdownPanel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _AppColors.cyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: _AppColors.navy,
          letterSpacing: -0.6,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: _AppColors.navy,
        fontWeight: FontWeight.w800,
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
                const TextSpan(
                  text: '',
                ),
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

class _DangerActionButton extends StatelessWidget {
  const _DangerActionButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const danger = Colors.redAccent;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.stop_rounded),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: danger.withOpacity(0.28),
          backgroundColor: danger,
          foregroundColor: Colors.white,
          disabledBackgroundColor: danger.withOpacity(0.5),
          textStyle: const TextStyle(
            fontSize: 18,
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

List<Widget> _withGaps(List<Widget> children, double gap) {
  final result = <Widget>[];

  for (var i = 0; i < children.length; i++) {
    result.add(children[i]);
    if (i != children.length - 1) {
      result.add(SizedBox(height: gap));
    }
  }

  return result;
}

String permissionLabel(TrackingPermissionState permission) {
  return switch (permission) {
    TrackingPermissionState.granted => 'разрешено',
    TrackingPermissionState.denied => 'запрещено',
    TrackingPermissionState.deniedForever => 'запрещено навсегда',
    TrackingPermissionState.unknown => 'неизвестно',
  };
}

String sessionStateLabel(TrackingSessionState state) {
  return switch (state) {
    TrackingSessionState.idle => 'не запущена',
    TrackingSessionState.preparing => 'подготовка',
    TrackingSessionState.tracking => 'идет запись',
    TrackingSessionState.paused => 'пауза',
    TrackingSessionState.syncing => 'синхронизация',
    TrackingSessionState.completed => 'завершена',
    TrackingSessionState.failed => 'ошибка',
  };
}
