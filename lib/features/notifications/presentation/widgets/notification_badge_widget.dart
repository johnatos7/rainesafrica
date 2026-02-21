import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/providers/notification_provider.dart';

class NotificationBadgeWidget extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NotificationBadgeWidget({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationListProvider);

    // Count unread notifications
    final unreadCount =
        notificationState.notifications
            .where((notification) => !notification.isRead)
            .length;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          child,
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
