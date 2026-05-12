import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../utils/json_map.dart';

class JwtAuthInterceptor extends QueuedInterceptor {
  JwtAuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _refreshDio = refreshDio,
        _tokenStorage = tokenStorage;

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;

  Future<StoredAuthTokens?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = _tokenStorage.accessToken;

    if (accessToken != null && !_isAuthEndpoint(options.path)) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestPath = err.requestOptions.path;

    if (statusCode != 401 || _isRefreshEndpoint(requestPath)) {
      handler.next(err);
      return;
    }

    final refreshedTokens = await _refreshTokens();
    if (refreshedTokens == null) {
      handler.next(err);
      return;
    }

    try {
      final response = await _retry(err.requestOptions, refreshedTokens);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<StoredAuthTokens?> _refreshTokens() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null) {
      return null;
    }

    _refreshFuture ??= _performRefresh(refreshToken);

    try {
      return await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<StoredAuthTokens?> _performRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final tokens = StoredAuthTokens.fromJson(castJsonMap(response.data));
      await _tokenStorage.saveTokens(tokens);
      return tokens;
    } on DioException {
      await _tokenStorage.clear();
      return null;
    } on FormatException {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    StoredAuthTokens tokens,
  ) {
    final headers = Map<String, dynamic>.from(requestOptions.headers)
      ..['Authorization'] = 'Bearer ${tokens.accessToken}';

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        headers: headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        extra: requestOptions.extra,
        followRedirects: requestOptions.followRedirects,
        listFormat: requestOptions.listFormat,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        receiveTimeout: requestOptions.receiveTimeout,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        sendTimeout: requestOptions.sendTimeout,
        validateStatus: requestOptions.validateStatus,
      ),
    );
  }

  bool _isAuthEndpoint(String path) {
    return path == ApiEndpoints.login ||
        path == ApiEndpoints.register ||
        path == ApiEndpoints.forgotPassword ||
        path == ApiEndpoints.resetPassword ||
        _isRefreshEndpoint(path);
  }

  bool _isRefreshEndpoint(String path) {
    return path == ApiEndpoints.refreshToken;
  }
}
