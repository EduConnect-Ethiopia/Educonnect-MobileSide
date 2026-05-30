import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/app_notification.dart';
import '../../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all read',
            onPressed: state.notifications.isEmpty
                ? null
                : () => ref
                    .read(notificationControllerProvider.notifier)
                    .markAllRead(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(notificationControllerProvider.notifier)
            .loadNotifications(),
        child: _buildBody(context, ref, state),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    NotificationState state,
  ) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notifications.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No notifications yet')),
        ],
      );
    }

    return ListView.builder(
      itemCount: state.notifications.length,
      itemBuilder: (context, index) {
        final notification = state.notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () async {
            ref
                .read(notificationControllerProvider.notifier)
                .markAsRead(notification.id);
            if (notification.deepLink != null && notification.deepLink!.isNotEmpty) {
              final uri = Uri.tryParse(notification.deepLink!);
              if (uri != null) {
                // In a real app, this would use a deep link router like go_router.
                // For now, if we can launch it (e.g. external browser), we launch it,
                // or we show a snackbar saying we would navigate.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Navigating to: ${notification.deepLink}')),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_iconForType(notification.type), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.enrollment:
        return Icons.school_outlined;
      case NotificationType.session:
        return Icons.video_call_outlined;
      case NotificationType.assessment:
        return Icons.quiz_outlined;
      case NotificationType.certificate:
        return Icons.workspace_premium_outlined;
      case NotificationType.general:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
