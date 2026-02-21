import 'package:flutter_riverpod_clean_architecture/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl({
    required NotificationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<NotificationListResponse> getNotifications({int page = 1}) async {
    return await _remoteDataSource.getNotifications(page: page);
  }

  @override
  Future<NotificationEntity> getNotificationById(String notificationId) async {
    return await _remoteDataSource.getNotificationById(notificationId);
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    return await _remoteDataSource.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    return await _remoteDataSource.markAllNotificationsAsRead();
  }
}
