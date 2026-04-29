import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models/api_models.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<AuthTokensResponseDto> login(
    @Body() LoginRequestDto request,
    @Header('X-Correlation-ID') String? correlationId,
  );

  @POST('/auth/register')
  Future<IdResponseDto> register(
    @Body() RegisterRequestDto request,
    @Header('X-Correlation-ID') String? correlationId,
  );

  @POST('/auth/refresh')
  Future<AuthTokensResponseDto> refresh(
    @Body() RefreshRequestDto? request,
    @Header('X-Correlation-ID') String? correlationId,
  );
}
