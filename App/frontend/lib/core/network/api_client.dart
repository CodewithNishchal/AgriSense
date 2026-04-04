import 'package:dio/dio.dart';

import 'app_config.dart';

final ApiClient apiClient = ApiClient();

class ApiClient {
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  late final Dio _dio;
  Dio get dio => _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    final r = await _dio.get<T>(path, queryParameters: queryParameters);
    return r.data as T;
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    final r = await _dio.post<T>(path, data: data);
    return r.data as T;
  }
}
