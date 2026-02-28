import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/presentation/screens/repayment_screen.dart';

class OrderDetailsHeader extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsHeader({super.key, required this.order});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      order.orderStatus.name,
                      colors,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getStatusColor(
                        order.orderStatus.name,
                        colors,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    order.orderStatus.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.orderStatus.name, colors),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: 'Order Date',
                    value: _formatDate(order.createdAt),
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.payment,
                    label: 'Payment',
                    value:
                        '${order.paymentMethod.toUpperCase().replaceAll('COD', 'Office Payment').replaceAll('BANK_TRANSFER', 'Bank Transfer').replaceAll('BANK', 'Bank Transfer').replaceAll('PDO_ZAMBIA', 'DPO Zambia').replaceAll('PAYFAST', 'Payfast').replaceAll('PESE', 'PesePay').replaceAll('OFFICE_PAYMENT', 'Office Payment')} • ${order.paymentStatus}',
                    colors: colors,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.person,
                    label: 'Customer',
                    value: order.consumer.name,
                    colors: colors,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: order.consumer.email,
                    colors: colors,
                  ),
                ),
              ],
            ),
            if (_shouldShowRepaymentButton(order)) ...[
              const SizedBox(height: 16),
              _buildRepaymentButton(context, colors),
            ],
            if (_shouldShowQrCodeButton(order)) ...[
              const SizedBox(height: 16),
              _buildQrCodeButton(context, colors),
            ],
          ],
        ),
      ),
    );
  }

  bool _shouldShowRepaymentButton(OrderEntity order) {
    final status = order.orderStatus.name.toLowerCase();
    final paymentStatus = order.paymentStatus.toLowerCase();

    // Show repayment button for failed or pending orders
    return (status == 'failed' || status == 'pending') &&
        (paymentStatus == 'failed' || paymentStatus == 'pending');
  }

  Widget _buildRepaymentButton(BuildContext context, ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToRepayment(context),
        icon: const Icon(Icons.payment, size: 20),
        label: const Text('Retry Payment'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _navigateToRepayment(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RepaymentScreen(order: order)),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colors.onSurface.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        return colors.tertiary ?? colors.primaryContainer;
      case 'out for delivery':
        return colors.tertiary ?? const Color(0xFF13C2C2);
      case 'delivered':
        return Color.lerp(colors.primary, Colors.green, 0.7) ??
            const Color(0xFF52C41A);
      case 'ready for collection':
        return colors.tertiary ?? colors.primaryContainer;
      case 'collected':
        return Color.lerp(colors.primary, Colors.green, 0.7) ??
            const Color(0xFF52C41A);
      case 'cancelled':
        return colors.error;
      default:
        return colors.onSurface.withOpacity(0.6);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _shouldShowQrCodeButton(OrderEntity order) {
    final slug = order.orderStatus.slug.toLowerCase();
    final name = order.orderStatus.name.toLowerCase();
    final isReadyForCollection =
        slug == 'ready-for-collection' || name == 'ready for collection';
    return isReadyForCollection &&
        order.qrCodeUrl != null &&
        order.qrCodeUrl!.trim().isNotEmpty;
  }

  Widget _buildQrCodeButton(BuildContext context, ColorScheme colors) {
    final color = colors.primary;
    return InkWell(
      onTap: () => _showQrCodeDialog(context, colors),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              'QR CODE',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context, ColorScheme colors) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Scan QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Scan this QR code at the Pickup Point when collecting your order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // QR Code Image
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      order.qrCodeUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: const Color(0xFF4CAF50),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load QR code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Order number fallback
                Text(
                  'ALTERNATIVELY, USE THIS ORDER NUMBER:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4CAF50),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
