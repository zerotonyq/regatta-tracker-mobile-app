import 'sync_job_entity.dart';
import 'sync_task_result.dart';

abstract class SyncBatchTaskExecutor {
  Future<Map<String, SyncTaskResult>> executeBatch(List<SyncJobEntity> jobs);
}
