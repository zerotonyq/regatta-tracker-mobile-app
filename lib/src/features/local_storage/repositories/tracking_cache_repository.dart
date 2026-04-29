import '../../tracking/domain/tracking_point_entity.dart';

abstract class TrackingCacheRepository {
  Future<void> savePoint(TrackingPointEntity point);
  Future<List<TrackingPointEntity>> loadBufferedPoints();
}
