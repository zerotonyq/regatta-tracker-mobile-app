import 'package:flutter/foundation.dart';

import '../domain/sync_job_entity.dart';
import '../domain/sync_repository.dart';

class SyncStatusController extends ChangeNotifier {
  SyncStatusController({required SyncRepository syncRepository})
    : _syncRepository = syncRepository;

  final SyncRepository _syncRepository;

  List<SyncJobEntity> _jobs = const <SyncJobEntity>[];

  List<SyncJobEntity> get jobs => _jobs;

  Future<void> refresh() async {
    _jobs = await _syncRepository.getAllJobs();
    notifyListeners();
  }
}
