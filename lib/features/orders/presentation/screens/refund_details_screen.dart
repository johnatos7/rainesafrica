import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_list_entity.dart';
import 'package:intl/intl.dart';

class RefundDetailsScreen extends StatelessWidget {
  final RefundListItemEntity refund;

  const RefundDetailsScreen({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Refund Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(colors, theme),
            const SizedBox(height: 16),

            // Refund Information
            _buildSectionCard(
              'Refund Information',
              [
                _buildDetailRow('Refund ID', '#${refund.id}', colors, theme),
                _buildDetailRow(
                  'Order ID',
                  '#${refund.orderId}',
                  colors,
                  theme,
                ),
                _buildDetailRow(
                  'Product ID',
                  '#${refund.productId}',
                  colors,
                  theme,
                ),
                _buildDetailRow(
                  'Amount',
                  '\$${refund.amount.toStringAsFixed(2)}',
                  colors,
                  theme,
                  isHighlighted: true,
                ),
                _buildDetailRow(
                  'Payment Type',
                  refund.paymentType.toUpperCase(),
                  colors,
                  theme,
                ),
                _buildDetailRow(
                  'Request Date',
                  DateFormat(
                    'MMMM dd, yyyy • hh:mm a',
                  ).format(refund.createdAt),
                  colors,
                  theme,
                ),
              ],
              colors,
              theme,
            ),
            const SizedBox(height: 16),

            // Reason Section
            _buildSectionCard(
              'Refund Reason',
              [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    refund.reason,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              colors,
              theme,
            ),
            const SizedBox(height: 16),

            // Status Timeline
            _buildTimelineCard(colors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ColorScheme colors, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (refund.status.toLowerCase()) {
      case 'approved':
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusMessage = 'Your refund has been approved and processed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty_outlined;
        statusMessage = 'Your refund request is being reviewed';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusMessage = 'Your refund request has been rejected';
        break;
      default:
        statusColor = colors.primary;
        statusIcon = Icons.info_outline;
        statusMessage = 'Refund status: ${refund.status}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, size: 32, color: statusColor),
          ),
          const SizedBox(height: 16),
          Text(
            refund.status.toUpperCase(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    List<Widget> children,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ColorScheme colors,
    ThemeData theme, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
              color: isHighlighted ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildTimelineItem(
            'Request Submitted',
            DateFormat('MMM dd, yyyy').format(refund.createdAt),
            true,
            colors,
            theme,
          ),
          _buildTimelineItem(
            'Under Review',
            refund.status.toLowerCase() != 'pending'
                ? 'Completed'
                : 'In Progress',
            refund.status.toLowerCase() != 'pending',
            colors,
            theme,
          ),
          _buildTimelineItem(
            'Decision Made',
            refund.status.toLowerCase() == 'pending' ? 'Pending' : 'Completed',
            refund.status.toLowerCase() != 'pending',
            colors,
            theme,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted,
    ColorScheme colors,
    ThemeData theme, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? colors.primary : colors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? colors.primary : colors.outline,
                  width: 2,
                ),
              ),
              child:
                  isCompleted
                      ? Icon(Icons.check, size: 14, color: colors.onPrimary)
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color:
                    isCompleted
                        ? colors.primary
                        : colors.outline.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
