import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

class JwtAuthInterceptor extends QueuedInterceptor {
  JwtAuthInterceptor({
    required TokenStorage tokenStorage,
    required VoidCallback onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired;

  final TokenStorage _tokenStorage;
  final VoidCallback _onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = _tokenStorage.accessToken;
    final path = options.path;

    // Add CORS headers for Web
    options.headers['Access-Control-Allow-Origin'] = '*';
    options.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS';
    options.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization';

    if (_isAuthEndpoint(path)) {
      if (kDebugMode) print('[JwtAuthInterceptor] 🔓 Auth endpoint detected: $path (no token needed)');
    } else if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      if (kDebugMode) print('[JwtAuthInterceptor] ✅ Token attached for: $path');
    } else {
      if (kDebugMode) print('[JwtAuthInterceptor] ⚠️  No token available for: $path');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    if (statusCode == 401 && !_isAuthEndpoint(path)) {
      if (kDebugMode) print('[JwtAuthInterceptor] ❌ 401 Unauthorized for: $path');
      if (kDebugMode) print('[JwtAuthInterceptor] 🔐 Triggering session expiration callback');
      _onSessionExpired();
    } else if (err.type == DioExceptionType.connectionTimeout) {
      if (kDebugMode) print('[JwtAuthInterceptor] ⏱️  Connection timeout: $path');
    } else if (err.type == DioExceptionType.receiveTimeout) {
      if (kDebugMode) print('[JwtAuthInterceptor] ⏱️  Receive timeout: $path');
    } else if (err.type == DioExceptionType.unknown) {
      if (kDebugMode) print('[JwtAuthInterceptor] 🚨 Network error on $path: ${err.message}');
    } else {
      if (kDebugMode) print('[JwtAuthInterceptor] 🚨 Error on $path: ${err.message}');
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path == ApiEndpoints.login ||
        path == ApiEndpoints.register ||
        path == ApiEndpoints.signup ||
        path.contains('/api/Auth');
  }
}
