import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';

class NotificationDetailsHeader extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationDetailsHeader({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildNotificationIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.data.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTypeChip(),
                  ],
                ),
              ),
              _buildStatusIndicator(context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (notification.isRead) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Read',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.data.type) {
      case 'order':
        iconData = Icons.shopping_bag;
        iconColor = Colors.blue;
        break;
      case 'points':
        iconData = Icons.stars;
        iconColor = Colors.amber;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Icon(iconData, size: 24, color: iconColor),
    );
  }

  Widget _buildTypeChip() {
    Color chipColor;
    String chipText;

    switch (notification.data.type) {
      case 'order':
        chipColor = Colors.blue;
        chipText = 'Order Update';
        break;
      case 'points':
        chipColor = Colors.amber;
        chipText = 'Points & Rewards';
        break;
      case 'promotion':
        chipColor = Colors.green;
        chipText = 'Promotion';
        break;
      default:
        chipColor = Colors.grey;
        chipText = 'General';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            notification.isRead
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        notification.isRead ? 'Read' : 'New',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color:
              notification.isRead
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
