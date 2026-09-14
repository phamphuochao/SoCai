import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required Future<void> Function() onUnauthorized,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: AppConfig.apiBaseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 15),
           headers: const {'Accept': 'application/json'},
         ),
       ) {
    _dio.interceptors.add(AuthInterceptor(tokenStorage, onUnauthorized));
  }

  final Dio _dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: _clean(query),
      );
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> post(String path, {Object? data}) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> patch(String path, {Object? data}) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete<dynamic>(path);
      return response.data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic>? _clean(Map<String, dynamic>? values) {
    if (values == null) return null;
    return Map.fromEntries(
      values.entries.where((entry) => entry.value != null && entry.value != ''),
    );
  }
}
