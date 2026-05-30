import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<AuthSession?> getStoredSession();

  Future<AuthenticatedUser?> getCurrentUser();

  Future<String?> getAccessToken();

  Future<void> refreshToken();

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
