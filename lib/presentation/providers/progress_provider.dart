import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course_content.dart';

final progressControllerProvider =
    NotifierProvider<ProgressController, ProgressState>(ProgressController.new);

class ProgressController extends Notifier<ProgressState> {
  String? _courseId;

  @override
  ProgressState build() => ProgressState.initial();

  Future<void> loadCourseProgress({
    required String courseId,
    required String enrollmentId,
    required CourseContent content,
  }) async {
    _courseId = courseId;
    state = state.copyWith(isLoading: true);
    final totalLessons = _countLessons(content);
    final progress = await ref.read(progressRepositoryProvider).getCourseProgress(
          courseId,
          enrollmentId,
          totalLessons,
        );
    state = ProgressState(
      isLoading: false,
      overallProgress: progress.percentage,
      completedLessons: progress.completedCount,
      totalLessons: progress.totalCount,
      lessonCompletion: progress.lessonCompletion,
      learningStreak: progress.learningStreak,
      timeSpentMinutes: progress.timeSpentMinutes,
    );
  }

  Future<void> loadLearningStreak() async {
    final streak = await ref.read(progressRepositoryProvider).getLearningStreak();
    state = state.copyWith(learningStreak: streak);
  }

  Future<void> markLessonComplete(
    String enrollmentId,
    String lessonId,
  ) async {
    final courseId = _courseId;
    if (courseId == null) return;

    await ref.read(progressRepositoryProvider).markLessonComplete(
          courseId,
          enrollmentId,
          lessonId,
        );
    final completion = Map<String, bool>.from(state.lessonCompletion);
    if (completion[lessonId] != true) {
      completion[lessonId] = true;
      final completed = state.completedLessons + 1;
      final total = state.totalLessons;
      state = state.copyWith(
        lessonCompletion: completion,
        completedLessons: completed,
        overallProgress: total == 0 ? 0 : (completed / total) * 100,
      );
    }
  }

  int _countLessons(CourseContent content) {
    return content.modules.fold<int>(
      0,
      (sum, module) => sum + module.lessons.length,
    );
  }
}

class ProgressState {
  const ProgressState({
    required this.isLoading,
    required this.overallProgress,
    required this.completedLessons,
    required this.totalLessons,
    required this.lessonCompletion,
    required this.learningStreak,
    required this.timeSpentMinutes,
  });

  const ProgressState.initial()
      : isLoading = false,
        overallProgress = 0,
        completedLessons = 0,
        totalLessons = 0,
        lessonCompletion = const {},
        learningStreak = 0,
        timeSpentMinutes = 0;

  final bool isLoading;
  final double overallProgress;
  final int completedLessons;
  final int totalLessons;
  final Map<String, bool> lessonCompletion;
  final int learningStreak;
  final int timeSpentMinutes;

  bool isLessonCompleted(String lessonId) =>
      lessonCompletion[lessonId] == true;

  ProgressState copyWith({
    bool? isLoading,
    double? overallProgress,
    int? completedLessons,
    int? totalLessons,
    Map<String, bool>? lessonCompletion,
    int? learningStreak,
    int? timeSpentMinutes,
  }) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      overallProgress: overallProgress ?? this.overallProgress,
      completedLessons: completedLessons ?? this.completedLessons,
      totalLessons: totalLessons ?? this.totalLessons,
      lessonCompletion: lessonCompletion ?? this.lessonCompletion,
      learningStreak: learningStreak ?? this.learningStreak,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
    );
  }
}
