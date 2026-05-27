import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../features/race_computer/domain/course_entity.dart';
import '../../features/race_computer/domain/geo_point_entity.dart';
import '../../features/race_computer/domain/mark_entity.dart';
import '../../features/race_computer/domain/start_line_entity.dart';
import '../../features/race_computer/presentation/race_computer_controller.dart';
import '../../features/sensor_bridge/application/read_current_tracking_point_use_case.dart';
import '../../features/tracking/domain/tracking_point_entity.dart';
import '../maps/regatta_map_view.dart';

enum _CourseEditMode { startP1, startP2, mark, finishP1, finishP2 }

class CourseEditorPage extends StatefulWidget {
  const CourseEditorPage({
    required this.raceId,
    required this.controller,
    required this.onBack,
    this.onSaved,
    this.enableMapTiles = true,
    this.readCurrentTrackingPointUseCase,
    super.key,
  });

  final int? raceId;
  final RaceComputerController controller;
  final VoidCallback onBack;
  final VoidCallback? onSaved;
  final bool enableMapTiles;
  final ReadCurrentTrackingPointUseCase? readCurrentTrackingPointUseCase;

  @override
  State<CourseEditorPage> createState() => _CourseEditorPageState();
}

class _CourseEditorPageState extends State<CourseEditorPage> {
  static const _logoAsset = 'assets/images/regatracker_logo.svg';

  final _nameController = TextEditingController(text: 'Regatta course');

  _CourseEditMode _mode = _CourseEditMode.startP1;
  GeoPointEntity? _startP1;
  GeoPointEntity? _startP2;
  GeoPointEntity? _finishP1;
  GeoPointEntity? _finishP2;
  List<MarkEntity> _marks = const <MarkEntity>[];
  TrackingPointEntity? _currentLocation;
  String? _localError;
  bool _loaded = false;
  Timer? _locationRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadExistingCourse();
    _refreshCurrentLocation();
    _locationRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_refreshCurrentLocation());
    });
  }

  @override
  void didUpdateWidget(covariant CourseEditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readCurrentTrackingPointUseCase !=
        widget.readCurrentTrackingPointUseCase) {
      unawaited(_refreshCurrentLocation());
    }
  }

  @override
  void dispose() {
    _locationRefreshTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _refreshCurrentLocation() async {
    final reader = widget.readCurrentTrackingPointUseCase;
    if (reader == null) {
      return;
    }

    try {
      final point = await reader.execute();
      if (!mounted) {
        return;
      }
      setState(() => _currentLocation = point);
    } catch (_) {}
  }

  Future<void> _loadExistingCourse() async {
    final raceId = widget.raceId;
    if (raceId == null || _loaded) {
      return;
    }

    _loaded = true;

    await widget.controller.loadCourse(raceId: raceId);

    final course = widget.controller.course;
    if (course == null || !mounted) {
      return;
    }

    setState(() {
      _nameController.text = course.name;
      _startP1 = course.startLine.committeeBoat;
      _startP2 = course.startLine.pinEnd;
      _finishP1 = course.finishLine.committeeBoat;
      _finishP2 = course.finishLine.pinEnd;
      _marks = course.marks;
    });
  }

  CourseEntity? get _draftCourse {
    final raceId = widget.raceId;

    if (raceId == null ||
        _startP1 == null ||
        _startP2 == null ||
        _finishP1 == null ||
        _finishP2 == null) {
      return null;
    }

    return CourseEntity(
      raceId: raceId,
      name: _nameController.text.trim().isEmpty
          ? 'Regatta course'
          : _nameController.text.trim(),
      startLine: StartLineEntity(
        committeeBoat: _startP1!,
        pinEnd: _startP2!,
        name: 'Start line',
      ),
      marks: _marks,
      finishLine: StartLineEntity(
        committeeBoat: _finishP1!,
        pinEnd: _finishP2!,
        name: 'Finish line',
      ),
      updatedAtUtc: DateTime.now().toUtc(),
      source: 'judge_editor',
    );
  }

  void _handleMapTap(GeoPointEntity point) {
    if (widget.raceId == null) {
      setState(() {
        _localError = 'Выберите гонку перед настройкой курса.';
      });
      return;
    }

    setState(() {
      _localError = null;

      switch (_mode) {
        case _CourseEditMode.startP1:
          _startP1 = point;
        case _CourseEditMode.startP2:
          _startP2 = point;
        case _CourseEditMode.mark:
          final nextOrder = _marks.length + 1;
          _marks = <MarkEntity>[
            ..._marks,
            MarkEntity(
              id: 'M$nextOrder',
              name: 'Знак $nextOrder',
              position: point,
              order: nextOrder,
              roundingSide: MarkRoundingSide.port,
            ),
          ];
        case _CourseEditMode.finishP1:
          _finishP1 = point;
        case _CourseEditMode.finishP2:
          _finishP2 = point;
      }
    });
  }

  void _removeMark(MarkEntity mark) {
    setState(() {
      _marks = _marks
          .where((item) => item.id != mark.id)
          .toList(growable: false)
          .asMap()
          .entries
          .map(
            (entry) => MarkEntity(
          id: 'M${entry.key + 1}',
          name: entry.value.name,
          position: entry.value.position,
          order: entry.key + 1,
          roundingSide: entry.value.roundingSide,
        ),
      )
          .toList(growable: false);
    });
  }

  void _updateMark(MarkEntity value) {
    setState(() {
      _marks = _marks
          .map((mark) => mark.id == value.id ? value : mark)
          .toList(growable: false);
    });
  }

  bool _isValidPoint(GeoPointEntity point) {
    return point.longitude >= -180 &&
        point.longitude <= 180 &&
        point.latitude >= -90 &&
        point.latitude <= 90;
  }

  bool _allCoordinatesValid() {
    final points = <GeoPointEntity>[
      if (_startP1 != null) _startP1!,
      if (_startP2 != null) _startP2!,
      if (_finishP1 != null) _finishP1!,
      if (_finishP2 != null) _finishP2!,
      ..._marks.map((mark) => mark.position),
    ];

    return points.every(_isValidPoint);
  }

  Future<void> _save() async {
    if (_startP1 == null || _startP2 == null) {
      setState(() => _localError = 'Укажите обе точки стартовой линии.');
      return;
    }

    if (_finishP1 == null || _finishP2 == null) {
      setState(() => _localError = 'Укажите обе точки финишной линии.');
      return;
    }

    if (_marks.isEmpty) {
      setState(() => _localError = 'Добавьте хотя бы один флаг.');
      return;
    }

    if (_marks.map((mark) => mark.id.trim()).toSet().length != _marks.length) {
      setState(() => _localError = 'ID флагов должны быть уникальными.');
      return;
    }

    if (!_allCoordinatesValid()) {
      setState(() => _localError = 'Координаты вне допустимого диапазона.');
      return;
    }

    final course = _draftCourse;
    if (course == null) {
      setState(() => _localError = 'Курс заполнен не полностью.');
      return;
    }

    await widget.controller.saveCourse(course, publishRemote: true);

    if (!mounted) {
      return;
    }

    if (widget.controller.error == null) {
      widget.onSaved?.call();
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draftCourse;

    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;

                final mapView = RegattaMapView(
                  key: const ValueKey('course-editor-map'),
                  trackPoints: const [],
                  currentPoint: _currentLocation,
                  course: draft,
                  fallbackCenter: const GeoPointEntity(
                    latitude: 60,
                    longitude: 30,
                  ),
                  enableTiles: widget.enableMapTiles,
                  onTap: widget.raceId == null ? null : _handleMapTap,
                );

                if (wide) {
                  final panel = _EditorPanel(
                    nameController: _nameController,
                    mode: _mode,
                    marks: _marks,
                    localError: _localError,
                    controllerError: widget.controller.error,
                    loading: widget.controller.loading,
                    startP1: _startP1,
                    startP2: _startP2,
                    finishP1: _finishP1,
                    finishP2: _finishP2,
                    canEdit: widget.raceId != null,
                    raceId: widget.raceId,
                    map: null,
                    onModeChanged: (mode) => setState(() => _mode = mode),
                    onRemoveMark: _removeMark,
                    onUpdateMark: _updateMark,
                    onSave: _save,
                  );

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                        child: Column(
                          children: [
                            _Header(
                              logoAsset: _logoAsset,
                              onBack: widget.onBack,
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _MapCard(
                                      expand: true,
                                      child: mapView,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 410,
                                    child: SingleChildScrollView(
                                      child: panel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final panel = _EditorPanel(
                  nameController: _nameController,
                  mode: _mode,
                  marks: _marks,
                  localError: _localError,
                  controllerError: widget.controller.error,
                  loading: widget.controller.loading,
                  startP1: _startP1,
                  startP2: _startP2,
                  finishP1: _finishP1,
                  finishP2: _finishP2,
                  canEdit: widget.raceId != null,
                  raceId: widget.raceId,
                  map: _MapCard(
                    expand: false,
                    child: mapView,
                  ),
                  onModeChanged: (mode) => setState(() => _mode = mode),
                  onRemoveMark: _removeMark,
                  onUpdateMark: _updateMark,
                  onSave: _save,
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      children: [
                        _Header(
                          logoAsset: _logoAsset,
                          onBack: widget.onBack,
                        ),
                        const SizedBox(height: 20),
                        panel,
                      ],
                    ),
                  ),
                );
              },
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
  });

  final String logoAsset;
  final VoidCallback onBack;

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
                'Редактор курса',
                style: TextStyle(
                  fontSize: 14,
                  color: _AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.child,
    required this.expand,
  });

  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final map = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: child,
    );

    return _AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 4, 6, 12),
            child: Row(
              children: [
                _CardIcon(
                  icon: Icons.map_outlined,
                  color: _AppColors.cyan,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Карта курса',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (expand)
            Expanded(child: map)
          else
            SizedBox(
              height: 420,
              child: map,
            ),
        ],
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.nameController,
    required this.mode,
    required this.marks,
    required this.loading,
    required this.canEdit,
    required this.raceId,
    required this.onModeChanged,
    required this.onRemoveMark,
    required this.onUpdateMark,
    required this.onSave,
    this.map,
    this.localError,
    this.controllerError,
    this.startP1,
    this.startP2,
    this.finishP1,
    this.finishP2,
  });

  final TextEditingController nameController;
  final _CourseEditMode mode;
  final List<MarkEntity> marks;
  final bool loading;
  final bool canEdit;
  final int? raceId;
  final Widget? map;
  final String? localError;
  final String? controllerError;
  final GeoPointEntity? startP1;
  final GeoPointEntity? startP2;
  final GeoPointEntity? finishP1;
  final GeoPointEntity? finishP2;
  final ValueChanged<_CourseEditMode> onModeChanged;
  final ValueChanged<MarkEntity> onRemoveMark;
  final ValueChanged<MarkEntity> onUpdateMark;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroCard(
          raceId: raceId,
          marksCount: marks.length,
        ),

        const SizedBox(height: 16),

        _AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Параметры курса',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _AppColors.navy,
                ),
              ),
              const SizedBox(height: 14),
              _CourseNameField(controller: nameController),
            ],
          ),
        ),

        if (map != null) ...[
          const SizedBox(height: 16),
          map!,
        ],

        const SizedBox(height: 16),

        _AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Что поставить на карте',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Выберите режим и нажмите на карту, чтобы поставить точку.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: _AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              _ModeSelector(
                mode: mode,
                enabled: canEdit,
                onChanged: onModeChanged,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _CourseReadinessCard(
          startP1: startP1,
          startP2: startP2,
          finishP1: finishP1,
          finishP2: finishP2,
          marksCount: marks.length,
        ),

        const SizedBox(height: 16),

        _MarksCard(
          marks: marks,
          onRemoveMark: onRemoveMark,
          onUpdateMark: onUpdateMark,
        ),

        if (localError != null || controllerError != null) ...[
          const SizedBox(height: 16),
          _InlineBanner(
            icon: Icons.error_outline_rounded,
            text: localError ?? controllerError!,
            danger: true,
          ),
        ],

        const SizedBox(height: 20),

        _PrimaryActionButton(
          label: 'Сохранить и опубликовать курс',
          icon: Icons.cloud_upload_rounded,
          loading: loading,
          onPressed: canEdit
              ? () {
            onSave();
          }
              : null,
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.raceId,
    required this.marksCount,
  });

  final int? raceId;
  final int marksCount;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _CardIcon(
                icon: Icons.route_rounded,
                color: _AppColors.cyan,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Настройка дистанции',
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
          const SizedBox(height: 16),
          const Text(
            'Поставьте стартовую линию, флаги дистанции и финишную линию. Курс будет опубликован для участников гонки.',
            style: TextStyle(
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
                icon: Icons.flag_rounded,
                text: 'Гонка: ${raceId?.toString() ?? 'не выбрана'}',
              ),
              _InfoChip(
                icon: Icons.place_rounded,
                text: 'Флагов: $marksCount',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseNameField extends StatelessWidget {
  const _CourseNameField({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        fontSize: 17,
        color: _AppColors.navy,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Название курса',
        prefixIcon: const Icon(
          Icons.edit_outlined,
          color: _AppColors.navy,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: _AppColors.cyan,
            width: 1.6,
          ),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.enabled,
    required this.onChanged,
  });

  final _CourseEditMode mode;
  final bool enabled;
  final ValueChanged<_CourseEditMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <_ModeOption>[
      const _ModeOption(
        mode: _CourseEditMode.startP1,
        icon: Icons.flag_rounded,
        title: 'Старт левый',
        subtitle: 'Судейское судно',
      ),
      const _ModeOption(
        mode: _CourseEditMode.startP2,
        icon: Icons.outlined_flag_rounded,
        title: 'Старт правый',
        subtitle: 'Флаг / буй старта',
      ),
      const _ModeOption(
        mode: _CourseEditMode.mark,
        icon: Icons.place_rounded,
        title: 'Флаг',
        subtitle: 'Добавить знак дистанции',
      ),
      const _ModeOption(
        mode: _CourseEditMode.finishP1,
        icon: Icons.sports_score_rounded,
        title: 'Финиш левый',
        subtitle: 'Первая точка финиша',
      ),
      const _ModeOption(
        mode: _CourseEditMode.finishP2,
        icon: Icons.sports_score_outlined,
        title: 'Финиш правый',
        subtitle: 'Вторая точка финиша',
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ModeTile(
            option: item,
            selected: mode == item.mode,
            enabled: enabled,
            onTap: () => onChanged(item.mode),
          ),
        ),
      )
          .toList(),
    );
  }
}

class _ModeOption {
  const _ModeOption({
    required this.mode,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final _CourseEditMode mode;
  final IconData icon;
  final String title;
  final String subtitle;
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final _ModeOption option;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? _AppColors.cyan : _AppColors.navy;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _AppColors.cyan.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _AppColors.cyan : _AppColors.border,
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                option.icon,
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _AppColors.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: _AppColors.cyan,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _CourseReadinessCard extends StatelessWidget {
  const _CourseReadinessCard({
    required this.startP1,
    required this.startP2,
    required this.finishP1,
    required this.finishP2,
    required this.marksCount,
  });

  final GeoPointEntity? startP1;
  final GeoPointEntity? startP2;
  final GeoPointEntity? finishP1;
  final GeoPointEntity? finishP2;
  final int marksCount;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Готовность курса',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          _PointStatus(
            label: 'Старт левый',
            point: startP1,
          ),
          const SizedBox(height: 10),
          _PointStatus(
            label: 'Старт правый',
            point: startP2,
          ),
          const SizedBox(height: 10),
          _PointStatus(
            label: 'Финиш левый',
            point: finishP1,
          ),
          const SizedBox(height: 10),
          _PointStatus(
            label: 'Финиш правый',
            point: finishP2,
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: 'Флаги',
            value: marksCount == 0 ? 'не добавлены' : '$marksCount шт.',
            done: marksCount > 0,
          ),
        ],
      ),
    );
  }
}

class _PointStatus extends StatelessWidget {
  const _PointStatus({
    required this.label,
    required this.point,
  });

  final String label;
  final GeoPointEntity? point;

  @override
  Widget build(BuildContext context) {
    return _StatusRow(
      label: label,
      value: point == null ? 'не задано' : _formatPoint(point!),
      done: point != null,
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.done,
  });

  final String label;
  final String value;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? _AppColors.cyan : Colors.orange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: color,
          size: 21,
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

class _MarksCard extends StatelessWidget {
  const _MarksCard({
    required this.marks,
    required this.onRemoveMark,
    required this.onUpdateMark,
  });

  final List<MarkEntity> marks;
  final ValueChanged<MarkEntity> onRemoveMark;
  final ValueChanged<MarkEntity> onUpdateMark;

  @override
  Widget build(BuildContext context) {
    return _AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Флаги дистанции',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          if (marks.isEmpty)
            const _EmptyBlock(
              icon: Icons.place_outlined,
              title: 'Флагов пока нет',
              text: 'Выберите режим «Флаг» и нажмите на карту.',
            )
          else
            ...marks.map(
                  (mark) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MarkTile(
                  mark: mark,
                  onRemove: () => onRemoveMark(mark),
                  onRoundingChanged: (value) {
                    onUpdateMark(
                      MarkEntity(
                        id: mark.id,
                        name: mark.name,
                        position: mark.position,
                        order: mark.order,
                        roundingSide: value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarkTile extends StatelessWidget {
  const _MarkTile({
    required this.mark,
    required this.onRemove,
    required this.onRoundingChanged,
  });

  final MarkEntity mark;
  final VoidCallback onRemove;
  final ValueChanged<MarkRoundingSide> onRoundingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: _AppColors.cyan,
                child: Text(
                  mark.order.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mark.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: _AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatPoint(mark.position),
                      style: const TextStyle(
                        fontSize: 13,
                        color: _AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Удалить флаг',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<MarkRoundingSide>(
                value: mark.roundingSide,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (value) {
                  if (value != null) {
                    onRoundingChanged(value);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: MarkRoundingSide.port,
                    child: Text('Левым бортом'),
                  ),
                  DropdownMenuItem(
                    value: MarkRoundingSide.starboard,
                    child: Text('Правым бортом'),
                  ),
                ],
              ),
            ),
          ),
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
            : Icon(icon, size: 23),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: _AppColors.cyan.withOpacity(0.28),
          backgroundColor: _AppColors.cyan,
          disabledBackgroundColor: _AppColors.cyan.withOpacity(0.45),
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
  static const background = Color(0xFFF8FBFD);
}

String _formatPoint(GeoPointEntity point) {
  return '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
}