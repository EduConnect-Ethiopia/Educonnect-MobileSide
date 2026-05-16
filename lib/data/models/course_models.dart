import '../../core/constants/backend_enum_values.dart';
import '../../core/utils/json_map.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/enrollment.dart';

class CourseModel {
  const CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.category,
    required this.mode,
    required this.price,
    required this.courseStatus,
    this.createdAt,
    this.updatedAt,
  });

  final String courseId;
  final String title;
  final String description;
  final String category;
  final int mode;
  final double price;
  final int courseStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CourseModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;

    return CourseModel(
      courseId: findString(data, const ['courseId', 'id']) ?? '',
      title: findString(data, const ['title']) ?? 'Untitled course',
      description: findString(data, const ['description']) ?? '',
      category: findString(data, const ['category']) ?? 'General',
      mode: _readInt(data['mode']) ?? BackendEnumValues.modeSelfPaced,
      price: _readDouble(data['price']) ?? 0,
      courseStatus:
          _readInt(data['courseStatus']) ?? BackendEnumValues.courseStatusDraft,
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: _parseBackendDate(data['updatedAt']),
    );
  }

  Course toEntity({double progress = 0, DateTime? enrolledAt}) {
    return Course(
      id: courseId,
      title: title,
      description: description,
      category: category,
      mode: mode,
      status: courseStatus,
      price: price,
      instructor: 'EduConnect Instructor',
      progress: progress,
      enrolledAt: enrolledAt,
    );
  }
}

class EnrollmentModel {
  const EnrollmentModel({
    required this.enrollmentId,
    required this.learnerId,
    required this.courseId,
    required this.enrollmentStatus,
    this.enrolledAt,
  });

  final String enrollmentId;
  final String learnerId;
  final String courseId;
  final int enrollmentStatus;
  final DateTime? enrolledAt;

  factory EnrollmentModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;

    return EnrollmentModel(
      enrollmentId: findString(data, const ['enrollmentId', 'id']) ?? '',
      learnerId: findString(data, const ['learnerId', 'userId']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      enrollmentStatus:
          _readInt(data['enrollmentStatus']) ??
          BackendEnumValues.enrollmentDropped,
      enrolledAt: parseDateTime(data['enrolledAt']),
    );
  }

  Enrollment toEntity() {
    return Enrollment(
      id: enrollmentId,
      learnerId: learnerId,
      courseId: courseId,
      status: enrollmentStatus,
      enrolledAt: enrolledAt,
    );
  }
}

DateTime? _parseBackendDate(Object? value) {
  final parsed = parseDateTime(value);
  if (parsed == null || parsed.year <= 1) {
    return null;
  }

  return parsed;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value);
  }

  return null;
}

double? _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value);
  }

  return null;
}
