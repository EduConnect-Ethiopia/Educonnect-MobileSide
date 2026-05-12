import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/json_map.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);

  Future<AuthResponse> register(RegisterRequest request);

  Future<void> logout();

  Future<void> forgotPassword(ForgotPasswordRequest request);

  Future<void> resetPassword(ResetPasswordRequest request);

  Future<StoredAuthTokens> refreshToken(String refreshToken);
}

class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  const DioAuthRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(castJsonMap(response.data));
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(castJsonMap(response.data));
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>(ApiEndpoints.logout);
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await _dio.post<void>(
      ApiEndpoints.forgotPassword,
      data: request.toJson(),
    );
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await _dio.post<void>(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
    );
  }

  @override
  Future<StoredAuthTokens> refreshToken(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    return StoredAuthTokens.fromJson(castJsonMap(response.data));
  }
}
