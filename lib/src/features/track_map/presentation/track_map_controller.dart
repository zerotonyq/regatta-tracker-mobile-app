import 'package:flutter/foundation.dart';

import '../../tracking/domain/tracking_point_entity.dart';
import '../../tracking/domain/tracking_repository.dart';

class TrackMapController extends ChangeNotifier {
  TrackMapController({
    required TrackingRepository trackingRepository,
    this.maxPoints = 1000,
  }) : _trackingRepository = trackingRepository;

  final TrackingRepository _trackingRepository;
  final int maxPoints;

  List<TrackingPointEntity> _points = const <TrackingPointEntity>[];
  bool _loading = false;
  String? _error;

  List<TrackingPointEntity> get points => _points;
  TrackingPointEntity? get currentPoint =>
      _points.isEmpty ? null : _points.last;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({required int sessionId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final points = await _trackingRepository.loadGpsPointsForSession(
        sessionId,
      );
      _points = points.length <= maxPoints
          ? points
          : points.sublist(points.length - maxPoints);
    } catch (error) {
      _error = error.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
