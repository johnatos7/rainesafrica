import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/providers/notification_provider.dart';

class NotificationIconWidget extends ConsumerWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double? iconSize;
  final bool showBadge;

  const NotificationIconWidget({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.iconSize,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationListProvider);

    // Count unread notifications
    final unreadCount =
        notificationState.notifications
            .where((notification) => notification.readAt == null)
            .length;

    return GestureDetector(
      onTap: () => context.push(AppConstants.notificationsRoute),
      child: Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            color: Theme.of(context).colorScheme.onSurface,
            size: iconSize ?? 24,
          ),
          if (showBadge && unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationIconButton extends ConsumerWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double? iconSize;
  final bool showBadge;

  const NotificationIconButton({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.iconSize,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationListProvider);

    // Count unread notifications
    final unreadCount =
        notificationState.notifications
            .where((notification) => notification.readAt == null)
            .length;

    return IconButton(
      onPressed: () => context.push(AppConstants.notificationsRoute),
      icon: Stack(
        children: [
          Icon(
            Icons.notifications_outlined,
            color:Theme.of(context).colorScheme.onSurface,
            size: iconSize ?? 24,
          ),
          if (showBadge && unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: badgeColor ?? Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
