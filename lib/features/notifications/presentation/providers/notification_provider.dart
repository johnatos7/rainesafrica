import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/providers/notification_use_case_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/get_notifications_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/get_notification_by_id_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';

// Notification list state
class NotificationListState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final bool hasMoreData;

  const NotificationListState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMoreData = true,
  });

  NotificationListState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    bool? hasMoreData,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
    );
  }
}

class NotificationListNotifier extends StateNotifier<NotificationListState> {
  final GetNotificationsUseCase _getNotificationsUseCase;

  NotificationListNotifier({
    required GetNotificationsUseCase getNotificationsUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       super(const NotificationListState());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 1,
        notifications: [],
        hasMoreData: true,
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final result = await _getNotificationsUseCase(
        GetNotificationsParams(page: refresh ? 1 : state.currentPage),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (response) {
          final newNotifications =
              refresh
                  ? response.data
                  : [...state.notifications, ...response.data];

          state = state.copyWith(
            isLoading: false,
            notifications: newNotifications,
            currentPage: response.currentPage,
            hasMoreData: response.nextPageUrl != null,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notifications: $e',
      );
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state.isLoadingMore || !state.hasMoreData) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _getNotificationsUseCase(
        GetNotificationsParams(page: state.currentPage + 1),
      );

      result.fold(
        (failure) {
          state = state.copyWith(isLoadingMore: false);
        },
        (response) {
          state = state.copyWith(
            isLoadingMore: false,
            notifications: [...state.notifications, ...response.data],
            currentPage: response.currentPage,
            hasMoreData: response.nextPageUrl != null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void markNotificationAsRead(String notificationId) {
    final updatedNotifications =
        state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(readAt: DateTime.now());
          }
          return notification;
        }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void markAllNotificationsAsRead() {
    final updatedNotifications =
        state.notifications.map((notification) {
          return notification.copyWith(readAt: DateTime.now());
        }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }
}

// Notification details state
class NotificationDetailsState {
  final NotificationEntity? notification;
  final bool isLoading;
  final String? errorMessage;

  const NotificationDetailsState({
    this.notification,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationDetailsState copyWith({
    NotificationEntity? notification,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationDetailsState(
      notification: notification ?? this.notification,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NotificationDetailsNotifier
    extends StateNotifier<NotificationDetailsState> {
  final GetNotificationByIdUseCase _getNotificationByIdUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  NotificationDetailsNotifier({
    required GetNotificationByIdUseCase getNotificationByIdUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
  }) : _getNotificationByIdUseCase = getNotificationByIdUseCase,
       _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
       super(const NotificationDetailsState());

  Future<void> loadNotificationDetails(String notificationId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getNotificationByIdUseCase(
        GetNotificationByIdParams(notificationId: notificationId),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (notification) {
          state = state.copyWith(
            isLoading: false,
            notification: notification,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notification details: $e',
      );
    }
  }

  void setNotification(NotificationEntity notification) {
    state = state.copyWith(
      isLoading: false,
      notification: notification,
      errorMessage: null,
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final result = await _markNotificationAsReadUseCase(
        MarkNotificationAsReadParams(notificationId: notificationId),
      );

      result.fold(
        (failure) {
          // Handle error silently or show a snackbar
        },
        (_) {
          // Update the notification in state
          if (state.notification?.id == notificationId) {
            state = state.copyWith(
              notification: state.notification!.copyWith(
                readAt: DateTime.now(),
              ),
            );
          }
        },
      );
    } catch (e) {
      // Handle error silently
    }
  }
}

// Providers
final notificationListProvider = StateNotifierProvider<
  NotificationListNotifier,
  NotificationListState
>((ref) {
  final getNotificationsUseCase = ref.watch(getNotificationsUseCaseProvider);
  return NotificationListNotifier(
    getNotificationsUseCase: getNotificationsUseCase,
  );
});

final notificationDetailsProvider = StateNotifierProvider<
  NotificationDetailsNotifier,
  NotificationDetailsState
>((ref) {
  final getNotificationByIdUseCase = ref.watch(
    getNotificationByIdUseCaseProvider,
  );
  final markNotificationAsReadUseCase = ref.watch(
    markNotificationAsReadUseCaseProvider,
  );
  return NotificationDetailsNotifier(
    getNotificationByIdUseCase: getNotificationByIdUseCase,
    markNotificationAsReadUseCase: markNotificationAsReadUseCase,
  );
});
