import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_status_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/return_api_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/return_reason_screen.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

class ProductActionButtons extends ConsumerStatefulWidget {
  final int orderId;
  final int consumerId;
  final OrderProductEntity product;
  final String currencySymbol;
  final bool showActions;

  const ProductActionButtons({
    super.key,
    required this.orderId,
    required this.consumerId,
    required this.product,
    required this.currencySymbol,
    this.showActions = true,
  });

  @override
  ConsumerState<ProductActionButtons> createState() =>
      _ProductActionButtonsState();
}

class _ProductActionButtonsState extends ConsumerState<ProductActionButtons> {
  ReturnStatusEntity? _existingReturn;
  bool _isLoadingReturnStatus = false;

  @override
  void initState() {
    super.initState();
    _checkReturnStatus();
  }

  Future<void> _checkReturnStatus() async {
    setState(() {
      _isLoadingReturnStatus = true;
    });

    try {
      final secureStorage = ref.read(secureStorageProvider);
      final apiService = ReturnApiService(secureStorage: secureStorage);
      final response = await apiService.getReturnsByOrderId(widget.orderId);

      if (response['success'] == true) {
        final List<ReturnStatusEntity> returns = response['data'];
        // Check if this product has an existing return request
        try {
          final existingReturn = returns.firstWhere(
            (returnRequest) => returnRequest.productId == widget.product.id,
          );

          setState(() {
            _existingReturn = existingReturn;
          });
        } catch (e) {
          // No existing return found for this product
          setState(() {
            _existingReturn = null;
          });
        }
      }
    } catch (e) {
      // Handle error silently - don't prevent the UI from showing
      print('Error checking return status: $e');
    } finally {
      setState(() {
        _isLoadingReturnStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!widget.showActions) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        children: [Expanded(child: _buildReturnButton(context, theme, colors))],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colors,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    // Show loading state while checking return status
    if (_isLoadingReturnStatus) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Checking...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Show different button states based on return status
    if (_existingReturn != null) {
      return _buildReturnStatusButton(context, theme, colors);
    }

    // Show normal return button if no existing return
    return _buildActionButton(
      context: context,
      theme: theme,
      colors: colors,
      icon: Icons.keyboard_return_outlined,
      label: 'LOG RETURN',
      color: colors.secondary,
      onTap: () => _showReturnDialog(context),
    );
  }

  Widget _buildReturnStatusButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final returnStatus = _existingReturn!.status.toLowerCase();
    IconData icon;
    String label;
    Color color;

    switch (returnStatus) {
      case 'pending':
        icon = Icons.pending_outlined;
        label = 'RETURN PENDING';
        color = colors.primary;
        break;
      case 'approved':
        icon = Icons.check_circle_outline;
        label = 'RETURN APPROVED';
        color = Colors.green;
        break;
      case 'rejected':
        icon = Icons.cancel_outlined;
        label = 'RETURN REJECTED';
        color = colors.error;
        break;
      default:
        icon = Icons.info_outline;
        label = 'RETURN SUBMITTED';
        color = colors.primary;
    }

    return InkWell(
      onTap: () => _showReturnDetailsDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ReturnReasonScreen(
              orderId: widget.orderId,
              product: widget.product,
            ),
      ),
    );
  }

  void _showReturnDetailsDialog(BuildContext context) {
    if (_existingReturn == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Return Request Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Status:',
                  _existingReturn!.status.toUpperCase(),
                ),
                _buildDetailRow('Reason:', _existingReturn!.returnReason),
                if (_existingReturn!.subReason.isNotEmpty)
                  _buildDetailRow('Sub-reason:', _existingReturn!.subReason),
                _buildDetailRow('Outcome:', _existingReturn!.preferredOutcome),
                if (_existingReturn!.rejectionReason != null)
                  _buildDetailRow(
                    'Rejection Reason:',
                    _existingReturn!.rejectionReason!,
                  ),
                _buildDetailRow(
                  'Submitted:',
                  _formatDate(_existingReturn!.createdAt),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
