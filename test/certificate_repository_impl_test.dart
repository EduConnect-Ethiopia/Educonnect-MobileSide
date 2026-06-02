import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:educonnect_mobile/data/datasources/remote/certificate_remote_data_source.dart';
import 'package:educonnect_mobile/data/models/certificate_models.dart';
import 'package:educonnect_mobile/data/repositories/certificate_repository_impl.dart';
import 'package:educonnect_mobile/domain/entities/course.dart';
import 'package:educonnect_mobile/domain/entities/auth_session.dart';
import 'package:educonnect_mobile/domain/repositories/course_repository.dart';
import 'package:educonnect_mobile/domain/repositories/auth_repository.dart';
import 'package:educonnect_mobile/domain/entities/course_content.dart';
import 'package:educonnect_mobile/domain/entities/course_session.dart';
import 'package:educonnect_mobile/domain/repositories/certificate_repository.dart';

class _FakeRemote implements CertificateRemoteDataSource {
  List<CertificateDto> dtos = [];
  Map<String, List<int>> downloads = {};

  @override
  Future<List<CertificateDto>> getMyCertificates() async {
    return dtos;
  }

  @override
  Future<CertificateDto?> getCertificate(String id) async {
    return dtos.firstWhere((d) => d.certificateId == id, orElse: () => throw StateError('not found'));
  }

  @override
  Future<Uint8List> downloadCertificatePdf(String id) async {
    final bytes = downloads[id] ?? <int>[];
    return Uint8List.fromList(bytes);
  }

  @override
  Future<CertificateEligibilityDto> getEligibility(String courseId) async => const CertificateEligibilityDto(isEligible: false, missingRequirements: []);

  @override
  Future<CertificateDto> issueCertificate(String courseId) async => throw UnimplementedError();
}

class _FakeCourseRepo implements CourseRepository {
  final Map<String, Course> map;
  _FakeCourseRepo(this.map);

  @override
  Future<Course> getCourseById(String courseId) async => map[courseId]!;

  // Unused in this test
  @override
  Future<List<Course>> getPublishedCourses() async => [];

  @override
  Future<List<Course>> getActiveCoursesForLearner(String userId) async => [];

  @override
  Future<CourseContent> getCourseContent(String courseId) async => throw UnimplementedError();

  @override
  Future<List<CourseSession>> getCourseSessions(String courseId) async => [];

  @override
  Future<List<Course>> searchCourses(String query) async => [];

  @override
  Future<String> getMaterialAccessUrl(String materialId) async => '';
}

class _FakeAuthRepo implements AuthRepository {
  final AuthenticatedUser? user;
  _FakeAuthRepo(this.user);

  @override
  Future<AuthenticatedUser?> getCurrentUser() async => user;

  // other methods not used in test
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
  Future<void> confirmEmailVerification({required String email, required String code}) async {}
  @override
  Future<void> resendEmailVerification(String email) async {}
}

void main() {
  test('maps certificate DTOs to entities with course titles and learner name', () async {
    final remote = _FakeRemote();
    remote.dtos = [
      CertificateDto(
        certificateId: 'cert-1',
        courseId: 'course-1',
        issueDate: DateTime.parse('2024-01-01'),
        certificateUrl: 'https://cdn/cert-1.pdf',
        verificationCode: 'ABC123',
      ),
    ];

    final course = Course(
      id: 'course-1',
      title: 'Intro to Testing',
      description: '',
      category: 'dev',
      mode: 0,
      status: 1,
      price: 0,
      instructor: 'Instructor',
    );

    final courseRepo = _FakeCourseRepo({'course-1': course});
    final authRepo = _FakeAuthRepo(const AuthenticatedUser(id: 'u1', email: 'a@b', fullName: 'Ada Lovelace'));

    final repo = CertificateRepositoryImpl(
      remoteDataSource: remote,
      courseRepository: courseRepo,
      authRepository: authRepo,
    );

    final certs = await repo.getCertificates();
    expect(certs.length, 1);
    final c = certs.first;
    expect(c.courseTitle, 'Intro to Testing');
    expect(c.learnerName, 'Ada Lovelace');
    expect(c.pdfUrl, 'https://cdn/cert-1.pdf');
    expect(c.uniqueCode, 'ABC123');
  });

  test('downloadCertificatePdf returns bytes from remote', () async {
    final remote = _FakeRemote();
    remote.downloads['cert-2'] = [1, 2, 3, 4];

    final courseRepo = _FakeCourseRepo({});
    final authRepo = _FakeAuthRepo(null);
    final repo = CertificateRepositoryImpl(remoteDataSource: remote, courseRepository: courseRepo, authRepository: authRepo);

    final bytes = await repo.downloadCertificatePdf('cert-2');
    expect(bytes, Uint8List.fromList([1, 2, 3, 4]));
  });
}
