import 'dart:convert';

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
  emailVerificationRequired,
  emailVerificationCodeSent,
  emailVerified,
}

class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.errorMessage,
    this.pendingEmail,
    this.pendingPassword,
    this.verificationCooldownExpiry,
    this.passwordResetCooldownExpiry,
  });

  const AuthState.unknown()
    : status = AuthStatus.unknown,
      session = null,
      errorMessage = null,
      pendingEmail = null,
      pendingPassword = null,
      verificationCooldownExpiry = null,
      passwordResetCooldownExpiry = null;

  final AuthStatus status;
  final AuthSession? session;
  final String? errorMessage;
  final String? pendingEmail;
  final String? pendingPassword;
  final DateTime? verificationCooldownExpiry;
  final DateTime? passwordResetCooldownExpiry;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? errorMessage,
    String? pendingEmail,
    String? pendingPassword,
    DateTime? verificationCooldownExpiry,
    DateTime? passwordResetCooldownExpiry,
    bool clearPending = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      errorMessage: errorMessage,
      pendingEmail: clearPending ? null : pendingEmail ?? this.pendingEmail,
      pendingPassword: clearPending
          ? null
          : pendingPassword ?? this.pendingPassword,
      verificationCooldownExpiry:
          verificationCooldownExpiry ?? this.verificationCooldownExpiry,
        passwordResetCooldownExpiry:
          passwordResetCooldownExpiry ?? this.passwordResetCooldownExpiry,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  static const Duration verificationCooldown = Duration(minutes: 3);
  static const Duration passwordResetCooldown = Duration(minutes: 3);

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
      state = AuthState(
        status: AuthStatus.authenticated,
        session: session,
      );
    } on Exception catch (error) {
      if (_isVerificationError(error)) {
        state = AuthState(
          status: AuthStatus.emailVerificationRequired,
          errorMessage: _friendlyError(error),
          pendingEmail: email,
          pendingPassword: password,
          verificationCooldownExpiry:
              DateTime.now().add(verificationCooldown),
        );
        return;
      }

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
      await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.emailVerificationRequired,
        pendingEmail: email,
        pendingPassword: password,
        verificationCooldownExpiry: DateTime.now().add(verificationCooldown),
      );
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final now = DateTime.now();
    final expiry = state.passwordResetCooldownExpiry;
    if (expiry != null && now.isBefore(expiry)) {
      final remaining = expiry.difference(now).inSeconds;
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage:
            'Please wait $remaining seconds before requesting a new reset code.',
        passwordResetCooldownExpiry: expiry,
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.requestPasswordReset(email);
      state = state.copyWith(
        status: AuthStatus.passwordResetEmailSent,
        passwordResetCooldownExpiry: DateTime.now().add(passwordResetCooldown),
      );
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.resetPassword(
        email: email,
        code: code,
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

  Future<void> requestEmailVerification(String email) async {
    final now = DateTime.now();
    final expiry = state.verificationCooldownExpiry;
    if (expiry != null && now.isBefore(expiry)) {
      final remaining = expiry.difference(now).inSeconds;
      print('[AuthController] requestEmailVerification blocked, remaining: $remaining s for $email');
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Please wait $remaining seconds before requesting a new code.',
        pendingEmail: email,
        pendingPassword: state.pendingPassword,
        verificationCooldownExpiry: expiry,
      );
      return;
    }

    print('[AuthController] requestEmailVerification starting for $email');
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.requestEmailVerification(email);
      final newExpiry = DateTime.now().add(verificationCooldown);
      print('[AuthController] requestEmailVerification succeeded for $email, expiry set to $newExpiry');
      state = state.copyWith(
        status: AuthStatus.emailVerificationCodeSent,
        verificationCooldownExpiry: newExpiry,
      );
    } on Exception catch (error) {
      print('[AuthController] requestEmailVerification failed for $email: $error');
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> resendEmailVerification(String email) async {
    final now = DateTime.now();
    final expiry = state.verificationCooldownExpiry;
    if (expiry != null && now.isBefore(expiry)) {
      final remaining = expiry.difference(now).inSeconds;
      print('[AuthController] resendEmailVerification blocked, remaining: $remaining s for $email');
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Please wait $remaining seconds before requesting a new code.',
        pendingEmail: email,
        pendingPassword: state.pendingPassword,
        verificationCooldownExpiry: expiry,
      );
      return;
    }

    print('[AuthController] resendEmailVerification starting for $email');
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.resendEmailVerification(email);
      final newExpiry = DateTime.now().add(verificationCooldown);
      print('[AuthController] resendEmailVerification succeeded for $email, expiry set to $newExpiry');
      state = state.copyWith(
        status: AuthStatus.emailVerificationCodeSent,
        verificationCooldownExpiry: newExpiry,
      );
    } on Exception catch (error) {
      print('[AuthController] resendEmailVerification failed for $email: $error');
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<bool> confirmEmailVerification({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await _repository.confirmEmailVerification(email: email, code: code);
      state = state.copyWith(status: AuthStatus.emailVerified);
      return true;
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.failure,
        errorMessage: _friendlyError(error),
      );
      return false;
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
      final apiMessage = _extractApiMessage(error);
      if (apiMessage != null) {
        return apiMessage;
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

  bool _isVerificationError(Object error) {
    final message = _extractApiMessage(error);
    if (message == null) {
      return false;
    }
    final normalized = message.toLowerCase();
    return normalized.contains('verify') ||
        normalized.contains('verification') ||
        normalized.contains('verified');
  }

  String? _extractApiMessage(Object error) {
    if (error is! DioException) {
      return null;
    }

    final data = error.response?.data;
    final map = _coerceErrorMap(data);
    if (map != null) {
      final message = map['message'] ?? map['error'] ?? map['title'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      final nested = map['data'];
      if (nested is Map<String, dynamic>) {
        final nestedMessage =
            nested['message'] ?? nested['error'] ?? nested['title'];
        if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
          return nestedMessage.trim();
        }
      }
    }

    return null;
  }

  Map<String, dynamic>? _coerceErrorMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } on FormatException {
        return null;
      }
    }

    return null;
  }
}
