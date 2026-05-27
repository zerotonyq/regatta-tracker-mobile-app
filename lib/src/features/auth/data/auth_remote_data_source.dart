import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/auth_failure.dart';
import '../../../core/network/auth_token_store.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../api/auth_api.dart';
import '../../api/models/api_models.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required AuthApi? authApi,
    required AuthTokenStore tokenStore,
    bool useMockApi = false,
  }) : _authApi = authApi,
       _tokenStore = tokenStore;

  final AuthApi? _authApi;
  final AuthTokenStore _tokenStore;

  Future<AuthTokensResponseDto> login({
    required String login,
    required String password,
    String? fingerprint,
    String? correlationId,
  }) async {
    final authApi = _authApi;
    if (authApi == null) {
      throw ApiException(
        statusCode: null,
        message: 'Auth API is not configured.',
      );
    }

    try {
      final response = await authApi.login(
        LoginRequestDto(
          login: login,
          password: password,
          fingerprint: fingerprint,
        ),
        correlationId,
      );
      await _tokenStore.writeTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return response;
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<IdResponseDto> register({
    required String name,
    required String surname,
    required UserRole role,
    required String login,
    required String password,
    String? correlationId,
  }) async {
    final authApi = _authApi;
    if (authApi == null) {
      throw ApiException(
        statusCode: null,
        message: 'Auth API is not configured.',
      );
    }

    try {
      return await authApi.register(
        RegisterRequestDto(
          name: name,
          surname: surname,
          role: role,
          login: login,
          password: password,
        ),
        correlationId,
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    } on Object catch (error) {
      // Some backends respond 201 for register without `{ "id": ... }`.
      // Retrofit then throws a parse error, but registration itself succeeded.
      if (_isRegisterResponseParseError(error)) {
        return IdResponseDto(id: 0);
      }
      rethrow;
    }
  }

  Future<AuthTokensResponseDto> refresh({
    String? fingerprintOverride,
    String? correlationId,
  }) async {
    final authApi = _authApi;
    if (authApi == null) {
      throw ApiException(
        statusCode: null,
        message: 'Auth API is not configured.',
      );
    }

    try {
      final refreshToken = await _tokenStore.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AuthFailure(
          type: AuthFailureType.missingRefreshToken,
          statusCode: null,
          message: 'Refresh token is missing.',
        );
      }
      final request = RefreshRequestDto(
        refreshToken: refreshToken,
        fingerprint: fingerprintOverride,
      );
      final response = await authApi.refresh(request, correlationId);
      await _tokenStore.writeTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return response;
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  bool _isRegisterResponseParseError(Object error) {
    if (error is TypeError || error is FormatException) {
      return true;
    }
    final text = error.toString();
    return text.contains('IdResponseDto') ||
        text.contains('Null is not a subtype') ||
        text.contains('type \'String\' is not a subtype') ||
        text.contains('NoSuchMethodError');
  }
}
