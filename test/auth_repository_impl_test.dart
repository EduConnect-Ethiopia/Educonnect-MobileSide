import 'package:educonnect_mobile/core/storage/token_storage.dart';
import 'package:educonnect_mobile/data/datasources/auth_remote_data_source.dart';
import 'package:educonnect_mobile/data/models/auth_models.dart';
import 'package:educonnect_mobile/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('register signs up without auto-login', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final remote = _FakeAuthRemoteDataSource();
    final repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: TokenStorage(preferences),
    );

    final session = await repository.register(
      fullName: 'Abebe Bekele',
      email: 'abebe@example.com',
      password: 'Password123!',
    );

    expect(remote.registeredEmail, 'abebe@example.com');
    expect(remote.loginEmail, isNull);
    expect(remote.loginPassword, isNull);
    expect(session.accessToken, isEmpty);
    expect(await repository.isAuthenticated(), isFalse);
  });

  test('logout and refresh clear local auth state only', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = TokenStorage(preferences);
    await storage.saveTokens(const StoredAuthTokens(accessToken: 'jwt-token'));
    await storage.saveUser(
      const StoredAuthUser(
        id: 'user-1',
        email: 'abebe@example.com',
        fullName: 'Abebe Bekele',
      ),
    );
    final repository = AuthRepositoryImpl(
      remoteDataSource: _FakeAuthRemoteDataSource(),
      tokenStorage: storage,
    );

    await repository.logout();

    expect(await repository.isAuthenticated(), isFalse);
    expect(await repository.getCurrentUser(), isNull);

    await storage.saveTokens(const StoredAuthTokens(accessToken: 'jwt-token'));
    await repository.refreshToken();

    expect(await repository.isAuthenticated(), isFalse);
  });
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? registeredEmail;
  String? loginEmail;
  String? loginPassword;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    loginEmail = request.email;
    loginPassword = request.password;

    return const AuthResponse(
      tokens: StoredAuthTokens(accessToken: 'jwt-token'),
      user: AuthUser(
        id: 'user-1',
        email: 'abebe@example.com',
        fullName: 'Abebe Bekele',
      ),
    );
  }

  @override
  Future<void> register(RegisterRequest request) async {
    registeredEmail = request.email;
  }

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<void> requestEmailVerification(String email) async {}

  @override
  Future<void> confirmEmailVerification({
    required String email,
    required String code,
  }) async {}

  @override
  Future<void> resendEmailVerification(String email) async {}
}
