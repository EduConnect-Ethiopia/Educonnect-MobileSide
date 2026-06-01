import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:educonnect_mobile/presentation/providers/profile_provider.dart';
import 'package:educonnect_mobile/core/di/app_providers.dart';
import 'package:educonnect_mobile/data/datasources/local/profile_local_data_source.dart';
import 'package:educonnect_mobile/domain/entities/auth_session.dart';
import 'package:educonnect_mobile/domain/entities/enrollment.dart';
import 'package:educonnect_mobile/domain/entities/certificate.dart' as cert_entity;
import 'package:educonnect_mobile/domain/repositories/auth_repository.dart';
import 'package:educonnect_mobile/domain/repositories/enrollment_repository.dart';
import 'package:educonnect_mobile/domain/repositories/certificate_repository.dart';
import 'dart:typed_data';

class _FakeAuth implements AuthRepository {
  final AuthenticatedUser? user;
  _FakeAuth(this.user);
  @override
  Future<AuthenticatedUser?> getCurrentUser() async => user;

  // unused
  @override
  Future<void> confirmEmailVerification({required String email, required String code}) async {}
  @override
  Future<AuthSession> login({required String email, required String password}) async => throw UnimplementedError();
  @override
  Future<AuthSession> register({required String fullName, required String email, required String password}) async => throw UnimplementedError();
  @override
  Future<void> logout() async {}
  @override
  Future<bool> isAuthenticated() async => user != null;
  @override
  Future<AuthSession?> getStoredSession() async => null;
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<void> refreshToken() async {}
  @override
  Future<void> requestPasswordReset(String email) async {}
  @override
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {}
  @override
  Future<void> requestEmailVerification(String email) async {}
  @override
  Future<void> resendEmailVerification(String email) async {}
}

class _FakeEnrollmentRepo implements EnrollmentRepository {
  final List<Enrollment> list;
  _FakeEnrollmentRepo(this.list);
  @override
  Future<List<Enrollment>> getMyEnrollments() async => list;

  // other methods unused
  @override
  Future<void> enroll(String courseId) async {}
  @override
  Future<void> unenroll(String courseId) async {}
}

class _FakeCertRepo implements CertificateRepository {
  final List<cert_entity.Certificate> list;
  _FakeCertRepo(this.list);
  @override
  Future<List<cert_entity.Certificate>> getCertificates() async => list;

  @override
  Future<cert_entity.Certificate?> getCertificate(String certificateId) async => null;
  @override
  Future<Uint8List> downloadCertificatePdf(String certificateId) async => Uint8List(0);
}

void main() {
  test('profileProvider builds LearnerProfile from repos and local prefs', () async {
    SharedPreferences.setMockInitialValues({
      'profile_phone': '+251900000000',
      'profile_bio': 'Learner bio',
    });
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(_FakeAuth(const AuthenticatedUser(id: 'u1', email: 'a@b', fullName: 'User One'))),
      enrollmentRepositoryProvider.overrideWithValue(_FakeEnrollmentRepo([
        Enrollment(id: 'e1', learnerId: 'u1', courseId: 'c1', status: 2),
        Enrollment(id: 'e2', learnerId: 'u1', courseId: 'c2', status: 1),
      ])),
      certificateRepositoryProvider.overrideWithValue(_FakeCertRepo([
        cert_entity.Certificate(
          id: 'cert1',
          courseId: 'c1',
          courseTitle: 'C1',
          learnerName: 'User One',
          issuedAt: DateTime.now(),
          uniqueCode: 'X',
        ),
      ])),
      profileLocalDataSourceProvider.overrideWithValue(ProfileLocalDataSource(prefs)),
    ]);

    final profile = await container.read(profileProvider.future);
    expect(profile, isNotNull);
    expect(profile!.user.fullName, 'User One');
    expect(profile.phone, '+251900000000');
    expect(profile.bio, 'Learner bio');
    expect(profile.stats.coursesCompleted, 1);
    expect(profile.stats.certificatesEarned, 1);
  });
}
