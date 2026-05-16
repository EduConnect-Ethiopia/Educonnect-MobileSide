import '../../core/constants/backend_enum_values.dart';

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.mode,
    required this.status,
    required this.price,
    required this.instructor,
    this.thumbnailUrl,
    this.progress = 0,
    this.enrolledAt,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int mode;
  final int status;
  final double price;
  final String instructor;
  final String? thumbnailUrl;
  final double progress;
  final DateTime? enrolledAt;

  bool get isFree => price <= 0;

  bool get isPublished => status == BackendEnumValues.courseStatusPublished;

  bool get isInstructorLed => mode == BackendEnumValues.modeInstructorLed;

  Course copyWith({double? progress, DateTime? enrolledAt}) {
    return Course(
      id: id,
      title: title,
      description: description,
      category: category,
      mode: mode,
      status: status,
      price: price,
      instructor: instructor,
      thumbnailUrl: thumbnailUrl,
      progress: progress ?? this.progress,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }
}
