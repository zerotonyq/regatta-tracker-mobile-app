import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/app.dart';
import 'package:vkr_regatta/src/core/config/app_config.dart';
import 'package:vkr_regatta/src/core/network/auth_token_store.dart';
import 'package:vkr_regatta/src/core/network/request_metadata_provider.dart';
import 'package:vkr_regatta/src/di/app_dependencies.dart';
import 'package:vkr_regatta/src/features/auth/data/auth_remote_data_source.dart';
import 'package:vkr_regatta/src/features/auth/presentation/auth_bootstrap_controller.dart';
import 'package:vkr_regatta/src/features/auth/presentation/auth_session_controller.dart';
import 'package:vkr_regatta/src/features/local_storage/database/app_database.dart';
import 'package:vkr_regatta/src/features/management/data/management_remote_data_source.dart';
import 'package:vkr_regatta/src/features/receiver/data/receiver_remote_data_source.dart';
import 'package:vkr_regatta/src/presentation/auth/login_page.dart';

void main() {
  testWidgets('renders login after bootstrap', (
    WidgetTester tester,
  ) async {
    final tokenStore = InMemoryAuthTokenStore();
    final authRemoteDataSource = AuthRemoteDataSource(
      authApi: null,
      tokenStore: tokenStore,
      useMockApi: true,
    );
    final authSessionController = AuthSessionController(
      authRemoteDataSource: authRemoteDataSource,
      tokenStore: tokenStore,
    );

    await tester.pumpWidget(
      RegattaApp(
        dependencies: AppDependencies(
          config: AppConfig(
            baseUrl: 'http://localhost',
            userAgent: 'vkr-regatta-mobile/1.0.0',
            connectTimeoutMs: 15000,
            receiveTimeoutMs: 15000,
            useMockApi: true,
          ),
          tokenStore: tokenStore,
          dio: Dio(),
          authDio: Dio(),
          appDatabase: AppDatabase(executor: NativeDatabase.memory()),
          requestMetadataProvider: const RequestMetadataProvider(
            userAgent: 'vkr-regatta-mobile/1.0.0',
            fingerprint: null,
          ),
          authRemoteDataSource: authRemoteDataSource,
          authSessionController: authSessionController,
          authBootstrapController: AuthBootstrapController(
            sessionController: authSessionController,
          ),
          receiverRemoteDataSource: ReceiverRemoteDataSource(
            receiverApi: null,
            useMockApi: true,
          ),
          managementRemoteDataSource: ManagementRemoteDataSource(
            managementApi: null,
            useMockApi: true,
          ),
          enableBackgroundSyncWorker: false,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
