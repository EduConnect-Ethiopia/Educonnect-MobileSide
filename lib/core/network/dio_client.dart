import 'package:dio/dio.dart';
import 'dart:ui' show VoidCallback;
import 'package:flutter/foundation.dart' show kDebugMode;

import '../config/app_environment.dart';
import '../storage/token_storage.dart';
import 'jwt_auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({
    required TokenStorage tokenStorage,
    required VoidCallback onSessionExpired,
    String? baseUrlOverride,
  }) {
    final apiBaseUrl = (baseUrlOverride != null && baseUrlOverride.trim().isNotEmpty)
        ? baseUrlOverride.trim()
        : AppEnvironment.apiBaseUrl;

    if (kDebugMode) {
      print('[DioClient] Initializing Dio with base URL: $apiBaseUrl (override=${baseUrlOverride != null})');
    }

    final baseOptions = BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: AppEnvironment.connectTimeout,
      receiveTimeout: AppEnvironment.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: {
        'Accept': Headers.jsonContentType,
        'Content-Type': 'application/json',
      },
      // Don't throw on HTTP errors - handle in interceptor
      validateStatus: (status) {
        return status != null && status < 600;
      },
    );

    final dio = Dio(baseOptions);

    // Add JWT auth interceptor
    final interceptor = JwtAuthInterceptor(
      tokenStorage: tokenStorage,
      onSessionExpired: onSessionExpired,
      apiBaseUrlOverride: baseUrlOverride,
    );
    dio.interceptors.add(interceptor);

    // Add logging interceptor in dev mode for debugging
    if (AppEnvironment.isDev) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: true,
          logPrint: (obj) {
            if (kDebugMode) print('[HTTP] $obj');
              },
        ),
      );
    }

    return dio;
  }
}
