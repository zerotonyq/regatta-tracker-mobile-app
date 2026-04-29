import '../database/app_database.dart';
import '../../tracking/domain/tracking_point_entity.dart';
import 'tracking_cache_repository.dart';

class TrackingCacheRepositoryImpl implements TrackingCacheRepository {
  const TrackingCacheRepositoryImpl(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<List<TrackingPointEntity>> loadBufferedPoints() async {
    final session = await _appDatabase.trackingSessionDao
        .loadLatestUnfinishedSession();
    if (session == null) {
      return const <TrackingPointEntity>[];
    }
    return _appDatabase.trackingPointDao.loadPointsForSession(session.id);
  }

  @override
  Future<void> savePoint(TrackingPointEntity point) async {
    await _appDatabase.trackingPointDao.insertPoint(point);
  }
}
