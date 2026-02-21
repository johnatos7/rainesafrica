import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';

class NotificationDetailsContent extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationDetailsContent({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          _buildSectionTitle(context, 'Message'),
          const SizedBox(height: 12),
          _buildMessageContent(context),
          // const SizedBox(height: 24),
          // _buildSectionTitle(context, 'Details'),
          //    const SizedBox(height: 12),
          //  _buildDetailsList(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        notification.data.message,
        style: TextStyle(
          fontSize: 15,
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildDetailsList(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          'Type',
          _getTypeDisplayName(notification.data.type),
        ),
        _buildDetailRow(context, 'Notification ID', notification.id),
        _buildDetailRow(
          context,
          'Created',
          _formatFullDate(notification.createdAt),
        ),
        if (notification.readAt != null)
          _buildDetailRow(
            context,
            'Read',
            _formatFullDate(notification.readAt!),
          ),
        _buildDetailRow(
          context,
          'Status',
          notification.isRead ? 'Read' : 'Unread',
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'order':
        return 'Order Update';
      case 'points':
        return 'Points & Rewards';
      case 'promotion':
        return 'Promotion';
      default:
        return 'General';
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
