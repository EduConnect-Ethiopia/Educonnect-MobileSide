import '../../core/constants/backend_enum_values.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_data_source.dart';
import '../models/course_models.dart';

class CourseRepositoryImpl implements CourseRepository {
  const CourseRepositoryImpl({required CourseRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CourseRemoteDataSource _remoteDataSource;

  @override
  Future<Course> getCourseById(String courseId) async {
    final course = await _remoteDataSource.getCourseById(courseId);
    return course.toEntity();
  }

  @override
  Future<List<Course>> getActiveCoursesForLearner(String userId) async {
    final enrollments = await _remoteDataSource.getLearnerEnrollments(userId);
    final activeEnrollments = enrollments.where(
      (enrollment) =>
          enrollment.enrollmentStatus == BackendEnumValues.enrollmentActive,
    );
    final courses = await Future.wait(
      activeEnrollments.map(_courseForEnrollment),
    );

    return courses.whereType<Course>().where((course) {
      return course.isPublished && course.id.isNotEmpty;
    }).toList();
  }

  Future<Course?> _courseForEnrollment(EnrollmentModel enrollment) async {
    if (enrollment.courseId.isEmpty) {
      return null;
    }

    try {
      final course = await _remoteDataSource.getCourseById(enrollment.courseId);
      return course.toEntity(enrolledAt: enrollment.enrolledAt);
    } on Object {
      return null;
    }
  }
}
