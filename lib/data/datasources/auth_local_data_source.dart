import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const _accessTokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _fullNameKey = 'full_name';
  static const _emailKey = 'email';

  Future<void> saveAuthData(
    String accessToken,
    String userId,
    String fullName,
    String email,
  ) async {
    await _preferences.setString(_accessTokenKey, accessToken);
    await _preferences.setString(_userIdKey, userId);
    await _preferences.setString(_fullNameKey, fullName);
    await _preferences.setString(_emailKey, email);
  }

  Future<String?> getAccessToken() async => _preferences.getString(_accessTokenKey);

  Future<String?> getUserId() async => _preferences.getString(_userIdKey);

  Future<String?> getFullName() async => _preferences.getString(_fullNameKey);

  Future<String?> getEmail() async => _preferences.getString(_emailKey);

  Future<void> clearAuthData() async {
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_userIdKey);
    await _preferences.remove(_fullNameKey);
    await _preferences.remove(_emailKey);
  }
}
