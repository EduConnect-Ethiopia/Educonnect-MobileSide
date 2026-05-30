import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';
import '../../models/notification_models.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationDto>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllRead();
}

class DioNotificationRemoteDataSource implements NotificationRemoteDataSource {
  const DioNotificationRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<NotificationDto>> getNotifications() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.notifications);
    final list = _unwrapList(response.data);
    return list
        .map((json) => NotificationDto.fromJson(castJsonMap(json)))
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _dio.put<void>(ApiEndpoints.notificationRead(notificationId));
  }

  @override
  Future<void> markAllRead() async {
    await _dio.put<void>(ApiEndpoints.notificationsReadAll);
  }

  List<Map<String, dynamic>> _unwrapList(Object? value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map) {
      final map = castJsonMap(value);
      final data = map['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
