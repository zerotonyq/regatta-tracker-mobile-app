import 'sync_job_entity.dart';
import 'sync_task_result.dart';

abstract class SyncTaskExecutor {
  Future<SyncTaskResult> execute(SyncJobEntity job);
}
