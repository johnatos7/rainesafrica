import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNotificationIcon(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.data.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        notification.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w600,
                                    color:
                                        notification.isRead
                                            ? theme.colorScheme.onSurface
                                                .withOpacity(0.6)
                                            : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.data.message,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  notification.isRead
                                      ? theme.colorScheme.onSurface.withOpacity(
                                        0.5,
                                      )
                                      : theme.colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTypeChip(),
                              const Spacer(),
                              Text(
                                _formatDate(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(iconData, size: 20, color: iconColor),
    );
  }

  Widget _buildTypeChip() {
    Color chipColor;
    String chipText;

    switch (notification.data.type) {
      case 'order':
        chipColor = Colors.blue;
        chipText = 'Order';
        break;
      case 'points':
        chipColor = Colors.amber;
        chipText = 'Points';
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        chipText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
