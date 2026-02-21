import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationListResponse> getNotifications({int page = 1});
  Future<NotificationEntity> getNotificationById(String notificationId);
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markAllNotificationsAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final AuthenticatedApiClient _apiClient;

  NotificationRemoteDataSourceImpl({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<NotificationListResponse> getNotifications({int page = 1}) async {
    try {
      print('API Client: Making GET request to /api/notifications');
      print('API Client: Query parameters: {page: $page}');

      final response = await _apiClient.get(
        '/api/notifications',
        queryParameters: {'page': page},
      );

      print('API Client: Response type: ${response.runtimeType}');
      print('API Client: Response data: $response');

      return NotificationListResponse.fromJson(response);
    } catch (e) {
      print('API Client: Error fetching notifications: $e');
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  @override
  Future<NotificationEntity> getNotificationById(String notificationId) async {
    try {
      print(
        'API Client: Making GET request to /api/notifications/$notificationId',
      );
      final response = await _apiClient.get(
        '/api/notifications/$notificationId',
      );
      print('API Client: Response type: ${response.runtimeType}');
      print('API Client: Response data: $response');

      // Check if response is a Map
      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>, got ${response.runtimeType}',
        );
      }

      return NotificationEntity.fromJson(response);
    } catch (e) {
      print('API Client: Error fetching notification details: $e');
      throw Exception('Failed to fetch notification details: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      print(
        'API Client: Making PUT request to /api/notifications/$notificationId',
      );
      await _apiClient.put(
        '/api/notifications/$notificationId',
        data: {'read': true},
      );
      print('API Client: Notification marked as read successfully');
    } catch (e) {
      print('API Client: Error marking notification as read: $e');
      // Don't throw exception - just log the error since this might not be supported by the API
      print('API Client: This endpoint might not be supported by the API');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      print('API Client: Making PUT request to /api/notifications/markAsRead');
      await _apiClient.put('/api/notifications/markAsRead');
      print('API Client: All notifications marked as read successfully');
    } catch (e) {
      print('API Client: Error marking all notifications as read: $e');
      // Don't throw exception - just log the error since this might not be supported by the API
      print('API Client: This endpoint might not be supported by the API');
    }
  }
}
