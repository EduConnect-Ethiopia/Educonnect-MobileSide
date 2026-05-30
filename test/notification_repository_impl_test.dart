import 'package:flutter_test/flutter_test.dart';

import 'package:educonnect_mobile/data/datasources/remote/notification_remote_data_source.dart';
import 'package:educonnect_mobile/data/models/notification_models.dart';
import 'package:educonnect_mobile/data/repositories/notification_repository_impl.dart';
import 'package:educonnect_mobile/domain/entities/app_notification.dart';

class _FakeRemote implements NotificationRemoteDataSource {
  List<NotificationDto> dtos = [];
  final List<String> marked = [];
  bool markAllCalled = false;

  @override
  Future<List<NotificationDto>> getNotifications() async => dtos;

  @override
  Future<void> markAsRead(String notificationId) async {
    marked.add(notificationId);
  }

  @override
  Future<void> markAllRead() async {
    markAllCalled = true;
  }
}

void main() {
  test('maps dtos to AppNotification and sorts by createdAt desc', () async {
    final remote = _FakeRemote();
    remote.dtos = [
      NotificationDto(
        notificationId: 'n1',
        title: 'First',
        message: 'Hello',
        type: 'General',
        isRead: false,
        createdAt: DateTime.parse('2024-01-02'),
      ),
      NotificationDto(
        notificationId: 'n2',
        title: 'Second',
        message: 'World',
        type: 'certificateissued',
        isRead: true,
        createdAt: DateTime.parse('2024-01-03'),
      ),
    ];

    final repo = NotificationRepositoryImpl(remote);
    final items = await repo.getNotifications();
    expect(items.length, 2);
    expect(items.first.id, 'n2'); // newer first
    expect(items.first.type, NotificationType.certificate);
  });

  test('markAsRead calls remote', () async {
    final remote = _FakeRemote();
    final repo = NotificationRepositoryImpl(remote);
    await repo.markAsRead('n-x');
    expect(remote.marked, ['n-x']);
  });

  test('markAllRead calls remote', () async {
    final remote = _FakeRemote();
    final repo = NotificationRepositoryImpl(remote);
    await repo.markAllRead();
    expect(remote.markAllCalled, true);
  });
}
