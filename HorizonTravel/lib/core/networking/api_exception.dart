import 'package:dio/dio.dart';
import '../../data/models/error_response.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String>? errors;
  final dynamic originalError;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
    this.originalError,
  });

  bool get isNetworkError =>
      statusCode == null ||
      originalError is DioException &&
          (originalError as DioException).type == DioExceptionType.connectionError;

  bool get isSessionExpired => statusCode == 401;
  bool get isAccountLocked => statusCode == 423;
  bool get isRateLimited => statusCode == 429;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;

  factory ApiException.fromDioException(DioException error) {
    int? code = error.response?.statusCode;
    String message = 'An unexpected error occurred';
    Map<String, String>? errors;

    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        final errResponse = ErrorResponse.fromJson(data);
        if (errResponse.message != null && errResponse.message!.isNotEmpty) {
          message = errResponse.message!;
        }
        errors = errResponse.errors;
      } else if (data is String && data.isNotEmpty) {
        message = data;
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Request timed out. Please check your connection.';
          break;
        case DioExceptionType.connectionError:
          message = 'Unable to connect to server. Please check your connection.';
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled.';
          break;
        default:
          message = error.message ?? 'Network error occurred.';
      }
    }

    // Special status code overrides for clean user presentation
    if (code == 401 && message == 'An unexpected error occurred') {
      message = 'Invalid email or password';
    } else if (code == 423) {
      message = 'Account is locked. Please contact support.';
    } else if (code == 429) {
      message = 'Too many requests. Please wait a moment.';
    }

    return ApiException(
      message: message,
      statusCode: code,
      errors: errors,
      originalError: error,
    );
  }

  @override
  String toString() => message;
}
