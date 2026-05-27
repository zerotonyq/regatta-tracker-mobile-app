import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/management/data/management_remote_data_source.dart';
import '../../features/tracking/domain/tracking_health.dart';
import '../../features/tracking/domain/tracking_session_entity.dart';
import '../../features/tracking/presentation/tracking_session_controller.dart';

class ParticipantDashboardPage extends StatefulWidget {
  const ParticipantDashboardPage({
    required this.authController,
    required this.trackingController,
    required this.managementRemoteDataSource,
    required this.onStartRacing,
    required this.onOpenHistory,
    required this.onLogoutTap,
    super.key,
  });

  final AuthSessionController authController;
  final TrackingSessionController trackingController;
  final ManagementRemoteDataSource managementRemoteDataSource;
  final VoidCallback onStartRacing;
  final VoidCallback onOpenHistory;
  final VoidCallback onLogoutTap;

  @override
  State<ParticipantDashboardPage> createState() =>
      _ParticipantDashboardPageState();
}

class _ParticipantDashboardPageState extends State<ParticipantDashboardPage> {
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  ActiveRaceResponseDto? _activeRace;
  String? _activeRaceError;
  bool _loadingActiveRace = false;

  @override
  void initState() {
    super.initState();
    widget.trackingController.refreshHealth();
    _loadActiveRace();
  }

  Future<void> _startTracking() async {
    final raceId = _activeRace?.active == true ? _activeRace?.raceId : null;

    if (raceId == null) {
      return;
    }

    await widget.trackingController.start(raceId: raceId);

    if (mounted && widget.trackingController.error == null) {
      widget.onStartRacing();
    }
  }

  Future<void> _loadActiveRace() async {
    setState(() {
      _loadingActiveRace = true;
      _activeRaceError = null;
    });

    try {
      final activeRace =
      await widget.managementRemoteDataSource.getActiveRace();

      if (!mounted) {
        return;
      }

      setState(() {
        _activeRace = activeRace;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _activeRaceError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingActiveRace = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const background = Color(0xFFF8FBFD);
    const textMuted = Color(0xFF667085);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.trackingController,
          builder: (context, _) {
            final controller = widget.trackingController;

            final hasActiveRace =
                _activeRace?.active == true && _activeRace?.raceId != null;

            final hasRunningSession =
                controller.state == TrackingSessionState.preparing ||
                    controller.state == TrackingSessionState.tracking ||
                    controller.state == TrackingSessionState.paused ||
                    controller.state == TrackingSessionState.syncing;

            final canStartRace =
                hasActiveRace && controller.health.canStartTracking;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          _logoAsset,
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
                                  color: navy,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Панель участника',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _RoundIconButton(
                          icon: Icons.logout_rounded,
                          tooltip: 'Выйти',
                          onTap: widget.onLogoutTap,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    _WelcomeCard(
                      userId: widget.authController.userId.toString(),
                      sessionState: controller.state,
                    ),

                    const SizedBox(height: 16),

                    _ActiveRacePanel(
                      activeRace: _activeRace,
                      loading: _loadingActiveRace,
                      error: _activeRaceError,
                      onRefresh: _loadActiveRace,
                    ),

                    const SizedBox(height: 16),

                    _SessionStatusCard(
                      state: controller.state,
                      canStartTracking: controller.health.canStartTracking,
                      error: controller.error,
                    ),

                    const SizedBox(height: 24),

                    _PrimaryActionButton(
                      label: hasRunningSession
                          ? 'Открыть текущую сессию'
                          : 'Перейти в режим гонки',
                      icon: hasRunningSession
                          ? Icons.navigation_rounded
                          : Icons.play_arrow_rounded,
                      loading: controller.loading,
                      onPressed: hasRunningSession
                          ? widget.onStartRacing
                          : canStartRace
                          ? _startTracking
                          : null,
                    ),

                    const SizedBox(height: 12),

                    _SecondaryActionButton(
                      label: 'История и экспорт',
                      icon: Icons.history_rounded,
                      onPressed: widget.onOpenHistory,
                    ),

                    const SizedBox(height: 18),

                    if (!hasRunningSession && !canStartRace)
                      const _HintCard(
                        text:
                        'Для старта нужна активная гонка и разрешение на запись геолокации.',
                      ),
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

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.userId,
    required this.sessionState,
  });

  final String? userId;
  final TrackingSessionState sessionState;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const textMuted = Color(0xFF667085);

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.sailing_rounded,
                  color: cyan,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Готовы к гонке?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: navy,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Проверьте активную гонку и начните запись трека.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  color: navy,
                  size: 21,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'ID участника: ${userId ?? 'неизвестно'}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _InfoPill(
            icon: Icons.route_rounded,
            label: 'Сессия: ${sessionStateLabel(sessionState)}',
          ),
        ],
      ),
    );
  }
}

class _ActiveRacePanel extends StatelessWidget {
  const _ActiveRacePanel({
    required this.activeRace,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  final ActiveRaceResponseDto? activeRace;
  final bool loading;
  final String? error;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final race = activeRace;

    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const textMuted = Color(0xFF667085);

    Widget content;

    if (loading) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LinearProgressIndicator(
            minHeight: 4,
            color: cyan,
            backgroundColor: Color(0xFFEAF1F6),
          ),
          const SizedBox(height: 12),
          Text(
            'Получаем данные активной гонки...',
            style: TextStyle(
              color: textMuted.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      );
    } else if (error != null) {
      content = _StateMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Не удалось загрузить гонку',
        message: error!,
        danger: true,
      );
    } else if (race == null) {
      content = const _StateMessage(
        icon: Icons.info_outline_rounded,
        title: 'Данные еще не запрошены',
        message: 'Обновите информацию, чтобы проверить активную гонку.',
      );
    } else if (!race.active) {
      content = const _StateMessage(
        icon: Icons.flag_outlined,
        title: 'Активной гонки нет',
        message: 'Сейчас вам не назначена активная гонка.',
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(
                text: race.status?.wireNameRu ?? 'неизвестно',
                active: race.status == RaceStatus.inProgress,
              ),
              const Spacer(),
              const Icon(
                Icons.flag_rounded,
                color: cyan,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RaceInfoRow(
            label: 'ID гонки',
            value: '${race.raceId}',
            icon: Icons.tag_rounded,
          ),
          const SizedBox(height: 10),
          _RaceInfoRow(
            label: 'Время старта',
            value: race.startedAt?.toString() ?? 'не указано',
            icon: Icons.schedule_rounded,
          ),
        ],
      );
    }

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Активная гонка',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              _SmallRefreshButton(
                loading: loading,
                onRefresh: onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }
}

class _SessionStatusCard extends StatelessWidget {
  const _SessionStatusCard({
    required this.state,
    required this.canStartTracking,
    required this.error,
  });

  final TrackingSessionState state;
  final bool canStartTracking;
  final String? error;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);
    const textMuted = Color(0xFF667085);

    final isReady = canStartTracking && error == null;

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Готовность трекинга',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: navy,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isReady
                      ? cyan.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isReady
                      ? Icons.gps_fixed_rounded
                      : Icons.location_disabled_rounded,
                  color: isReady ? cyan : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isReady
                      ? 'Можно начинать запись трека'
                      : 'Трекинг пока недоступен',
                  style: const TextStyle(
                    fontSize: 16,
                    color: navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Состояние сессии: ${sessionStateLabel(state)}',
            style: const TextStyle(
              fontSize: 14,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _InlineError(text: error!),
          ],
        ],
      ),
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
    const cyan = Color(0xFF00B8CC);

    return SizedBox(
      width: double.infinity,
      height: 60,
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
            : Icon(icon, size: 24),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: cyan.withOpacity(0.28),
          backgroundColor: cyan,
          disabledBackgroundColor: cyan.withOpacity(0.45),
          foregroundColor: Colors.white,
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

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const borderColor = Color(0xFFD6DEE8);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: borderColor),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const borderColor = Color(0xFFD6DEE8);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const cyan = Color(0xFF00B8CC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: cyan, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallRefreshButton extends StatelessWidget {
  const _SmallRefreshButton({
    required this.loading,
    required this.onRefresh,
  });

  final bool loading;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00B8CC);

    return InkWell(
      onTap: loading ? null : onRefresh,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const Padding(
          padding: EdgeInsets.all(11),
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(cyan),
          ),
        )
            : const Icon(
          Icons.refresh_rounded,
          color: cyan,
          size: 24,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const textMuted = Color(0xFF667085);

    final color = danger ? Colors.redAccent : const Color(0xFF00B8CC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
    required this.active,
  });

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF00B8CC) : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RaceInfoRow extends StatelessWidget {
  const _RaceInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B3A);
    const textMuted = Color(0xFF667085);

    return Row(
      children: [
        Icon(icon, color: textMuted, size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            color: textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    const textMuted = Color(0xFF667085);

    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: textMuted,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w500,
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
    const navy = Color(0xFF061B3A);

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
                color: navy.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: navy,
            size: 23,
          ),
        ),
      ),
    );
  }
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

extension on RaceStatus {
  String get wireNameRu {
    return switch (this) {
      RaceStatus.notStarted => 'не началась',
      RaceStatus.inProgress => 'идет',
      RaceStatus.finished => 'завершена',
    };
  }
}