import '../../core/utils/json_map.dart';
import '../../domain/entities/course_progress.dart';

class CourseProgressDto {
  const CourseProgressDto({
    required this.courseId,
    required this.totalLessons,
    required this.completedLessons,
    required this.percentageComplete,
    required this.lessons,
  });

  final String courseId;
  final int totalLessons;
  final int completedLessons;
  final double percentageComplete;
  final List<LessonProgressDto> lessons;

  factory CourseProgressDto.fromJson(JsonMap json) {
    final lessonsRaw = json['lessons'];
    final lessons = lessonsRaw is List
        ? lessonsRaw
            .whereType<Map>()
            .map((e) => LessonProgressDto.fromJson(castJsonMap(e)))
            .toList()
        : <LessonProgressDto>[];

    return CourseProgressDto(
      courseId: findString(json, const ['courseId']) ?? '',
      totalLessons: _readInt(json['totalLessons']) ?? 0,
      completedLessons: _readInt(json['completedLessons']) ?? 0,
      percentageComplete: _readDouble(json['percentageComplete']) ?? 0,
      lessons: lessons,
    );
  }

  CourseProgress toEntity() {
    final completion = {
      for (final lesson in lessons) lesson.lessonId: lesson.isCompleted,
    };
    return CourseProgress(
      percentage: percentageComplete,
      completedCount: completedLessons,
      totalCount: totalLessons,
      lessonCompletion: completion,
      timeSpentMinutes: 0,
      learningStreak: 0,
    );
  }
}

class LessonProgressDto {
  const LessonProgressDto({
    required this.lessonId,
    required this.isCompleted,
  });

  final String lessonId;
  final bool isCompleted;

  factory LessonProgressDto.fromJson(JsonMap json) {
    return LessonProgressDto(
      lessonId: findString(json, const ['lessonId']) ?? '',
      isCompleted: json['isCompleted'] == true,
    );
  }
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
