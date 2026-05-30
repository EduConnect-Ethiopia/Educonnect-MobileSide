import '../../domain/entities/course_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/local/progress_local_data_source.dart';
import '../datasources/remote/progress_remote_data_source.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._remote, this._local);

  final ProgressRemoteDataSource _remote;
  final ProgressLocalDataSource _local;

  @override
  Future<CourseProgress> getCourseProgress(
    String courseId,
    String enrollmentId,
    int totalLessons,
  ) async {
    try {
      final dto = await _remote.getCourseProgress(courseId);
      final progress = dto.toEntity();
      if (progress.totalCount == 0 && totalLessons > 0) {
        return CourseProgress(
          percentage: progress.percentage,
          completedCount: progress.completedCount,
          totalCount: totalLessons,
          lessonCompletion: progress.lessonCompletion,
        );
      }
      return progress;
    } on Object {
      return _localFallback(courseId, enrollmentId, totalLessons);
    }
  }

  Future<CourseProgress> _localFallback(
    String courseId,
    String enrollmentId,
    int totalLessons,
  ) async {
    final completion = await _local.getLessonCompletion(courseId, enrollmentId);
    final completedCount =
        completion.values.where((completed) => completed).length;
    final percentage = totalLessons == 0
        ? 0.0
        : (completedCount / totalLessons) * 100;
    return CourseProgress(
      percentage: percentage,
      completedCount: completedCount,
      totalCount: totalLessons,
      lessonCompletion: completion,
      timeSpentMinutes: await _local.getTimeSpentMinutes(courseId),
      learningStreak: await _local.getLearningStreak(),
    );
  }

  @override
  Future<void> markLessonComplete(
    String courseId,
    String enrollmentId,
    String lessonId,
  ) async {
    await _remote.markLessonComplete(courseId: courseId, lessonId: lessonId);
    await _local.setLessonComplete(courseId, enrollmentId, lessonId);
    await _local.incrementStreak();
  }

  @override
  Future<int> getLearningStreak() => _local.getLearningStreak();

  @override
  Future<void> saveVideoPosition(String lessonId, int positionSeconds) =>
      _local.saveVideoPosition(lessonId, positionSeconds);

  @override
  Future<int> getVideoPosition(String lessonId) =>
      _local.getVideoPosition(lessonId);

  @override
  Future<void> addTimeSpent(String courseId, int minutes) =>
      _local.addTimeSpent(courseId, minutes);
}
