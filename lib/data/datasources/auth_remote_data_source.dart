import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/utils/json_map.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);

  Future<void> register(RegisterRequest request);

  Future<void> requestPasswordReset(String email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });
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
  Future<void> register(RegisterRequest request) async {
    await _dio.post<dynamic>(ApiEndpoints.register, data: request.toJson());
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _dio.post<dynamic>(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.resetPassword,
      data: {
        'email': email.trim(),
        'token': token.trim(),
        'newPassword': newPassword,
      },
    );
  }
}
