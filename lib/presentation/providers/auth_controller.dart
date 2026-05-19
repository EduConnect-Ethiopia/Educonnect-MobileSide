import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  failure,
  passwordResetEmailSent,
  passwordResetCompleted,
}

class AuthState {
  const AuthState({required this.status, this.session, this.errorMessage});

  const AuthState.unknown()
    : status = AuthStatus.unknown,
      session = null,
      errorMessage = null;

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _restoreSessionStatus();
    return const AuthState.unknown();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final session = await _repository.login(email: email, password: password);
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final session = await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = AuthState(status: AuthStatus.authenticated, session: session);
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.requestPasswordReset(email);
      state = state.copyWith(status: AuthStatus.passwordResetEmailSent);
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      state = const AuthState(status: AuthStatus.passwordResetCompleted);
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> signOut() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _restoreSessionStatus() async {
    final session = await _repository.getStoredSession();
    state = AuthState(
      status: session == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated,
      session: session,
    );
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['title'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'The connection timed out. Please try again.';
      }

      if (error.response?.statusCode == 401) {
        return 'Invalid email or password.';
      }

      return 'Unable to reach EduConnect. Please try again.';
    }

    if (error is Exception && error.toString().contains('coming soon')) {
      return 'Password reset is coming soon.';
    }

    return 'Something went wrong. Please try again.';
  }
}
