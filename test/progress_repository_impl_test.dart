import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:educonnect_mobile/data/datasources/local/progress_local_data_source.dart';
import 'package:educonnect_mobile/data/datasources/remote/progress_remote_data_source.dart';
import 'package:educonnect_mobile/data/models/progress_models.dart';
import 'package:educonnect_mobile/data/repositories/progress_repository_impl.dart';
import 'package:educonnect_mobile/domain/entities/course_progress.dart';

class _FakeProgressRemote implements ProgressRemoteDataSource {
  bool failGet = false;
  CourseProgress? progress;
  final List<String> marked = [];

  @override
  Future<void> markLessonComplete({required String courseId, required String lessonId}) async {
    marked.add('$courseId:$lessonId');
  }

  @override
  Future<CourseProgressDto> getCourseProgress(String courseId) async {
    if (failGet || progress == null) {
      throw StateError('offline');
    }
    final p = progress!;
    return CourseProgressDto(
      courseId: courseId,
      totalLessons: p.totalCount,
      completedLessons: p.completedCount,
      percentageComplete: p.percentage,
      lessons: p.lessonCompletion.entries
          .map((e) => LessonProgressDto(lessonId: e.key, isCompleted: e.value))
          .toList(),
    );
  }
}

void main() {
  test('falls back to local progress when remote fails', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final remote = _FakeProgressRemote()..failGet = true;
    final local = ProgressLocalDataSource(prefs);
    await local.setLessonComplete('course-1', 'enroll-1', 'lesson-a');
    await local.setLessonComplete('course-1', 'enroll-1', 'lesson-b');
    await local.addTimeSpent('course-1', 27);
    await local.incrementStreak();

    final repo = ProgressRepositoryImpl(remote, local);
    final progress = await repo.getCourseProgress('course-1', 'enroll-1', 4);

    expect(progress.completedCount, 2);
    expect(progress.totalCount, 4);
    expect(progress.percentage, 50);
    expect(progress.timeSpentMinutes, 27);
    expect(progress.learningStreak, 1);
    expect(progress.lessonCompletion['lesson-a'], true);
  });

  test('markLessonComplete syncs remote and local', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final remote = _FakeProgressRemote();
    final local = ProgressLocalDataSource(prefs);
    final repo = ProgressRepositoryImpl(remote, local);

    await repo.markLessonComplete('course-1', 'enroll-1', 'lesson-a');

    expect(remote.marked, ['course-1:lesson-a']);
    final completion = await local.getLessonCompletion('course-1', 'enroll-1');
    expect(completion['lesson-a'], true);
  });
}
