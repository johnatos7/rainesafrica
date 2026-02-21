import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/providers/notification_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/get_notification_by_id_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/mark_all_notifications_as_read_use_case.dart';

// Use case providers
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  final repository = ref.watch(notificationRepositoryProvider);
  return GetNotificationsUseCase(repository: repository);
});

final getNotificationByIdUseCaseProvider = Provider<GetNotificationByIdUseCase>(
  (ref) {
    final repository = ref.watch(notificationRepositoryProvider);
    return GetNotificationByIdUseCase(repository: repository);
  },
);

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return MarkNotificationAsReadUseCase(repository: repository);
    });

final markAllNotificationsAsReadUseCaseProvider =
    Provider<MarkAllNotificationsAsReadUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return MarkAllNotificationsAsReadUseCase(repository: repository);
    });
