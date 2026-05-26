import 'package:flutter/material.dart';

import '../../features/api/models/api_models.dart';
import '../../features/auth/presentation/auth_session_controller.dart';
import '../../features/management/data/management_remote_data_source.dart';
import '../../features/tracking/domain/tracking_health.dart';
import '../../features/tracking/domain/tracking_session_entity.dart';
import '../../features/tracking/presentation/tracking_session_controller.dart';
import '../widgets/app_button.dart';

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
  final _raceIdController = TextEditingController();
  ActiveRaceResponseDto? _activeRace;
  String? _activeRaceError;
  bool _loadingActiveRace = false;

  @override
  void initState() {
    super.initState();
    widget.trackingController.refreshHealth();
    _loadActiveRace();
  }

  @override
  void dispose() {
    _raceIdController.dispose();
    super.dispose();
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
      final activeRace = await widget.managementRemoteDataSource
          .getActiveRace();
      if (!mounted) {
        return;
      }
      setState(() {
        _activeRace = activeRace;
        if (activeRace.active && activeRace.raceId != null) {
          _raceIdController.text = activeRace.raceId.toString();
        } else {
          _raceIdController.clear();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _activeRaceError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loadingActiveRace = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель участника'),
        actions: [
          IconButton(
            onPressed: widget.onLogoutTap,
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: AnimatedBuilder(
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

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  'Трекинг гонки',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ваш id участника: ${widget.authController.userId ?? 'неизвестно'}',
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                _ActiveRacePanel(
                  activeRace: _activeRace,
                  loading: _loadingActiveRace,
                  error: _activeRaceError,
                  onRefresh: _loadActiveRace,
                ),
                const SizedBox(height: 16),
                _HealthPanel(health: controller.health),
                const SizedBox(height: 16),
                Text(
                  'Состояние сессии: ${sessionStateLabel(controller.state)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (controller.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Ошибка: ${controller.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _raceIdController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'ID активной гонки',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: hasRunningSession
                      ? 'Открыть текущую сессию'
                      : 'Перейти в режим гонки',
                  fullWidth: true,
                  loading: controller.loading,
                  variant: AppButtonVariant.success,
                  onPressed: hasRunningSession
                      ? widget.onStartRacing
                      : (hasActiveRace && controller.health.canStartTracking
                            ? _startTracking
                            : null),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'История и экспорт',
                  fullWidth: true,
                  variant: AppButtonVariant.secondary,
                  onPressed: widget.onOpenHistory,
                ),
              ],
            ),
          );
        },
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Активная гонка',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (loading)
              const LinearProgressIndicator()
            else if (error != null)
              Text(
                'Не удалось загрузить активную гонку: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (race == null)
              const Text('Данные об активной гонке еще не запрошены.')
            else if (!race.active)
              const Text('Сейчас вам не назначена активная гонка.')
            else ...[
              Text('ID гонки: ${race.raceId}'),
              Text('Статус: ${race.status?.wireNameRu ?? 'неизвестно'}'),
              Text('Время старта: ${race.startedAt ?? 'не указано'}'),
            ],
            const SizedBox(height: 12),
            AppButton(
              label: 'Обновить гонку',
              fullWidth: true,
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: loading ? null : onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthPanel extends StatelessWidget {
  const _HealthPanel({required this.health});

  final TrackingHealth health;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Состояние трекинга',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text('GPS: ${health.gpsEnabled ? 'включен' : 'выключен'}'),
            Text(
              'Доступ к геолокации: ${permissionLabel(health.locationPermission)}',
            ),
            Text(
              'Доступ к датчикам движения: ${permissionLabel(health.motionPermission)}',
            ),
            Text('IMU-мост: ${health.imuEnabled ? 'готов' : 'недоступен'}'),
            Text(
              'Фоновая служба: ${health.backgroundServiceRunning ? 'работает' : 'остановлена'}',
            ),
            Text(
              'Точность GPS: ${health.gpsAccuracyMeters?.toStringAsFixed(1) ?? 'н/д'} м',
            ),
            Text(
              'Частота GPS: ${_formatRate(health.averageGpsRateHz)} / ${_formatRate(health.targetGpsHz)}',
            ),
            Text(
              'Частота IMU: ${_formatRate(health.averageImuRateHz)} / ${_formatRate(health.targetImuHz)}',
            ),
            if (health.hasTelemetryWarning)
              Text(
                'Предупреждение: фактическая частота датчиков ниже целевой.',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            Text('Ожидают досылки: ${health.pendingSyncCount}'),
            Text('Потеряно сэмплов: ${health.droppedSampleCount}'),
          ],
        ),
      ),
    );
  }

  String _formatRate(double? value) {
    return value == null ? 'н/д' : '${value.toStringAsFixed(1)} Гц';
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
