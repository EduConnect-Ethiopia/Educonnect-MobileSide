import '../../core/utils/json_map.dart';
import '../../domain/entities/course_session.dart';

class CourseSessionModel {
  const CourseSessionModel({
    required this.sessionId,
    required this.courseId,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.meetingUrl,
    this.status = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String sessionId;
  final String courseId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingUrl;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CourseSessionModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;

    return CourseSessionModel(
      sessionId: findString(data, const ['sessionId', 'id']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      title: findString(data, const ['title']) ?? 'Session',
      startTime: parseDateTime(data['startTime']) ?? DateTime.now(),
      endTime: parseDateTime(data['endTime']) ?? DateTime.now().add(const Duration(hours: 1)),
      meetingUrl: findString(data, const ['meetingUrl', 'url']) ?? '',
      status: _readSessionStatus(data['status']) ?? 0,
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: parseDateTime(data['updatedAt']),
    );
  }

  CourseSession toEntity() {
    return CourseSession(
      id: sessionId,
      courseId: courseId,
      title: title,
      startTime: startTime,
      endTime: endTime,
      meetingUrl: meetingUrl,
      status: status,
    );
  }
}

int? _readSessionStatus(Object? value) {
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('cancel')) return 3;
    if (normalized.contains('complete') || normalized.contains('done')) return 2;
    if (normalized.contains('live') || normalized.contains('inprogress') || normalized.contains('ongoing')) return 1;
  }
  return _readInt(value);
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
