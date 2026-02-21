import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';

class OrderDetailsTimeline extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              title: 'Order Placed',
              description: 'Your order has been placed successfully',
              date: order.createdAt,
              isActive: true,
              isFirst: true,
              colors: colors,
            ),
            if (order.statusHistories.isNotEmpty) ...[
              ...order.statusHistories.map((statusHistory) {
                return _buildTimelineItem(
                  title: _getStatusTitle(statusHistory.status),
                  description: _getStatusDescription(statusHistory.status),
                  date: statusHistory.createdAt,
                  isActive: true,
                  isFirst: false,
                  colors: colors,
                );
              }),
            ] else ...[
              _buildTimelineItem(
                title: 'Processing',
                description: 'Your order is being processed',
                date: null,
                isActive: false,
                isFirst: false,
                colors: colors,
              ),
              _buildTimelineItem(
                title: 'Shipped',
                description: 'Your order has been shipped',
                date: null,
                isActive: false,
                isFirst: false,
                colors: colors,
              ),
              _buildTimelineItem(
                title: 'Delivered',
                description: 'Your order has been delivered',
                date: null,
                isActive: false,
                isFirst: false,
                isLast: true,
                colors: colors,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String description,
    required DateTime? date,
    required bool isActive,
    required bool isFirst,
    required ColorScheme colors,
    bool isLast = false,
  }) {
    final activeColor = colors.primary;
    final inactiveColor = colors.outline.withOpacity(0.3);
    final activeTextColor = colors.onSurface;
    final inactiveTextColor = colors.onSurface.withOpacity(0.5);
    final inactiveDescriptionColor = colors.onSurface.withOpacity(0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isActive ? activeColor : inactiveColor,
              ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? activeColor : inactiveColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 20,
                color: isActive ? activeColor : inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? activeTextColor : inactiveTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isActive ? inactiveTextColor : inactiveDescriptionColor,
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: TextStyle(fontSize: 12, color: inactiveTextColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Your order is being prepared';
      case 'shipped':
        return 'Your order is on its way';
      case 'delivered':
        return 'Your order has been delivered';
      case 'cancelled':
        return 'Your order has been cancelled';
      default:
        return 'Order status updated';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
