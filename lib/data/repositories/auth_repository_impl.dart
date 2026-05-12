import '../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
    await _tokenStorage.saveTokens(response.tokens);
    return _toSession(response);
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _remoteDataSource.register(
      RegisterRequest(fullName: fullName, email: email, password: password),
    );
    await _tokenStorage.saveTokens(response.tokens);
    return _toSession(response);
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _tokenStorage.hasValidSession;
  }

  @override
  Future<String?> getAccessToken() async {
    return _tokenStorage.accessToken;
  }

  @override
  Future<void> refreshToken() async {
    final refreshToken = _tokenStorage.refreshToken;
    if (refreshToken == null) {
      return;
    }

    final tokens = await _remoteDataSource.refreshToken(refreshToken);
    await _tokenStorage.saveTokens(tokens);
  }

  @override
  Future<void> requestPasswordReset(String email) {
    return _remoteDataSource.forgotPassword(
      ForgotPasswordRequest(email: email),
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) {
    return _remoteDataSource.resetPassword(
      ResetPasswordRequest(
        email: email,
        token: token,
        newPassword: newPassword,
      ),
    );
  }

  AuthSession _toSession(AuthResponse response) {
    final user = response.user;

    return AuthSession(
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
      expiresAt: response.tokens.expiresAt,
      user: user == null
          ? null
          : AuthenticatedUser(
              id: user.id,
              email: user.email,
              fullName: user.fullName,
            ),
    );
  }
}
