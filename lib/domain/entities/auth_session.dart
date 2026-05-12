class AuthSession {
  const AuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.user,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final AuthenticatedUser? user;
}

class AuthenticatedUser {
  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;
}
