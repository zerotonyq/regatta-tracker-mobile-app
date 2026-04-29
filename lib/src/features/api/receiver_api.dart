import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'models/api_models.dart';

part 'receiver_api.g.dart';

@RestApi()
abstract class ReceiverApi {
  factory ReceiverApi(Dio dio, {String baseUrl}) = _ReceiverApi;

  @POST('/receiver/upload')
  Future<StatusMessageResponseDto> uploadLocation(
    @Body() UploadLocationRequestDto request,
  );

  @POST('/receiver/upload-batch')
  Future<UploadBatchResponseDto> uploadBatch(
    @Body() UploadBatchRequestDto request,
  );
}
