import '../entities/course.dart';

abstract class CourseRepository {
  Future<Course> getCourseById(String courseId);

  Future<List<Course>> getActiveCoursesForLearner(String userId);
}
