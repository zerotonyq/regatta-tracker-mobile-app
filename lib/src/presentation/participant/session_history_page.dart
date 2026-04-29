import 'package:flutter/material.dart';

import '../../features/export/domain/diagnostics_snapshot_entity.dart';
import '../../features/export/domain/export_format.dart';
import '../../features/export/domain/session_summary_entity.dart';
import '../../features/export/presentation/export_controller.dart';
import '../widgets/app_button.dart';

class SessionHistoryPage extends StatefulWidget {
  const SessionHistoryPage({
    required this.controller,
    required this.onBack,
    super.key,
  });

  final ExportController controller;
  final VoidCallback onBack;

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История сессий'),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final diagnostics = widget.controller.diagnostics;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                if (diagnostics != null) _DiagnosticsCard(diagnostics: diagnostics),
                if (widget.controller.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.controller.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                if (widget.controller.lastExport != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Последний экспорт: ${widget.controller.lastExport!.fileName}\n${widget.controller.lastExport!.filePath}',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Завершенные сессии',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (widget.controller.sessions.isEmpty && !widget.controller.loading)
                  const Text(
                    'Завершенных сессий пока нет.',
                  )
                else
                  ...widget.controller.sessions.map(
                    (session) => _SessionSummaryCard(
                      session: session,
                      loading: widget.controller.loading,
                      onExport: (format) => widget.controller.export(
                        sessionId: session.sessionId,
                        format: format,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard({required this.diagnostics});

  final DiagnosticsSnapshotEntity diagnostics;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Диагностика',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Версия приложения: ${diagnostics.appVersion}'),
            Text('Схема БД: ${diagnostics.databaseSchemaVersion}'),
            Text('Геолокация: ${diagnostics.locationPermission}'),
            Text('Датчики движения: ${diagnostics.motionPermission}'),
            Text('GPS включен: ${diagnostics.gpsEnabled}'),
            Text('IMU включен: ${diagnostics.imuEnabled}'),
            Text('Фоновая служба: ${diagnostics.backgroundServiceRunning}'),
            Text(
              'Средняя частота GPS: ${diagnostics.averageGpsRateHz.toStringAsFixed(2)} Гц',
            ),
            Text(
              'Средняя частота IMU: ${diagnostics.averageImuRateHz.toStringAsFixed(2)} Гц',
            ),
            Text('Потеряно сэмплов: ${diagnostics.droppedSamples}'),
            Text('Задержка синхронизации: ${diagnostics.syncLagSeconds} с'),
            Text('Ожидают досылки: ${diagnostics.pendingSyncJobs}'),
            Text(
              'Маркеры нагрузки батареи: ${diagnostics.batteryImpactMarkers.isEmpty ? 'нет' : diagnostics.batteryImpactMarkers.join(', ')}',
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({
    required this.session,
    required this.loading,
    required this.onExport,
  });

  final SessionSummaryEntity session;
  final bool loading;
  final Future<void> Function(ExportFormat format) onExport;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сессия ${session.sessionId} | гонка ${session.raceId}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Роль: ${_roleLabel(session.role)}'),
            Text('Состояние: ${_sessionStateLabel(session.state)}'),
            Text(
              'Длительность: ${session.duration.inMinutes} мин ${session.duration.inSeconds % 60} с',
            ),
            Text('GPS-точек: ${session.gpsPointCount}'),
            Text('IMU-чанков: ${session.imuChunkCount}'),
            Text('IMU-сэмплов: ${session.imuSampleCount}'),
            Text('Синхронизация: ${_syncStateLabel(session.syncState)}'),
            Text(
              'Средняя скорость: ${session.averageSpeedMetersPerSecond.toStringAsFixed(2)} м/с',
            ),
            Text('Потеряно сэмплов: ${session.droppedSampleCount}'),
            Text('Есть ошибки: ${session.hasErrors}'),
            if (session.derivedMetricSummary.isNotEmpty)
              Text(
                'Метрики: ${session.derivedMetricSummary.entries.map((entry) => '${entry.key}=${entry.value.toStringAsFixed(1)}').join(', ')}',
              ),
            if (session.failureReason != null)
              Text('Причина сбоя: ${session.failureReason}'),
            if (session.lastExportPath != null)
              Text('Последний экспорт: ${session.lastExportPath}'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ExportButton(
                  label: 'CSV',
                  loading: loading,
                  onPressed: () => onExport(ExportFormat.csv),
                ),
                _ExportButton(
                  label: 'GPX',
                  loading: loading,
                  onPressed: () => onExport(ExportFormat.gpx),
                ),
                _ExportButton(
                  label: 'GeoJSON',
                  loading: loading,
                  onPressed: () => onExport(ExportFormat.geoJson),
                ),
                _ExportButton(
                  label: 'ZIP',
                  loading: loading,
                  onPressed: () => onExport(ExportFormat.zipBundle),
                ),
                _ExportButton(
                  label: 'Диагностика',
                  loading: loading,
                  onPressed: () => onExport(ExportFormat.diagnosticsJson),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      size: AppButtonSize.sm,
      loading: loading,
      variant: AppButtonVariant.outline,
      onPressed: onPressed,
    );
  }
}

String _roleLabel(String value) {
  return switch (value) {
    'participant' => 'участник',
    'judge' => 'судья',
    _ => value,
  };
}

String _sessionStateLabel(String value) {
  return switch (value) {
    'idle' => 'не запущена',
    'preparing' => 'подготовка',
    'tracking' => 'идет запись',
    'paused' => 'пауза',
    'syncing' => 'синхронизация',
    'completed' => 'завершена',
    'failed' => 'ошибка',
    _ => value,
  };
}

String _syncStateLabel(String value) {
  return switch (value) {
    'pending' => 'ожидает отправки',
    'in_progress' => 'отправляется',
    'synced' => 'отправлено',
    'failed_retryable' => 'будет повторено',
    'failed_terminal' => 'ошибка отправки',
    _ => value,
  };
}
