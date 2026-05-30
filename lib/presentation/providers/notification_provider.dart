import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/app_notification.dart';

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    Future.microtask(loadNotifications);
    return NotificationState.initial();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final items =
          await ref.read(notificationRepositoryProvider).getNotifications();
      state = state.copyWith(isLoading: false, notifications: items);
    } on Object {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
    state = state.copyWith(
      notifications: state.notifications
          .map(
            (n) => n.id == id
                ? AppNotification(
                    id: n.id,
                    title: n.title,
                    body: n.body,
                    type: n.type,
                    isRead: true,
                    createdAt: n.createdAt,
                    deepLink: n.deepLink,
                  )
                : n,
          )
          .toList(),
    );
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    state = state.copyWith(
      notifications: state.notifications
          .map(
            (n) => AppNotification(
              id: n.id,
              title: n.title,
              body: n.body,
              type: n.type,
              isRead: true,
              createdAt: n.createdAt,
              deepLink: n.deepLink,
            ),
          )
          .toList(),
    );
  }
}

class NotificationState {
  const NotificationState({
    required this.notifications,
    required this.isLoading,
  });

  const NotificationState.initial()
      : notifications = const [],
        isLoading = false;

  final List<AppNotification> notifications;
  final bool isLoading;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
