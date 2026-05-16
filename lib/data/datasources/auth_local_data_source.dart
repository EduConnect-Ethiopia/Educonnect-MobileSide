import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _fullNameKey = 'full_name';
  static const _emailKey = 'email';

  final SharedPreferences _preferences;

  AuthLocalDataSource(this._preferences);

  /// Save authentication data to local storage
  Future<void> saveAuthData(
    String token,
    String userId,
    String fullName,
    String email,
  ) async {
    await Future.wait([
      _preferences.setString(_tokenKey, token),
      _preferences.setString(_userIdKey, userId),
      _preferences.setString(_fullNameKey, fullName),
      _preferences.setString(_emailKey, email),
    ]);
  }

  /// Retrieve access token
  Future<String?> getAccessToken() async {
    return _preferences.getString(_tokenKey);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return _preferences.getString(_userIdKey);
  }

  /// Retrieve full name
  Future<String?> getFullName() async {
    return _preferences.getString(_fullNameKey);
  }

  /// Retrieve email
  Future<String?> getEmail() async {
    return _preferences.getString(_emailKey);
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    await Future.wait([
      _preferences.remove(_tokenKey),
      _preferences.remove(_userIdKey),
      _preferences.remove(_fullNameKey),
      _preferences.remove(_emailKey),
    ]);
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _preferences.containsKey(_tokenKey);
  }
}
