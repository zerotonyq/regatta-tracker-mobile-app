import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'auth_failure.dart';
import 'network_failure.dart';

class DioErrorMapper {
  static ApiException map(DioException error) {
    final nestedError = error.error;
    if (nestedError is ApiException) {
      return nestedError;
    }

    final response = error.response;
    final body = response?.data;
    final statusCode = response?.statusCode;

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return NetworkFailure(
        type: NetworkFailureType.timeout,
        statusCode: statusCode,
        message: 'Истекло время ожидания ответа сервера. Повторите попытку.',
        rawBody: body,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkFailure(
        type: NetworkFailureType.offline,
        statusCode: statusCode,
        message: 'Нет сети или сервер недоступен.',
        rawBody: body,
      );
    }

    final backendMessage = _extractBackendMessage(body);

    if (statusCode == 401) {
      return AuthFailure(
        type: AuthFailureType.unauthorized,
        statusCode: statusCode,
        message: backendMessage ?? 'Сессия недействительна. Войдите снова.',
        rawBody: body,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return NetworkFailure(
        type: NetworkFailureType.server,
        statusCode: statusCode,
        message:
            backendMessage ??
            error.message ??
            'Не удалось обработать ответ сервера.',
        rawBody: body,
      );
    }

    return ApiException(
      statusCode: statusCode,
      message:
          backendMessage ??
          error.message ??
          'Не удалось обработать ответ сервера.',
      rawBody: body,
    );
  }

  static String? _extractBackendMessage(Object? body) {
    if (body is Map) {
      final message = body['message'] ?? body['error'];
      return message is String && message.isNotEmpty ? message : null;
    }

    if (body is String && body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map) {
          final message = decoded['message'] ?? decoded['error'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      } catch (_) {
        return body;
      }

      return body;
    }

    return null;
  }
}
