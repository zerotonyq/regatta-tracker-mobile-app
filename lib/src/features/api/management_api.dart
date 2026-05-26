import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models/api_models.dart';

part 'management_api.g.dart';

@RestApi()
abstract class ManagementApi {
  factory ManagementApi(Dio dio, {String baseUrl}) = _ManagementApi;

  @POST('/management/create_race')
  Future<IdResponseDto> createRace(@Body() CreateRaceRequestDto request);

  @POST('/management/start_race')
  Future<StatusMessageResponseDto> startRace(@Body() RaceIdRequestDto request);

  @POST('/management/end_race')
  Future<StatusMessageResponseDto> endRace(@Body() RaceIdRequestDto request);

  @GET('/management/users')
  Future<UserListResponseDto> searchUsers({
    @Query('role') String? role,
    @Query('query') String? query,
  });

  @GET('/management/my-races')
  Future<RaceSummaryListResponseDto> getMyRaces();

  @GET('/management/races/{race_id}')
  Future<RaceDetailDto> getRace(@Path('race_id') int raceId);

  @GET('/management/races/{race_id}/events')
  Future<RaceEventListResponseDto> getRaceEvents(@Path('race_id') int raceId);

  @POST('/management/races/{race_id}/events')
  Future<RaceEventDto> createRaceEvent(
    @Path('race_id') int raceId,
    @Body() CreateRaceEventRequestDto request,
  );

  @GET('/management/races/{race_id}/course')
  Future<RaceCourseResponseDto> getRaceCourse(@Path('race_id') int raceId);

  @POST('/management/races/{race_id}/course')
  Future<RaceCourseResponseDto> upsertRaceCourse(
    @Path('race_id') int raceId,
    @Body() UpsertRaceCourseRequestDto request,
  );

  @GET('/management/races/{race_id}/results')
  Future<RaceResultsResponseDto> getRaceResults(@Path('race_id') int raceId);

  @GET('/participant/active-race')
  Future<ActiveRaceResponseDto> getActiveRace();
}
