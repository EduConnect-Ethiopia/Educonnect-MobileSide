import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:educonnect_mobile/data/datasources/local/profile_local_data_source.dart';

void main() {
  test('saveProfile and get values', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final local = ProfileLocalDataSource(prefs);

    await local.saveProfile(phone: '+251911111111', bio: 'Hello');

    final phone = await local.getPhone();
    final bio = await local.getBio();

    expect(phone, '+251911111111');
    expect(bio, 'Hello');
  });
}
