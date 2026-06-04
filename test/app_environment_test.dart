import 'package:educonnect_mobile/core/config/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes whitespace in API base URLs', () {
    expect(
      AppEnvironment.normalizeApiBaseUrl('http:// 192.168.137.79:5001 '),
      'http://192.168.137.79:5001',
    );
  });

  test('preserves https URLs when normalizing', () {
    expect(
      AppEnvironment.normalizeApiBaseUrl(' https://api.educonnect.et '),
      'https://api.educonnect.et',
    );
  });
}
