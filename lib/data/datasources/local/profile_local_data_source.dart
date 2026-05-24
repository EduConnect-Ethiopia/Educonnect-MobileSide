import 'package:shared_preferences/shared_preferences.dart';

class ProfileLocalDataSource {
  ProfileLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _phoneKey = 'profile_phone';
  static const _bioKey = 'profile_bio';

  Future<String?> getPhone() async => _prefs.getString(_phoneKey);

  Future<String?> getBio() async => _prefs.getString(_bioKey);

  Future<void> saveProfile({String? phone, String? bio}) async {
    if (phone != null) {
      await _prefs.setString(_phoneKey, phone.trim());
    }
    if (bio != null) {
      await _prefs.setString(_bioKey, bio.trim());
    }
  }
}
