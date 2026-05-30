import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _phoneKey = 'profile_phone';
  static const _bioKey = 'profile_bio';
  static const _avatarKey = 'profile_avatar_base64';

  Future<String?> getPhone() async => _prefs.getString(_phoneKey);

  Future<String?> getBio() async => _prefs.getString(_bioKey);

  Future<String?> getAvatarBase64() async => _prefs.getString(_avatarKey);

  Future<void> saveProfile({
    String? phone,
    String? bio,
    String? avatarBase64,
  }) async {
    if (phone != null) {
      await _prefs.setString(_phoneKey, phone.trim());
    }
    if (bio != null) {
      await _prefs.setString(_bioKey, bio.trim());
    }
    if (avatarBase64 != null) {
      if (avatarBase64.isEmpty) {
        await _prefs.remove(_avatarKey);
      } else {
        await _prefs.setString(_avatarKey, avatarBase64);
      }
    }
  }

  Future<void> clearAvatar() => _prefs.remove(_avatarKey);

  List<int>? getAvatarBytes() {
    final raw = _prefs.getString(_avatarKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } on Object {
      return null;
    }
  }
}
