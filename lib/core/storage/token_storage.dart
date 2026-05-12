import 'package:shared_preferences/shared_preferences.dart';

import '../utils/json_map.dart';

class StoredAuthTokens {
  const StoredAuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }

    return DateTime.now().toUtc().isAfter(expiresAt!.toUtc());
  }

  factory StoredAuthTokens.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final tokenData = findMap(data, const ['tokens', 'auth', 'session']) ?? data;
    final accessToken = findString(
      tokenData,
      const ['accessToken', 'access_token', 'token', 'jwt'],
    );

    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Auth response did not include a JWT token.');
    }

    return StoredAuthTokens(
      accessToken: accessToken,
      refreshToken: findString(
        tokenData,
        const ['refreshToken', 'refresh_token'],
      ),
      expiresAt: parseDateTime(
        tokenData['expiresAt'] ??
            tokenData['expires_at'] ??
            tokenData['expiration'] ??
            tokenData['expires'],
      ),
    );
  }
}

class TokenStorage {
  TokenStorage(this._preferences);

  final SharedPreferences _preferences;

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _expiresAtKey = 'auth.expires_at';

  String? get accessToken => _preferences.getString(_accessTokenKey);

  String? get refreshToken => _preferences.getString(_refreshTokenKey);

  DateTime? get expiresAt {
    final value = _preferences.getString(_expiresAtKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  bool get hasValidSession {
    final token = accessToken;
    if (token == null || token.isEmpty) {
      return false;
    }

    final expiry = expiresAt;
    return expiry == null || DateTime.now().toUtc().isBefore(expiry.toUtc());
  }

  Future<void> saveTokens(StoredAuthTokens tokens) async {
    await _preferences.setString(_accessTokenKey, tokens.accessToken);

    final refreshToken = tokens.refreshToken;
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _preferences.setString(_refreshTokenKey, refreshToken);
    }

    final expiresAt = tokens.expiresAt;
    if (expiresAt != null) {
      await _preferences.setString(_expiresAtKey, expiresAt.toIso8601String());
    }
  }

  Future<void> clear() async {
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_refreshTokenKey);
    await _preferences.remove(_expiresAtKey);
  }
}
