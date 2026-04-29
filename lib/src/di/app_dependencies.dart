import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:regatta_sensor_bridge/regatta_sensor_bridge.dart';

import '../core/config/app_config.dart';
import '../core/network/app_dio.dart';
import '../core/network/auth_token_store.dart';
import '../core/network/request_metadata_provider.dart';
import '../features/api/auth_api.dart';
import '../features/api/management_api.dart';
import '../features/api/receiver_api.dart';
import '../features/auth/data/auth_remote_data_source.dart';
import '../features/auth/presentation/auth_bootstrap_controller.dart';
import '../features/auth/presentation/auth_session_controller.dart';
import '../features/export/application/export_session_data_use_case.dart';
import '../features/export/data/export_repository_impl.dart';
import '../features/export/domain/export_repository.dart';
import '../features/export/presentation/export_controller.dart';
import '../features/judge/application/judge_race_flow_service.dart';
import '../features/judge/data/judge_local_repository_impl.dart';
import '../features/judge/data/judge_race_repository_impl.dart';
import '../features/judge/domain/judge_local_repository.dart';
import '../features/judge/domain/judge_race_repository.dart';
import '../features/judge/presentation/judge_race_controller.dart';
import '../features/local_storage/database/app_database.dart';
import '../features/local_storage/migrations/migration_registry.dart';
import '../features/local_storage/repositories/tracking_cache_repository.dart';
import '../features/local_storage/repositories/tracking_cache_repository_impl.dart';
import '../features/management/data/management_remote_data_source.dart';
import '../features/receiver/data/receiver_remote_data_source.dart';
import '../features/race_computer/application/create_reference_course_use_case.dart';
import '../features/race_computer/application/evaluate_race_state_use_case.dart';
import '../features/race_computer/data/race_computer_repository_impl.dart';
import '../features/race_computer/domain/race_computer_repository.dart';
import '../features/race_computer/presentation/race_computer_controller.dart';
import '../features/sensor_bridge/application/read_tracking_health_use_case.dart';
import '../features/sensor_bridge/data/sensor_bridge_repository_impl.dart';
import '../features/sensor_bridge/domain/sensor_bridge_repository.dart';
import '../features/sync/application/queue_sync_upload_use_case.dart';
import '../features/sync/application/sync_upload_worker.dart';
import '../features/sync/data/polling_connectivity_monitor.dart';
import '../features/sync/data/receiver_sync_task_executor.dart';
import '../features/sync/data/sync_repository_impl.dart';
import '../features/sync/domain/connectivity_monitor.dart';
import '../features/sync/domain/sync_repository.dart';
import '../features/tracking/application/tracking_sample_ingestion_service.dart';
import '../features/tracking/application/live_tracking_delivery_service.dart';
import '../features/tracking/data/tracking_repository_impl.dart';
import '../features/tracking/data/tracking_session_repository_impl.dart';
import '../features/tracking/application/tracking_session_service.dart';
import '../features/tracking/domain/tracking_repository.dart';
import '../features/tracking/domain/tracking_session_repository.dart';
import '../features/tracking/presentation/tracking_session_controller.dart';

class AppDependencies {
  AppDependencies({
    required this.config,
    required this.tokenStore,
    required this.dio,
    required this.authDio,
    required this.appDatabase,
    required this.requestMetadataProvider,
    required this.authRemoteDataSource,
    required this.authSessionController,
    required this.authBootstrapController,
    required this.receiverRemoteDataSource,
    required this.managementRemoteDataSource,
    bool? enableBackgroundSyncWorker,
  }) : enableBackgroundSyncWorker = enableBackgroundSyncWorker ?? true;

  final AppConfig config;
  final AuthTokenStore tokenStore;
  final Dio dio;
  final Dio authDio;
  final AppDatabase appDatabase;
  final RequestMetadataProvider requestMetadataProvider;
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthSessionController authSessionController;
  final AuthBootstrapController authBootstrapController;
  final ReceiverRemoteDataSource receiverRemoteDataSource;
  final ManagementRemoteDataSource managementRemoteDataSource;
  final bool enableBackgroundSyncWorker;
  late final MigrationRegistry migrationRegistry = const MigrationRegistry();
  late final TrackingCacheRepository trackingCacheRepository =
      TrackingCacheRepositoryImpl(appDatabase);
  late final SyncRepository syncRepository = SyncRepositoryImpl(appDatabase);
  late final QueueSyncUploadUseCase queueSyncUploadUseCase =
      QueueSyncUploadUseCase(syncRepository);
  late final ConnectivityMonitor connectivityMonitor =
      PollingConnectivityMonitor();
  late final ReceiverSyncTaskExecutor receiverSyncTaskExecutor =
      ReceiverSyncTaskExecutor(receiverRemoteDataSource);
  late final SyncUploadWorker syncUploadWorker = SyncUploadWorker(
    syncRepository: syncRepository,
    taskExecutor: receiverSyncTaskExecutor,
    connectivityMonitor: connectivityMonitor,
  );
  bool _syncWorkerStarted = false;
  late final SensorBridgeRepository sensorBridgeRepository =
      SensorBridgeRepositoryImpl(bridge: _buildSensorBridge());
  late final ReadTrackingHealthUseCase readTrackingHealthUseCase =
      ReadTrackingHealthUseCase(sensorBridgeRepository);
  late final TrackingRepository trackingRepository = TrackingRepositoryImpl(
    appDatabase,
  );
  late final TrackingSessionRepository trackingSessionRepository =
      TrackingSessionRepositoryImpl(
        trackingRepository: trackingRepository,
        syncRepository: syncRepository,
      );
  late final LiveTrackingDeliveryService liveTrackingDeliveryService =
      LiveTrackingDeliveryService(
        receiverRemoteDataSource: receiverRemoteDataSource,
        trackingRepository: trackingRepository,
        trackingSessionRepository: trackingSessionRepository,
      );
  late final TrackingSampleIngestionService trackingSampleIngestionService =
      TrackingSampleIngestionService(
        sensorBridgeRepository: sensorBridgeRepository,
        trackingSessionRepository: trackingSessionRepository,
        trackingRepository: trackingRepository,
        liveTrackingDeliveryService: liveTrackingDeliveryService,
      );
  late final TrackingSessionService trackingSessionService =
      TrackingSessionService(
        trackingSessionRepository: trackingSessionRepository,
        sensorBridgeRepository: sensorBridgeRepository,
        trackingSampleIngestionService: trackingSampleIngestionService,
      );
  late final JudgeRaceRepository judgeRaceRepository = JudgeRaceRepositoryImpl(
    managementRemoteDataSource,
  );
  late final JudgeLocalRepository judgeLocalRepository =
      JudgeLocalRepositoryImpl(appDatabase);
  late final JudgeRaceFlowService judgeRaceFlowService = JudgeRaceFlowService(
    judgeRaceRepository: judgeRaceRepository,
    judgeLocalRepository: judgeLocalRepository,
  );
  late final RaceComputerRepository raceComputerRepository =
      RaceComputerRepositoryImpl(
        appDatabase: appDatabase,
        trackingRepository: trackingRepository,
      );
  late final EvaluateRaceStateUseCase evaluateRaceStateUseCase =
      EvaluateRaceStateUseCase(raceComputerRepository);
  late final CreateReferenceCourseUseCase createReferenceCourseUseCase =
      CreateReferenceCourseUseCase(raceComputerRepository);
  late final ExportRepository exportRepository = ExportRepositoryImpl(
    appDatabase: appDatabase,
    sensorBridgeRepository: sensorBridgeRepository,
    config: config,
  );
  late final ExportSessionDataUseCase exportSessionDataUseCase =
      ExportSessionDataUseCase(exportRepository);

  JudgeRaceController createJudgeRaceController() {
    return JudgeRaceController(judgeRaceFlowService: judgeRaceFlowService);
  }

  TrackingSessionController createTrackingSessionController() {
    return TrackingSessionController(
      trackingSessionService: trackingSessionService,
    );
  }

  RaceComputerController createRaceComputerController() {
    return RaceComputerController(
      evaluateRaceStateUseCase: evaluateRaceStateUseCase,
      createReferenceCourseUseCase: createReferenceCourseUseCase,
    );
  }

  ExportController createExportController() {
    return ExportController(
      exportSessionDataUseCase: exportSessionDataUseCase,
    );
  }

  factory AppDependencies.bootstrap() {
    final config = AppConfig.fromEnvironment();
    const secureStorage = FlutterSecureStorage();
    final tokenStore = SecureAuthTokenStore(secureStorage);
    final appDatabase = AppDatabase();
    final requestMetadataProvider = RequestMetadataProvider(
      userAgent: config.userAgent,
      fingerprint: config.fingerprint,
    );
    final authDio = AppDio.createAuthClient(
      config: config,
      metadataProvider: requestMetadataProvider,
    );
    final authApi = AuthApi(authDio);
    final authRemoteDataSource = AuthRemoteDataSource(
      authApi: authApi,
      tokenStore: tokenStore,
    );
    final authSessionController = AuthSessionController(
      authRemoteDataSource: authRemoteDataSource,
      tokenStore: tokenStore,
    );
    final authBootstrapController = AuthBootstrapController(
      sessionController: authSessionController,
    );
    final dio = AppDio.createProtectedClient(
      config: config,
      tokenStore: tokenStore,
      metadataProvider: requestMetadataProvider,
      refreshSession: ({String? correlationId}) =>
          authSessionController.refreshSession(
            correlationId: correlationId,
            showRefreshingState: false,
          ),
      onSessionExpired: authSessionController.handleTerminalAuthFailure,
    );

    final receiverApi = ReceiverApi(dio);
    final managementApi = ManagementApi(dio);

    return AppDependencies(
      config: config,
      tokenStore: tokenStore,
      dio: dio,
      authDio: authDio,
      appDatabase: appDatabase,
      requestMetadataProvider: requestMetadataProvider,
      authRemoteDataSource: authRemoteDataSource,
      authSessionController: authSessionController,
      authBootstrapController: authBootstrapController,
      receiverRemoteDataSource: ReceiverRemoteDataSource(
        receiverApi: receiverApi,
      ),
      managementRemoteDataSource: ManagementRemoteDataSource(
        managementApi: managementApi,
      ),
    );
  }

  Future<void> ensureSyncWorkerStarted() async {
    if (!enableBackgroundSyncWorker) {
      return;
    }
    if (_syncWorkerStarted) {
      return;
    }
    _syncWorkerStarted = true;
    await syncUploadWorker.start();
  }

  Future<void> disposeBackgroundTasks() async {
    await trackingSessionService.dispose();
    if (_syncWorkerStarted) {
      await syncUploadWorker.dispose();
      _syncWorkerStarted = false;
    }
    final monitor = connectivityMonitor;
    if (monitor is PollingConnectivityMonitor) {
      monitor.dispose();
    }
  }

  RegattaSensorBridge _buildSensorBridge() {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      throw UnsupportedError(
        'Regatta sensor bridge is supported only on Android and iOS.',
      );
    }

    return RegattaSensorBridge();
  }
}
