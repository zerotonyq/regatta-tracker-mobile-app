import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../api/models/api_models.dart';
import '../../api/receiver_api.dart';

class ReceiverRemoteDataSource {
  ReceiverRemoteDataSource({
    required ReceiverApi? receiverApi,
    bool useMockApi = false,
  }) : _receiverApi = receiverApi;

  final ReceiverApi? _receiverApi;

  Future<StatusMessageResponseDto> uploadLocation({
    required DateTime timestampUtc,
    required double longitude,
    required double latitude,
  }) async {
    final receiverApi = _receiverApi;
    if (receiverApi == null) {
      throw ApiException(
        statusCode: null,
        message: 'Receiver API is not configured.',
      );
    }

    try {
      return await receiverApi.uploadLocation(
        UploadLocationRequestDto(
          time: timestampUtc.toUtc().toIso8601String(),
          longitude: longitude,
          latitude: latitude,
        ),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }

  Future<UploadBatchResponseDto> uploadBatch({
    required String requestId,
    int? raceId,
    required List<UploadBatchPointDto> points,
  }) async {
    final receiverApi = _receiverApi;
    if (receiverApi == null) {
      throw ApiException(
        statusCode: null,
        message: 'Receiver API is not configured.',
      );
    }

    try {
      return await receiverApi.uploadBatch(
        UploadBatchRequestDto(
          requestId: requestId,
          raceId: raceId,
          points: points,
        ),
      );
    } on DioException catch (error) {
      throw DioErrorMapper.map(error);
    } on ApiException {
      rethrow;
    }
  }
}
