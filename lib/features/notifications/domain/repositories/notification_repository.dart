import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<NotificationListResponse> getNotifications({int page = 1});
  Future<NotificationEntity> getNotificationById(String notificationId);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead();
}
