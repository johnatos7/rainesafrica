import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_list_entity.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnDetailsScreen extends StatelessWidget {
  final ReturnListItemEntity returnItem;

  const ReturnDetailsScreen({super.key, required this.returnItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Return Details',
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

            // Return Information
            _buildSectionCard(
              'Return Information',
              [
                _buildDetailRow(
                  'Return ID',
                  '#${returnItem.id}',
                  colors,
                  theme,
                ),
                _buildDetailRow(
                  'Order ID',
                  '#${returnItem.orderId}',
                  colors,
                  theme,
                ),
                _buildDetailRow(
                  'Product ID',
                  '#${returnItem.productId}',
                  colors,
                  theme,
                ),
                _buildDetailRow(
                  'Preferred Outcome',
                  returnItem.preferredOutcome
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  colors,
                  theme,
                  isHighlighted: true,
                ),
                _buildDetailRow(
                  'Request Date',
                  DateFormat(
                    'MMMM dd, yyyy • hh:mm a',
                  ).format(returnItem.createdAt),
                  colors,
                  theme,
                ),
              ],
              colors,
              theme,
            ),
            const SizedBox(height: 16),

            // Return Reason Section
            _buildSectionCard(
              'Return Reason',
              [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    returnItem.returnReason,
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
            const SizedBox(height: 16),

            // Return Policy Notice
            _buildReturnPolicyNotice(colors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ColorScheme colors, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (returnItem.status.toLowerCase()) {
      case 'approved':
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        statusMessage = 'Your return has been approved and processed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty_outlined;
        statusMessage = 'Your return request is being reviewed';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        statusMessage = 'Your return request has been rejected';
        break;
      default:
        statusColor = colors.secondary;
        statusIcon = Icons.info_outline;
        statusMessage = 'Return status: ${returnItem.status}';
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
            returnItem.status.toUpperCase(),
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
              color: isHighlighted ? colors.secondary : colors.onSurface,
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
            DateFormat('MMM dd, yyyy').format(returnItem.createdAt),
            true,
            colors,
            theme,
          ),
          _buildTimelineItem(
            'Under Review',
            returnItem.status.toLowerCase() != 'pending'
                ? 'Completed'
                : 'In Progress',
            returnItem.status.toLowerCase() != 'pending',
            colors,
            theme,
          ),
          _buildTimelineItem(
            'Decision Made',
            returnItem.status.toLowerCase() == 'pending'
                ? 'Pending'
                : 'Completed',
            returnItem.status.toLowerCase() != 'pending',
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
                color: isCompleted ? colors.secondary : colors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? colors.secondary : colors.outline,
                  width: 2,
                ),
              ),
              child:
                  isCompleted
                      ? Icon(Icons.check, size: 14, color: colors.onSecondary)
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color:
                    isCompleted
                        ? colors.secondary
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

  Widget _buildReturnPolicyNotice(ColorScheme colors, ThemeData theme) {
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
            'Important Notice',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please note: When we receive your product, we will inspect it. Only unused products in their original packaging will be accepted, else the product may be returned to you.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap:
                () => _openUrl('https://raines.africa/en/pages/return-policy'),
            child: Text(
              'View our Returns Policy',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    );
  }
}
