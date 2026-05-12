import '../../core/storage/token_storage.dart';
import '../../core/utils/json_map.dart';

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  JsonMap toJson() {
    return {
      'email': email.trim(),
      'password': password,
    };
  }
}

class RegisterRequest {
  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;

  JsonMap toJson() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'password': password,
      'role': 'Learner',
    };
  }
}

class ForgotPasswordRequest {
  const ForgotPasswordRequest({
    required this.email,
  });

  final String email;

  JsonMap toJson() {
    return {
      'email': email.trim(),
    };
  }
}

class ResetPasswordRequest {
  const ResetPasswordRequest({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  final String email;
  final String token;
  final String newPassword;

  JsonMap toJson() {
    return {
      'email': email.trim(),
      'token': token,
      'newPassword': newPassword,
    };
  }
}

class AuthResponse {
  const AuthResponse({
    required this.tokens,
    this.user,
  });

  final StoredAuthTokens tokens;
  final AuthUser? user;

  factory AuthResponse.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final userJson = findMap(data, const ['user', 'profile']);

    return AuthResponse(
      tokens: StoredAuthTokens.fromJson(data),
      user: userJson == null ? null : AuthUser.fromJson(userJson),
    );
  }
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;

  factory AuthUser.fromJson(JsonMap json) {
    return AuthUser(
      id: findString(json, const ['id', 'userId', 'sub']) ?? '',
      email: findString(json, const ['email']) ?? '',
      fullName: findString(json, const ['fullName', 'name']) ?? '',
    );
  }
}
