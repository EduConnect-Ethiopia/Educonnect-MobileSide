import '../entities/enrollment.dart';

abstract class EnrollmentRepository {
  Future<Enrollment> enroll(String courseId);
  Future<void> unenroll(String courseId);
  Future<List<Enrollment>> getMyEnrollments();
}
