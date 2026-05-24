import 'dart:typed_data';

import '../../core/config/app_environment.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/remote/certificate_remote_data_source.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  CertificateRepositoryImpl({
    required CertificateRemoteDataSource remoteDataSource,
    required CourseRepository courseRepository,
    required AuthRepository authRepository,
  })  : _remote = remoteDataSource,
        _courseRepository = courseRepository,
        _authRepository = authRepository;

  final CertificateRemoteDataSource _remote;
  final CourseRepository _courseRepository;
  final AuthRepository _authRepository;

  @override
  Future<List<Certificate>> getCertificates() async {
    final dtos = await _remote.getMyCertificates();
    final user = await _authRepository.getCurrentUser();
    final learnerName = user?.fullName ?? 'Learner';
    final certs = <Certificate>[];

    for (final dto in dtos) {
      final title = await _courseTitle(dto.courseId);
      certs.add(
        dto.toEntity(
          courseTitle: title,
          learnerName: learnerName,
          publicBaseUrl: _verifyBaseUrl(),
        ),
      );
    }

    return certs;
  }

  @override
  Future<Certificate?> getCertificate(String certificateId) async {
    final dto = await _remote.getCertificate(certificateId);
    if (dto == null) return null;
    final user = await _authRepository.getCurrentUser();
    return dto.toEntity(
      courseTitle: await _courseTitle(dto.courseId),
      learnerName: user?.fullName ?? 'Learner',
      publicBaseUrl: _verifyBaseUrl(),
    );
  }

  @override
  Future<Uint8List> downloadCertificatePdf(String certificateId) {
    return _remote.downloadCertificatePdf(certificateId);
  }

  Future<String> _courseTitle(String courseId) async {
    try {
      final course = await _courseRepository.getCourseById(courseId);
      return course.title;
    } on Object {
      return 'Course';
    }
  }

  String? _verifyBaseUrl() {
    final api = AppEnvironment.apiBaseUrl;
    if (api.endsWith('/')) {
      return api.substring(0, api.length - 1);
    }
    return null;
  }
}
