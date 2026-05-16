import '../../core/constants/backend_enum_values.dart';

class Enrollment {
  const Enrollment({
    required this.id,
    required this.learnerId,
    required this.courseId,
    required this.status,
    this.enrolledAt,
  });

  final String id;
  final String learnerId;
  final String courseId;
  final int status;
  final DateTime? enrolledAt;

  bool get isActive => status == BackendEnumValues.enrollmentActive;
}
