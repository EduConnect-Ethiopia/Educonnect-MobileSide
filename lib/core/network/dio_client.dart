import 'package:dio/dio.dart';

import '../config/app_environment.dart';
import '../storage/token_storage.dart';
import 'jwt_auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({required TokenStorage tokenStorage}) {
    final baseOptions = BaseOptions(
      baseUrl: AppEnvironment.apiBaseUrl,
      connectTimeout: AppEnvironment.connectTimeout,
      receiveTimeout: AppEnvironment.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const {'Accept': Headers.jsonContentType},
    );

    final dio = Dio(baseOptions);

    dio.interceptors.add(JwtAuthInterceptor(tokenStorage: tokenStorage));

    if (AppEnvironment.isDev) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
