import '../../core/constants/backend_enum_values.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_session.dart';
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
  Future<List<Course>> getFeaturedCourses() async {
    final courses = await _remoteDataSource.getFeaturedCourses();
    return courses.map((c) => c.toEntity()).toList();
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    final courses = await _remoteDataSource.searchCourses(query);
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
      ? courses
      : courses.where((c) {
        final title = c.title.toLowerCase();
        final category = c.category.toLowerCase();
        return title.contains(q) || category.contains(q);
        }).toList();

    return filtered.map((c) => c.toEntity()).toList();
  }

  @override
  Future<CourseContent> getCourseContent(String courseId) async {
    final content = await _remoteDataSource.getCourseContent(courseId);
    return content.toEntity();
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

  @override
  Future<List<CourseSession>> getCourseSessions(String courseId) async {
    final sessions = await _remoteDataSource.getCourseSessions(courseId);
    return sessions.map((s) => s.toEntity()).toList();
  }

  @override
  Future<String> getMaterialAccessUrl(String materialId) async {
    return _remoteDataSource.getMaterialAccessUrl(materialId);
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
