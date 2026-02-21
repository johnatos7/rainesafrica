import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/providers/notification_use_case_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';

class NotificationBackgroundService {
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  NotificationBackgroundService({
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
  }) : _markNotificationAsReadUseCase = markNotificationAsReadUseCase;

  /// Mark a notification as read in the background
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _markNotificationAsReadUseCase(
        MarkNotificationAsReadParams(notificationId: notificationId),
      );
    } catch (e) {
      // Handle error silently - this is a background operation
      // The API might not support marking notifications as read
      print('Background service: Failed to mark notification as read: $e');
      print(
        'Background service: This might be because the API doesn\'t support this endpoint',
      );
    }
  }

  /// Mark all notifications as read in the background
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _markNotificationAsReadUseCase(
        MarkNotificationAsReadParams(notificationId: 'all'),
      );
    } catch (e) {
      // Handle error silently - this is a background operation
      // The API might not support marking all notifications as read
      print('Background service: Failed to mark all notifications as read: $e');
      print(
        'Background service: This might be because the API doesn\'t support this endpoint',
      );
    }
  }
}

// Provider for the background service
final notificationBackgroundServiceProvider =
    Provider<NotificationBackgroundService>((ref) {
      final markNotificationAsReadUseCase = ref.watch(
        markNotificationAsReadUseCaseProvider,
      );
      return NotificationBackgroundService(
        markNotificationAsReadUseCase: markNotificationAsReadUseCase,
      );
    });
