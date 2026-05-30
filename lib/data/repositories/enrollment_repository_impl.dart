import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/enrollment_remote_data_source.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  const EnrollmentRepositoryImpl({
    required EnrollmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final EnrollmentRemoteDataSource _remoteDataSource;

  @override
  Future<Enrollment> enroll(String courseId) async {
    final createdEnrollment = await _remoteDataSource.enroll(courseId);
    if (createdEnrollment != null) {
      return createdEnrollment.toEntity();
    }

    final enrollments = await getMyEnrollments();
    for (final enrollment in enrollments) {
      if (enrollment.courseId == courseId && enrollment.isActive) {
        return enrollment;
      }
    }

    throw StateError(
      'Enrollment completed but the active enrollment could not be resolved.',
    );
  }

  @override
  Future<void> unenroll(String courseId) async {
    await _remoteDataSource.unenroll(courseId);
  }

  @override
  Future<List<Enrollment>> getMyEnrollments() async {
    final enrollments = await _remoteDataSource.getMyEnrollments();
    return enrollments.map((e) => e.toEntity()).toList();
  }
}
