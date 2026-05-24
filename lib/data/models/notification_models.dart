import '../../core/utils/json_map.dart';
import '../../domain/entities/app_notification.dart';

class NotificationDto {
  const NotificationDto({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String notificationId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return NotificationDto(
      notificationId:
          findString(data, const ['notificationId', 'id']) ?? '',
      title: findString(data, const ['title']) ?? 'Notification',
      message: findString(data, const ['message', 'body']) ?? '',
      type: findString(data, const ['type']) ?? 'General',
      isRead: data['isRead'] == true,
      createdAt: parseDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: notificationId,
      title: title,
      body: message,
      type: _mapType(type),
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  static NotificationType _mapType(String raw) {
    switch (raw.toLowerCase()) {
      case 'enrollment':
        return NotificationType.enrollment;
      case 'sessionscheduled':
        return NotificationType.session;
      case 'assessmentgraded':
        return NotificationType.assessment;
      case 'certificateissued':
        return NotificationType.certificate;
      default:
        return NotificationType.general;
    }
  }
}
