import 'package:educonnect_mobile/data/models/auth_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signup request does not send role', () {
    final request = const RegisterRequest(
      fullName: ' Abebe Bekele ',
      email: ' abebe@example.com ',
      password: 'Password123!',
    ).toJson();

    expect(request, {
      'fullName': 'Abebe Bekele',
      'email': 'abebe@example.com',
      'password': 'Password123!',
    });
    expect(request.containsKey('role'), isFalse);
  });

  test('login response parses backend data shape', () {
    final response = AuthResponse.fromJson({
      'success': true,
      'message': 'Login successful!',
      'data': {
        'success': true,
        'token': 'jwt-token',
        'userId': 'user-1',
        'fullName': 'Abebe Bekele',
        'email': 'abebe@example.com',
      },
    });

    expect(response.tokens.accessToken, 'jwt-token');
    expect(response.tokens.refreshToken, isNull);
    expect(response.user?.id, 'user-1');
    expect(response.user?.fullName, 'Abebe Bekele');
    expect(response.user?.email, 'abebe@example.com');
  });
}
