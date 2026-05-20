import '../../domain/entities/enrollment.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/enrollment_remote_data_source.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  const EnrollmentRepositoryImpl({
    required EnrollmentRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final EnrollmentRemoteDataSource _remoteDataSource;

  @override
  Future<void> enroll(String courseId) async {
    await _remoteDataSource.enroll(courseId);
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
