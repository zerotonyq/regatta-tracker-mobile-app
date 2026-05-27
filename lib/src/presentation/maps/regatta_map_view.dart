import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../features/race_computer/domain/course_entity.dart';
import '../../features/race_computer/domain/geo_point_entity.dart';
import '../../features/tracking/domain/tracking_point_entity.dart';

class RegattaMapView extends StatefulWidget {
  const RegattaMapView({
    required this.trackPoints,
    this.course,
    this.currentPoint,
    this.fallbackCenter,
    this.onTap,
    this.enableTiles = true,
    this.emptyMessage = 'Нет GPS-данных для карты',
    super.key,
  });

  final List<TrackingPointEntity> trackPoints;
  final CourseEntity? course;
  final TrackingPointEntity? currentPoint;
  final GeoPointEntity? fallbackCenter;
  final void Function(GeoPointEntity point)? onTap;
  final bool enableTiles;
  final String emptyMessage;

  @override
  State<RegattaMapView> createState() => _RegattaMapViewState();
}

class _RegattaMapViewState extends State<RegattaMapView> {
  final MapController _mapController = MapController();

  double _currentZoom = 15;

  @override
  void didUpdateWidget(covariant RegattaMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousPoint =
        oldWidget.currentPoint ??
        (oldWidget.trackPoints.isEmpty ? null : oldWidget.trackPoints.last);
    final nextPoint =
        widget.currentPoint ??
        (widget.trackPoints.isEmpty ? null : widget.trackPoints.last);
    if (previousPoint == null && nextPoint != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _mapController.move(
          LatLng(nextPoint.latitude, nextPoint.longitude),
          _currentZoom,
        );
      });
    }
  }

  void _zoomIn() {
    _changeZoom(1);
  }

  void _zoomOut() {
    _changeZoom(-1);
  }

  void _changeZoom(double delta) {
    final camera = _mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(3.0, 19.0);

    _mapController.move(camera.center, newZoom);
  }

  void _centerOnCurrentLocation() {
    final position =
        widget.currentPoint ??
        (widget.trackPoints.isEmpty ? null : widget.trackPoints.last)!;

    final point = LatLng(position.latitude, position.longitude);

    _mapController.move(point, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final center = _resolveCenter();
    if (center == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.emptyMessage,
            key: const ValueKey('regatta-map-empty'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: _currentZoom,
              onTap: widget.onTap == null
                  ? null
                  : (_, point) => widget.onTap!(
                      GeoPointEntity(
                        latitude: point.latitude,
                        longitude: point.longitude,
                      ),
                    ),
              onPositionChanged: (position, hasGesture) {
                _currentZoom = position.zoom ?? _currentZoom;
              },
            ),
            children: [
              if (widget.enableTiles)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'vkr_regatta',
                )
              else
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: [
                        LatLng(center.latitude - 0.02, center.longitude - 0.02),
                        LatLng(center.latitude + 0.02, center.longitude - 0.02),
                        LatLng(center.latitude + 0.02, center.longitude + 0.02),
                        LatLng(center.latitude - 0.02, center.longitude + 0.02),
                      ],
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                  ],
                ),
              if (widget.trackPoints.length > 1)
                PolylineLayer(
                  key: const ValueKey('regatta-map-track-layer'),
                  polylines: [
                    Polyline(
                      points: widget.trackPoints
                          .map(
                            (point) => LatLng(point.latitude, point.longitude),
                          )
                          .toList(growable: false),
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              if (widget.course != null)
                PolylineLayer(
                  key: const ValueKey('regatta-map-course-layer'),
                  polylines: [
                    Polyline(
                      points: [
                        _toLatLng(widget.course!.startLine.committeeBoat),
                        _toLatLng(widget.course!.startLine.pinEnd),
                      ],
                      color: Theme.of(context).colorScheme.error,
                      strokeWidth: 4,
                    ),
                    Polyline(
                      points: [
                        _toLatLng(widget.course!.finishLine.committeeBoat),
                        _toLatLng(widget.course!.finishLine.pinEnd),
                      ],
                      color: Theme.of(context).colorScheme.error,
                      strokeWidth: 4,
                    ),
                    if (widget.course!.marks.isNotEmpty)
                      Polyline(
                        points: [
                          _toLatLng(widget.course!.startLine.committeeBoat),
                          ...widget.course!.marks
                              .map((mark) => _toLatLng(mark.position)),
                          _toLatLng(widget.course!.finishLine.committeeBoat),
                        ],
                        color: Theme.of(context).colorScheme.tertiary,
                        strokeWidth: 2,
                      ),
                  ],
                ),
              MarkerLayer(markers: _buildMarkers(context)),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _LocationCenterButton(onPressed: _centerOnCurrentLocation),
                const SizedBox(height: 8),
                _ZoomButtons(onZoomIn: _zoomIn, onZoomOut: _zoomOut),
                const SizedBox(height: 8),
                _MapLegend(
                  hasTrack: widget.trackPoints.isNotEmpty,
                  hasCourse: widget.course != null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LatLng? _resolveCenter() {
    final point =
        widget.currentPoint ??
        (widget.trackPoints.isEmpty ? null : widget.trackPoints.last);
    if (point != null) {
      return LatLng(point.latitude, point.longitude);
    }
    final startLine = widget.course?.startLine;
    if (startLine != null) {
      return _toLatLng(startLine.committeeBoat);
    }
    final mark = widget.course?.marks.isEmpty == true
        ? null
        : widget.course?.marks.first;
    if (mark != null) {
      return _toLatLng(mark.position);
    }
    final fallback = widget.fallbackCenter;
    return fallback == null ? null : _toLatLng(fallback);
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final markers = <Marker>[];
    final point =
        widget.currentPoint ??
        (widget.trackPoints.isEmpty ? null : widget.trackPoints.last);
    if (point != null) {
      markers.add(
        Marker(
          key: const ValueKey('regatta-map-current-marker'),
          point: LatLng(point.latitude, point.longitude),
          width: 38,
          height: 38,
          child: _RoundMarker(
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.navigation,
            tooltip: 'Текущая позиция',
          ),
        ),
      );
    }
    final course = widget.course;
    if (course != null) {
      markers
        ..add(
          Marker(
            key: const ValueKey('regatta-map-committee-marker'),
            point: _toLatLng(course.startLine.committeeBoat),
            width: 38,
            height: 38,
            child: _RoundMarker(
              color: Theme.of(context).colorScheme.error,
              icon: Icons.flag,
              tooltip: 'Судейское судно',
            ),
          ),
        )
        ..add(
          Marker(
            key: const ValueKey('regatta-map-pin-marker'),
            point: _toLatLng(course.startLine.pinEnd),
            width: 38,
            height: 38,
            child: _RoundMarker(
              color: Theme.of(context).colorScheme.error,
              icon: Icons.outlined_flag,
              tooltip: 'Пин',
            ),
          ),
        )
        ..add(
          Marker(
            key: const ValueKey('regatta-map-finish-committee-marker'),
            point: _toLatLng(course.finishLine.committeeBoat),
            width: 38,
            height: 38,
            child: _RoundMarker(
              color: Theme.of(context).colorScheme.error,
              icon: Icons.sports_score,
              tooltip: 'Финиш P1',
            ),
          ),
        )
        ..add(
          Marker(
            key: const ValueKey('regatta-map-finish-pin-marker'),
            point: _toLatLng(course.finishLine.pinEnd),
            width: 38,
            height: 38,
            child: _RoundMarker(
              color: Theme.of(context).colorScheme.error,
              icon: Icons.sports_score_outlined,
              tooltip: 'Финиш P2',
            ),
          ),
        );
      for (final mark in course.marks) {
        markers.add(
          Marker(
            key: ValueKey('regatta-map-mark-${mark.id}'),
            point: _toLatLng(mark.position),
            width: 42,
            height: 42,
            child: Tooltip(
              message: mark.name,
              child: Badge(
                label: Text(mark.order.toString()),
                child: _RoundMarker(
                  color: Theme.of(context).colorScheme.tertiary,
                  icon: Icons.place,
                  tooltip: mark.name,
                ),
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  LatLng _toLatLng(GeoPointEntity point) {
    return LatLng(point.latitude, point.longitude);
  }
}

class _LocationCenterButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LocationCenterButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'location_center_button',
      onPressed: onPressed,
      child: const Icon(Icons.my_location),
    );
  }
}

class _ZoomButtons extends StatelessWidget {
  const _ZoomButtons({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onZoomIn,
            icon: const Icon(Icons.add),
            tooltip: 'Приблизить',
          ),
          const SizedBox(width: 36, child: Divider(height: 1)),
          IconButton(
            onPressed: onZoomOut,
            icon: const Icon(Icons.remove),
            tooltip: 'Отдалить',
          ),
        ],
      ),
    );
  }
}

class _RoundMarker extends StatelessWidget {
  const _RoundMarker({
    required this.color,
    required this.icon,
    required this.tooltip,
  });

  final Color color;
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.hasTrack, required this.hasCourse});

  final bool hasTrack;
  final bool hasCourse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _LegendItem(
              color: colorScheme.primary,
              label: hasTrack ? 'GPS-трек' : 'GPS-трек ожидается',
            ),
            _LegendItem(
              color: colorScheme.error,
              label: hasCourse ? 'Стартовая линия' : 'Курс не настроен',
            ),
            _LegendItem(color: colorScheme.tertiary, label: 'Знаки'),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
