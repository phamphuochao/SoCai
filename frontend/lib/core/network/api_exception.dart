import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    final english = Intl.getCurrentLocale().startsWith('en');
    String message = english
        ? 'Unable to connect to the server.'
        : 'Không thể kết nối tới máy chủ.';
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) {
        message = detail;
      } else if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          message = first['msg'].toString();
        }
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = english
          ? 'The server is taking too long to respond.'
          : 'Máy chủ phản hồi quá chậm.';
    }
    return ApiException(message, statusCode: error.response?.statusCode);
  }

  @override
  String toString() => message;
}
