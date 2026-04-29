import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/config/app_config.dart';
import 'package:vkr_regatta/src/core/network/auth_token_store.dart';
import 'package:vkr_regatta/src/features/api/auth_api.dart';
import 'package:vkr_regatta/src/features/api/models/api_models.dart';
import 'package:vkr_regatta/src/features/auth/data/auth_remote_data_source.dart';

void main() {
  group('Auth contract', () {
    test('RegisterRequestDto serializes role in lowercase', () {
      final request = RegisterRequestDto(
        name: 'John',
        surname: 'Doe',
        role: UserRole.participant,
        login: 'johndoe',
        password: 'Str0ng!Pass',
      );

      expect(request.toJson(), {
        'name': 'John',
        'surname': 'Doe',
        'role': 'participant',
        'login': 'johndoe',
        'password': 'Str0ng!Pass',
      });
    });

    test('optional auth fingerprints are omitted from JSON when absent', () {
      expect(
        LoginRequestDto(login: 'johndoe', password: 'Str0ng!Pass').toJson(),
        {'login': 'johndoe', 'password': 'Str0ng!Pass'},
      );
      expect(RefreshRequestDto().toJson(), isEmpty);
    });

    test('AppConfig provides a backend-compatible default fingerprint', () {
      final config = AppConfig.fromEnvironment();

      expect(config.fingerprint, isNotNull);
      expect(config.fingerprint, isNotEmpty);
    });

    test(
      'AuthRemoteDataSource persists auth tokens and refresh payload',
      () async {
        final authApi = _FakeAuthApi();
        final tokenStore = InMemoryAuthTokenStore();
        final dataSource = AuthRemoteDataSource(
          authApi: authApi,
          tokenStore: tokenStore,
          useMockApi: false,
        );

        final loginResponse = await dataSource.login(
          login: 'johndoe',
          password: 'Str0ng!Pass',
          fingerprint: 'login-fingerprint',
          correlationId: 'login-correlation',
        );

        expect(authApi.lastLoginRequest?.toJson(), {
          'login': 'johndoe',
          'password': 'Str0ng!Pass',
          'fingerprint': 'login-fingerprint',
        });
        expect(authApi.lastLoginCorrelationId, 'login-correlation');
        expect(loginResponse.accessToken, 'login-access-token');
        expect(loginResponse.refreshToken, 'login-refresh-token');

        final refreshResponse = await dataSource.refresh(
          fingerprintOverride: 'refresh-fingerprint',
          correlationId: 'refresh-correlation',
        );

        expect(authApi.lastRefreshCorrelationId, 'refresh-correlation');
        expect(authApi.lastRefreshRequest?.toJson(), {
          'refresh_token': 'login-refresh-token',
          'fingerprint': 'refresh-fingerprint',
        });
        expect(refreshResponse.accessToken, 'refresh-access-token');
        expect(refreshResponse.refreshToken, 'refresh-refresh-token');
      },
    );
  });
}

class _FakeAuthApi implements AuthApi {
  LoginRequestDto? lastLoginRequest;
  String? lastLoginCorrelationId;

  RefreshRequestDto? lastRefreshRequest;
  String? lastRefreshCorrelationId;

  @override
  Future<AuthTokensResponseDto> login(
    LoginRequestDto request,
    String? correlationId,
  ) async {
    lastLoginRequest = request;
    lastLoginCorrelationId = correlationId;
    return AuthTokensResponseDto(
      accessToken: 'login-access-token',
      refreshToken: 'login-refresh-token',
    );
  }

  @override
  Future<IdResponseDto> register(
    RegisterRequestDto request,
    String? correlationId,
  ) async {
    return IdResponseDto(id: 1);
  }

  @override
  Future<AuthTokensResponseDto> refresh(
    RefreshRequestDto? request,
    String? correlationId,
  ) async {
    lastRefreshRequest = request;
    lastRefreshCorrelationId = correlationId;
    return AuthTokensResponseDto(
      accessToken: 'refresh-access-token',
      refreshToken: 'refresh-refresh-token',
    );
  }
}
