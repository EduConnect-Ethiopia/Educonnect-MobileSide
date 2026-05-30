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
    required String code,
    required String newPassword,
  });

  Future<void> requestEmailVerification(String email);

  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  });

  Future<void> resendEmailVerification(String email);
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
    required String code,
    required String newPassword,
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.resetPassword,
      data: {
        'email': email.trim(),
        'code': code.trim(),
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<void> requestEmailVerification(String email) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.requestEmailVerification,
      data: {'email': email.trim()},
    );
    try {
      print('[AuthRemote] requestEmailVerification status: ${response.statusCode} body: ${response.data}');
    } catch (_) {}
  }

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.confirmEmailVerification,
      data: {
        'email': email.trim(),
        'code': code.trim(),
      },
    );
  }

  @override
  Future<void> resendEmailVerification(String email) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.resendEmailVerification,
      data: {'email': email.trim()},
    );
    try {
      print('[AuthRemote] resendEmailVerification status: ${response.statusCode} body: ${response.data}');
    } catch (_) {}
  }
}
