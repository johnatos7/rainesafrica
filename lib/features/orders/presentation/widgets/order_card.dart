import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildOrderInfo(context),
                const SizedBox(height: 12),
                _buildStatusAndAmount(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order #${order.orderNumber}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface.withOpacity(0.8),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(
              order.orderStatus.name,
              colors,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            order.orderStatus.name.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(order.orderStatus.name, colors),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: colors.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDate(order.createdAt),
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.payment,
              size: 16,
              color: colors.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              '${order.paymentMethod.toUpperCase().replaceAll('COD', 'Office Payment').replaceAll('BANK_TRANSFER', 'Bank Transfer').replaceAll('BANK', 'Bank Transfer').replaceAll('PDO_ZAMBIA', 'DPO Zambia').replaceAll('PAYFAST', 'Payfast').replaceAll('PESE', 'PesePay').replaceAll('OFFICE_PAYMENT', 'Office Payment')} • ${order.paymentStatus}',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        if (order.deliveryDescription.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.local_shipping,
                size: 16,
                color: colors.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusAndAmount(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.currencySymbol}${((order.summary?.finalTotal ?? 0) * order.exchangeRate).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'View Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'pending':
        return colors.secondary;
      case 'processing':
        return colors.primary;
      case 'shipped':
        return colors.tertiary;
      case 'out for delivery':
        return colors.tertiary;
      case 'delivered':
        return colors.primary.withGreen(200); // Green-like color
      case 'ready for collection':
        return colors.tertiary;
      case 'collected':
        return colors.primary.withGreen(200); // Green-like color
      case 'cancelled':
        return colors.error;
      default:
        return colors.onSurface.withOpacity(0.6);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
