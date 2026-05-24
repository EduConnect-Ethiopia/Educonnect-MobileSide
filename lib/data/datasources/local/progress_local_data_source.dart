import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProgressLocalDataSource {
  ProgressLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static String _completionKey(String courseId, String enrollmentId) =>
      'progress_${courseId}_$enrollmentId';

  static String _videoPositionKey(String lessonId) =>
      'video_position_$lessonId';

  static const _streakKey = 'learning_streak';
  static const _timeSpentPrefix = 'time_spent_';

  Future<Map<String, bool>> getLessonCompletion(
    String courseId,
    String enrollmentId,
  ) async {
    final raw = _prefs.getString(_completionKey(courseId, enrollmentId));
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v == true));
  }

  Future<void> setLessonComplete(
    String courseId,
    String enrollmentId,
    String lessonId,
  ) async {
    final current = await getLessonCompletion(courseId, enrollmentId);
    current[lessonId] = true;
    await _prefs.setString(
      _completionKey(courseId, enrollmentId),
      jsonEncode(current),
    );
  }

  Future<int> getVideoPosition(String lessonId) async {
    return _prefs.getInt(_videoPositionKey(lessonId)) ?? 0;
  }

  Future<void> saveVideoPosition(String lessonId, int seconds) async {
    await _prefs.setInt(_videoPositionKey(lessonId), seconds);
  }

  Future<int> getLearningStreak() async {
    return _prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> incrementStreak() async {
    final current = await getLearningStreak();
    await _prefs.setInt(_streakKey, current + 1);
  }

  Future<int> getTimeSpentMinutes(String courseId) async {
    return _prefs.getInt('$_timeSpentPrefix$courseId') ?? 0;
  }

  Future<void> addTimeSpent(String courseId, int minutes) async {
    final current = await getTimeSpentMinutes(courseId);
    await _prefs.setInt('$_timeSpentPrefix$courseId', current + minutes);
  }
}
