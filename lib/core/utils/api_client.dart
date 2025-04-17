import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl, Map<String, dynamic>? headers})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? 'https://favqs.com/api/',
          headers:
              headers ??
              {
                'Authorization': 'Token token=3c8649fc551e873cb01617e6d66dbef6',
                'Content-Type': 'application/json',
              },
        ),
      );

  Future<Response<T>> get<T>({
    Map<String, dynamic>? queryParameters,
    required String path,
  }) async {
    return await _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete<T>(path, queryParameters: queryParameters);
  }

  Dio get dio => _dio;
}
