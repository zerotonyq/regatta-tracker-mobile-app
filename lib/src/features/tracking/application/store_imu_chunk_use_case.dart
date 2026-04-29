import '../domain/imu_chunk_entity.dart';
import '../domain/tracking_repository.dart';

class StoreImuChunkUseCase {
  const StoreImuChunkUseCase(this._trackingRepository);

  final TrackingRepository _trackingRepository;

  Future<void> execute({required ImuChunkEntity chunk}) {
    return _trackingRepository.saveImuChunk(chunk: chunk);
  }
}
