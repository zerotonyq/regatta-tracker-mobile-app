import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vkr_regatta/src/core/domain/app_role.dart';
import 'package:vkr_regatta/src/core/network/auth_failure.dart';
import 'package:vkr_regatta/src/core/network/auth_token_store.dart';
import 'package:vkr_regatta/src/core/network/network_failure.dart';
import 'package:vkr_regatta/src/features/api/auth_api.dart';
import 'package:vkr_regatta/src/features/api/models/api_models.dart';
import 'package:vkr_regatta/src/features/auth/data/auth_remote_data_source.dart';
import 'package:vkr_regatta/src/features/auth/presentation/auth_session_controller.dart';
import 'package:vkr_regatta/src/features/auth/presentation/auth_session_state.dart';

void main() {
  group('AuthSessionController', () {
    test(
      'restoreSession authenticates with stored refresh token and role from token',
      () async {
        final tokenStore = InMemoryAuthTokenStore();
        await tokenStore.writeTokens(
          accessToken: _jwt(role: 'participant', sub: 42),
          refreshToken: 'refresh-token',
        );

        final controller = AuthSessionController(
          authRemoteDataSource: AuthRemoteDataSource(
            authApi: _FakeAuthApi(
              onRefresh: ({required request, correlationId}) async {
                return AuthTokensResponseDto(
                  accessToken: _jwt(role: 'participant', sub: 42),
                  refreshToken: 'new-refresh',
                );
              },
            ),
            tokenStore: tokenStore,
            useMockApi: false,
          ),
          tokenStore: tokenStore,
        );

        await controller.restoreSession();

        expect(controller.status, AuthSessionStatus.authenticated);
        expect(controller.selectedRole, AppRole.participant);
        expect(controller.userId, 42);
        expect(await tokenStore.readRefreshToken(), 'new-refresh');
        expect(await tokenStore.readRole(), AppRole.participant);
      },
    );

    test('restoreSession enters failure on retryable network error', () async {
      final tokenStore = InMemoryAuthTokenStore();
      await tokenStore.writeTokens(
        accessToken: _jwt(role: 'judge', sub: 7),
        refreshToken: 'refresh-token',
      );

      final controller = AuthSessionController(
        authRemoteDataSource: AuthRemoteDataSource(
          authApi: _FakeAuthApi(
            onRefresh: ({required request, correlationId}) async {
              throw NetworkFailure(
                type: NetworkFailureType.offline,
                statusCode: null,
                message: 'No network connection or backend is unreachable.',
              );
            },
          ),
          tokenStore: tokenStore,
          useMockApi: false,
        ),
        tokenStore: tokenStore,
      );

      await controller.restoreSession();

      expect(controller.status, AuthSessionStatus.failure);
      expect(controller.selectedRole, AppRole.judge);
      expect(controller.error, contains('No network connection'));
      expect(await tokenStore.readRefreshToken(), 'refresh-token');
    });

    test('refreshSession clears session on terminal auth failure', () async {
      final tokenStore = InMemoryAuthTokenStore();
      await tokenStore.writeTokens(
        accessToken: _jwt(role: 'participant', sub: 99),
        refreshToken: 'refresh-token',
      );

      final controller = AuthSessionController(
        authRemoteDataSource: AuthRemoteDataSource(
          authApi: _FakeAuthApi(
            onRefresh: ({required request, correlationId}) async {
              throw AuthFailure(
                type: AuthFailureType.sessionExpired,
                statusCode: 401,
                message: 'Session expired. Please sign in again.',
              );
            },
          ),
          tokenStore: tokenStore,
          useMockApi: false,
        ),
        tokenStore: tokenStore,
      );

      await expectLater(
        controller.refreshSession(),
        throwsA(isA<AuthFailure>()),
      );

      expect(controller.status, AuthSessionStatus.expired);
      expect(await tokenStore.readRefreshToken(), isNull);
      expect(await tokenStore.readRole(), isNull);
    });

    test('login authenticates with role from access token', () async {
      final tokenStore = InMemoryAuthTokenStore();
      final controller = AuthSessionController(
        authRemoteDataSource: AuthRemoteDataSource(
          authApi: _FakeAuthApi(
            onLogin: ({required request, correlationId}) async {
              return AuthTokensResponseDto(
                accessToken: _jwt(role: 'judge', sub: 55),
                refreshToken: 'login-refresh-token',
              );
            },
            onRefresh: ({required request, correlationId}) async {
              throw UnimplementedError();
            },
          ),
          tokenStore: tokenStore,
          useMockApi: false,
        ),
        tokenStore: tokenStore,
      );

      await controller.login(login: 'judge', password: 'Secret123!');

      expect(controller.status, AuthSessionStatus.authenticated);
      expect(controller.selectedRole, AppRole.judge);
      expect(controller.userId, 55);
      expect(await tokenStore.readRole(), AppRole.judge);
    });
  });
}

typedef _LoginHandler =
    Future<AuthTokensResponseDto> Function({
      required LoginRequestDto request,
      String? correlationId,
    });

typedef _RefreshHandler =
    Future<AuthTokensResponseDto> Function({
      required RefreshRequestDto request,
      String? correlationId,
    });

class _FakeAuthApi implements AuthApi {
  _FakeAuthApi({_LoginHandler? onLogin, required _RefreshHandler onRefresh})
    : _onLogin = onLogin,
      _onRefresh = onRefresh;

  final _LoginHandler? _onLogin;
  final _RefreshHandler _onRefresh;

  @override
  Future<AuthTokensResponseDto> login(
    LoginRequestDto request,
    String? correlationId,
  ) async {
    final onLogin = _onLogin;
    if (onLogin != null) {
      return onLogin(request: request, correlationId: correlationId);
    }
    return AuthTokensResponseDto(
      accessToken: _jwt(role: 'participant', sub: 1),
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
  ) {
    return _onRefresh(request: request!, correlationId: correlationId);
  }
}

String _jwt({required String role, required int sub}) {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode('{"sub":"$sub","role":"$role"}'),
  );
  return '$header.$payload.signature';
}
