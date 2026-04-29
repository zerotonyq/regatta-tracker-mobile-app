import '../domain/sync_job_entity.dart';
import '../domain/sync_repository.dart';

class QueueSyncUploadUseCase {
  const QueueSyncUploadUseCase(this._syncRepository);

  final SyncRepository _syncRepository;

  Future<void> execute(SyncJobEntity job) => _syncRepository.enqueue(job);
}
