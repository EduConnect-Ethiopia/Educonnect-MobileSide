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
    final user = response.user;
    if (user != null) {
      await _tokenStorage.saveUser(
        StoredAuthUser(id: user.id, email: user.email, fullName: user.fullName),
      );
    }
    return _toSession(response);
  }

  @override
  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _remoteDataSource.register(
      RegisterRequest(fullName: fullName, email: email, password: password),
    );

    return const AuthSession(accessToken: '');
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _tokenStorage.hasValidSession;
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    if (!_tokenStorage.hasValidSession) return null;

    final accessToken = _tokenStorage.accessToken;
    if (accessToken == null || accessToken.isEmpty) return null;

    final user = await getCurrentUser();
    return AuthSession(
      accessToken: accessToken,
      refreshToken: _tokenStorage.refreshToken,
      expiresAt: _tokenStorage.expiresAt,
      user: user,
    );
  }

  @override
  Future<AuthenticatedUser?> getCurrentUser() async {
    final user = _tokenStorage.user;
    if (user == null) return null;

    return AuthenticatedUser(id: user.id, email: user.email, fullName: user.fullName);
  }

  @override
  Future<String?> getAccessToken() async => _tokenStorage.accessToken;

  @override
  Future<void> refreshToken() async {
    await _tokenStorage.clear();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _remoteDataSource.requestPasswordReset(ForgotPasswordRequest(email: email));
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(
      ResetPasswordRequest(email: email, token: token, newPassword: newPassword),
    );
  }

  @override
  Future<void> requestEmailVerification(String email) async {
    await _remoteDataSource.requestEmailVerification(ForgotPasswordRequest(email: email));
  }

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) async {
    await _remoteDataSource.confirmEmailVerification(email: email, code: code);
  }

  @override
  Future<void> resendEmailVerification(String email) async {
    await _remoteDataSource.resendEmailVerification(ForgotPasswordRequest(email: email));
  }

  AuthSession _toSession(AuthResponse response) {
    final user = response.user;

    return AuthSession(
      accessToken: response.tokens.accessToken,
      refreshToken: response.tokens.refreshToken,
      expiresAt: response.tokens.expiresAt,
      user: user == null
          ? null
          : AuthenticatedUser(id: user.id, email: user.email, fullName: user.fullName),
    );
  }
}
