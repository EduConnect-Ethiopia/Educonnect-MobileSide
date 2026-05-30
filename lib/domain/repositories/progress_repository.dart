import '../entities/course_progress.dart';

abstract class ProgressRepository {
  Future<CourseProgress> getCourseProgress(
    String courseId,
    String enrollmentId,
    int totalLessons,
  );

  Future<void> markLessonComplete(
    String courseId,
    String enrollmentId,
    String lessonId,
  );

  Future<int> getLearningStreak();

  Future<void> saveVideoPosition(String lessonId, int positionSeconds);

  Future<int> getVideoPosition(String lessonId);

  Future<void> addTimeSpent(String courseId, int minutes);
}
