import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<List<AppNotification>> getNotifications() async {
    final dtos = await _remote.getNotifications();
    return dtos.map((dto) => dto.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _remote.markAsRead(notificationId);
  }

  @override
  Future<void> markAllRead() => _remote.markAllRead();
}
