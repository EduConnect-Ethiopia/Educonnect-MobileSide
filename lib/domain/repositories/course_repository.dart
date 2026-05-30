import '../entities/course.dart';
import '../entities/course_content.dart';
import '../entities/course_session.dart';

abstract class CourseRepository {
  Future<Course> getCourseById(String courseId);
  Future<List<Course>> getFeaturedCourses();
  Future<List<Course>> searchCourses(String query);
  Future<CourseContent> getCourseContent(String courseId);
  Future<List<Course>> getActiveCoursesForLearner(String userId);
  Future<List<CourseSession>> getCourseSessions(String courseId);
  Future<String> getMaterialAccessUrl(String materialId);
}
