class CourseProgress {
  const CourseProgress({
    required this.percentage,
    required this.completedCount,
    required this.totalCount,
    required this.lessonCompletion,
    this.timeSpentMinutes = 0,
    this.learningStreak = 0,
  });

  final double percentage;
  final int completedCount;
  final int totalCount;
  final Map<String, bool> lessonCompletion;
  final int timeSpentMinutes;
  final int learningStreak;
}
