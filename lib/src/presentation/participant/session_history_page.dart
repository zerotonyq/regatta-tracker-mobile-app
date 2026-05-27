import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/export/domain/diagnostics_snapshot_entity.dart';
import '../../features/export/domain/export_format.dart';
import '../../features/export/domain/session_summary_entity.dart';
import '../../features/export/presentation/export_controller.dart';

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
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  @override
  void initState() {
    super.initState();
    widget.controller.load();
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
            final diagnostics = widget.controller.diagnostics;
            final sessions = widget.controller.sessions;
            final error = widget.controller.error;
            final lastExport = widget.controller.lastExport;
            final loading = widget.controller.loading;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: RefreshIndicator(
                  color: _AppColors.cyan,
                  onRefresh: widget.controller.load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                    children: [
                      _Header(
                        logoAsset: _logoAsset,
                        onBack: widget.onBack,
                        onRefresh: widget.controller.load,
                        loading: loading,
                      ),

                      const SizedBox(height: 24),

                      _HeroCard(
                        sessionsCount: sessions.length,
                        loading: loading,
                      ),

                      if (error != null) ...[
                        const SizedBox(height: 16),
                        _InlineBanner(
                          icon: Icons.error_outline_rounded,
                          text: error,
                          danger: true,
                        ),
                      ],

                      if (lastExport != null) ...[
                        const SizedBox(height: 16),
                        _LastExportCard(
                          fileName: lastExport.fileName,
                          filePath: lastExport.filePath,
                        ),
                      ],

                      if (diagnostics != null) ...[
                        const SizedBox(height: 16),
                        _DiagnosticsCard(diagnostics: diagnostics),
                      ],

                      const SizedBox(height: 22),

                      const Text(
                        'Завершенные сессии',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _AppColors.navy,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (sessions.isEmpty && loading)
                        const _LoadingCard()
                      else if (sessions.isEmpty)
                        const _EmptyHistoryCard()
                      else
                        ...sessions.map(
                              (session) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _SessionSummaryCard(
                              session: session,
                              loading: loading,
                              onExport: (format) => widget.controller.export(
                                sessionId: session.sessionId,
                                format: format,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
    required this.onBack,
    required this.onRefresh,
    required this.loading,
  });

  final String logoAsset;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Назад',
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        SvgPicture.asset(
          logoAsset,
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
                'История и экспорт',
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
          loading: loading,
          onTap: () {
            onRefresh();
          },
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.sessionsCount,
    required this.loading,
  });

  final int sessionsCount;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _CardIcon(
                icon: Icons.history_rounded,
                color: _AppColors.cyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loading ? 'Обновляем данные' : 'Архив треков',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.navy,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            loading
                ? 'Загружаем завершенные сессии и данные для экспорта.'
                : 'Здесь можно выгрузить треки, диагностику и данные завершенных гонок.',
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.check_circle_outline_rounded,
                text: 'Сессий: $sessionsCount',
              ),
              const _InfoChip(
                icon: Icons.file_download_outlined,
                text: 'CSV · GPX · GeoJSON · ZIP',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsCard extends StatelessWidget {
  const _DiagnosticsCard({
    required this.diagnostics,
  });

  final DiagnosticsSnapshotEntity diagnostics;

  @override
  Widget build(BuildContext context) {
    final markers = diagnostics.batteryImpactMarkers;

    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.monitor_heart_outlined,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Диагностика',
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
          _KeyValueRow(
            label: 'Маркеры нагрузки батареи',
            value: markers.isEmpty ? 'нет' : markers.join(', '),
            icon: Icons.battery_charging_full_rounded,
          ),
        ],
      ),
    );
  }
}

class _LastExportCard extends StatelessWidget {
  const _LastExportCard({
    required this.fileName,
    required this.filePath,
  });

  final String fileName;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.file_present_rounded,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Последний экспорт',
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
          _KeyValueRow(
            label: 'Файл',
            value: fileName,
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 10),
          _KeyValueRow(
            label: 'Путь',
            value: filePath,
            icon: Icons.folder_outlined,
          ),
        ],
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
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _CardIcon(
                icon: Icons.route_rounded,
                color: _AppColors.cyan,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Сессия #${session.sessionId}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.navy,
                  ),
                ),
              ),
              _StatusBadge(
                text: _sessionStateLabel(session.state),
                danger: session.state == 'failed',
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.flag_rounded,
                text: 'Гонка #${session.raceId}',
              ),
              _InfoChip(
                icon: Icons.timer_outlined,
                text: _formatDuration(session.duration),
              ),
              _InfoChip(
                icon: Icons.gps_fixed_rounded,
                text: 'GPS: ${session.gpsPointCount}',
              ),
            ],
          ),

          if (session.failureReason != null) ...[
            const SizedBox(height: 14),
            _InlineBanner(
              icon: Icons.warning_amber_rounded,
              text: 'Причина сбоя: ${session.failureReason}',
              danger: true,
            ),
          ],

          if (session.lastExportPath != null) ...[
            const SizedBox(height: 14),
            _KeyValueRow(
              label: 'Последний экспорт',
              value: session.lastExportPath!,
              icon: Icons.file_download_done_rounded,
            ),
          ],

          const SizedBox(height: 18),

          const Text(
            'Экспорт',
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
              _ExportButton(
                label: 'CSV',
                icon: Icons.table_chart_outlined,
                loading: loading,
                onPressed: () => onExport(ExportFormat.csv),
              ),
              _ExportButton(
                label: 'GPX',
                icon: Icons.map_outlined,
                loading: loading,
                onPressed: () => onExport(ExportFormat.gpx),
              ),
              _ExportButton(
                label: 'GeoJSON',
                icon: Icons.data_object_rounded,
                loading: loading,
                onPressed: () => onExport(ExportFormat.geoJson),
              ),
              _ExportButton(
                label: 'ZIP',
                icon: Icons.folder_zip_outlined,
                loading: loading,
                onPressed: () => onExport(ExportFormat.zipBundle),
              ),
              _ExportButton(
                label: 'Диагностика',
                icon: Icons.monitor_heart_outlined,
                loading: loading,
                onPressed: () => onExport(ExportFormat.diagnosticsJson),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes == 0) {
      return '$seconds с';
    }

    return '$minutes мин $seconds с';
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_AppColors.cyan),
        ),
      )
          : Icon(icon, size: 18),
      label: Text(label),
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
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _AppCard(
      child: Column(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(_AppColors.cyan),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Загружаем историю сессий...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _AppColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return const _AppCard(
      child: Column(
        children: [
          _CardIcon(
            icon: Icons.inbox_outlined,
            color: _AppColors.cyan,
          ),
          SizedBox(height: 16),
          Text(
            'Завершенных сессий пока нет',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: _AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'После завершения трекинга гонки она появится здесь для экспорта.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              color: _AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
    this.danger = false,
  });

  final String text;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.redAccent : _AppColors.cyan;

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

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: loading ? null : onTap,
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
          child: loading
              ? const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _AppColors.cyan,
              ),
            ),
          )
              : Icon(
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