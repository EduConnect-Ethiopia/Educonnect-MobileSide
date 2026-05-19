import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

class JwtAuthInterceptor extends QueuedInterceptor {
  JwtAuthInterceptor({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = _tokenStorage.accessToken;
    final path = options.path;

    if (_isAuthEndpoint(path)) {
      print('[JwtAuthInterceptor] 🔓 Auth endpoint detected: $path (no token needed)');
    } else if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
      print('[JwtAuthInterceptor] ✅ Token attached for: $path');
    } else {
      print('[JwtAuthInterceptor] ⚠️  No token available for: $path');
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
      print('[JwtAuthInterceptor] ❌ 401 Unauthorized for: $path');
      print('[JwtAuthInterceptor] 🔐 Clearing token storage due to 401 error');
      await _tokenStorage.clear();
    } else if (err.type == DioExceptionType.connectionTimeout) {
      print('[JwtAuthInterceptor] ⏱️  Connection timeout: $path');
    } else if (err.type == DioExceptionType.receiveTimeout) {
      print('[JwtAuthInterceptor] ⏱️  Receive timeout: $path');
    } else {
      print('[JwtAuthInterceptor] 🚨 Error on $path: ${err.message}');
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path == ApiEndpoints.login ||
        path == ApiEndpoints.register ||
        path == ApiEndpoints.signup;
  }
}
