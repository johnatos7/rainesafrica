import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/refund_return_provider.dart';

class RefundRequestDialog extends ConsumerStatefulWidget {
  final int orderId;
  final int consumerId;
  final OrderProductEntity product;
  final String currencySymbol;

  const RefundRequestDialog({
    super.key,
    required this.orderId,
    required this.consumerId,
    required this.product,
    required this.currencySymbol,
  });

  @override
  ConsumerState<RefundRequestDialog> createState() =>
      _RefundRequestDialogState();
}

class _RefundRequestDialogState extends ConsumerState<RefundRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String _selectedPaymentType = 'bank';
  double _refundAmount = 0.0;
  int _refundQuantity = 1;

  final List<String> _paymentTypes = ['bank', 'wallet', 'card'];
  final List<String> _refundReasons = [
    'Defective product',
    'Wrong item received',
    'Item not as described',
    'Quality issues',
    'Changed mind',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _refundAmount = widget.product.pivot.subtotal;
    _refundQuantity = widget.product.pivot.quantity;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final refundState = ref.watch(refundProvider);

    // Listen for success/error states
    ref.listen<RefundState>(refundProvider, (previous, next) {
      if (next.isSuccess) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Refund request submitted successfully'),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.money_off_outlined,
                      color: colors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Refund',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          widget.product.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: colors.onSurface),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Details',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: colors.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child:
                                        widget.product.productThumbnail != null
                                            ? Image.network(
                                              widget
                                                  .product
                                                  .productThumbnail!
                                                  .imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Icon(
                                                  Icons.image_outlined,
                                                  color: colors.onSurface
                                                      .withOpacity(0.4),
                                                  size: 16,
                                                );
                                              },
                                            )
                                            : Icon(
                                              Icons.image_outlined,
                                              color: colors.onSurface
                                                  .withOpacity(0.4),
                                              size: 16,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qty: ${widget.product.pivot.quantity} • ${widget.product.pivot.subtotal.toStringAsFixed(2)} ${widget.currencySymbol}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: colors.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Refund Amount
                      Text(
                        'Refund Amount',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _refundAmount.toStringAsFixed(2),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  suffixText: widget.currencySymbol,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  _refundAmount = double.tryParse(value) ?? 0.0;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: _refundQuantity.toString(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Qty',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  _refundQuantity = int.tryParse(value) ?? 1;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Refund Reason
                      Text(
                        'Reason for Refund',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _refundReasons.first,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items:
                            _refundReasons.map((reason) {
                              return DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _reasonController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Additional Details (Optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Payment Type
                      Text(
                        'Refund Method',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPaymentType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items:
                            _paymentTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.toUpperCase()),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentType = value ?? 'bank';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(color: colors.outline.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: refundState.isLoading ? null : _submitRefund,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          refundState.isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('Submit Refund Request'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRefund() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = RefundRequestEntity(
        consumerId: widget.consumerId,
        orderId: widget.orderId,
        productId: widget.product.id,
        amount: _refundAmount,
        quantity: _refundQuantity,
        reason:
            _reasonController.text.isNotEmpty
                ? _reasonController.text
                : _refundReasons.first,
        paymentType: _selectedPaymentType,
      );

      ref.read(refundProvider.notifier).requestRefund(request);
    }
  }
}
