import 'package:dio/dio.dart';
import 'dart:ui' show VoidCallback;
import 'package:flutter/foundation.dart' show kDebugMode;

import '../config/app_environment.dart';
import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

class JwtAuthInterceptor extends QueuedInterceptor {
  JwtAuthInterceptor({
    required TokenStorage tokenStorage,
    required VoidCallback onSessionExpired,
    String? apiBaseUrlOverride,
  })  : _tokenStorage = tokenStorage,
        _onSessionExpired = onSessionExpired,
        _apiBaseUrlOverride = apiBaseUrlOverride;

  final TokenStorage _tokenStorage;
  final VoidCallback _onSessionExpired;
  final String? _apiBaseUrlOverride;

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

    // Determine request host (robustly handle absolute URLs)
    Uri? requestUri;
    try {
      requestUri = options.uri;
    } catch (_) {
      try {
        requestUri = Uri.tryParse('${options.baseUrl}${options.path}');
      } catch (_) {
        requestUri = null;
      }
    }

    final apiBase = (_apiBaseUrlOverride != null && _apiBaseUrlOverride!.trim().isNotEmpty)
        ? _apiBaseUrlOverride!.trim()
        : AppEnvironment.apiBaseUrl;
    Uri? apiUri;
    try {
      apiUri = Uri.tryParse(apiBase);
    } on Object {
      apiUri = null;
    }

    final requestHost = requestUri?.host;
    final apiHost = apiUri?.host;

    final isSameHost = requestHost != null && apiHost != null && requestHost == apiHost;

    if (_isAuthEndpoint(path)) {
      if (kDebugMode) print('[JwtAuthInterceptor] 🔓 Auth endpoint detected: $path (no token needed)');
    } else if (!isSameHost) {
      // External host (e.g., storage, CDN, presigned URL) — do not attach Authorization header
      if (kDebugMode) print('[JwtAuthInterceptor] ↗️  External host detected ($requestHost) — skipping token attach');
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
