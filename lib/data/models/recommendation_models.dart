import '../../core/utils/json_map.dart';
import '../../domain/entities/course.dart';

class RecommendedCourseDto {
  const RecommendedCourseDto({
    required this.courseId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.mode,
    required this.reason,
  });

  final String courseId;
  final String title;
  final String description;
  final String category;
  final double price;
  final String mode;
  final String reason;

  factory RecommendedCourseDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return RecommendedCourseDto(
      courseId: findString(data, const ['courseId', 'id']) ?? '',
      title: findString(data, const ['title']) ?? 'Course',
      description: findString(data, const ['description']) ?? '',
      category: findString(data, const ['category']) ?? 'General',
      price: _readDouble(data['price']) ?? 0,
      mode: findString(data, const ['mode']) ?? '',
      reason: findString(data, const ['reasonForRecommendation', 'reason']) ??
          '',
    );
  }

  Course toEntity() {
    return Course(
      id: courseId,
      title: title,
      description: description,
      category: category,
      mode: 0,
      status: 1,
      price: price,
      instructor: reason.isNotEmpty ? reason : 'EduConnect',
    );
  }
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
