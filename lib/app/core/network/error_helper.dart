import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ErrorHelper {
  static ApiException toApiException(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map &&
          data['errors'] is List &&
          (data['errors'] as List).isNotEmpty) {
        final first = (data['errors'] as List).first;
        if (first is Map && first['msg'] != null) {
          return ApiException(first['msg'].toString());
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException(
            'The server is taking too long to respond. Please try again.',
          );
        case DioExceptionType.connectionError:
          return ApiException(
            'Unable to connect. Please check your internet connection.',
          );
        default:
          break;
      }
    }

    return ApiException('Something went wrong. Please try again.');
  }
}
