import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/refund_return_provider.dart';

class ReturnRequestDialog extends ConsumerStatefulWidget {
  final int orderId;
  final OrderProductEntity product;

  const ReturnRequestDialog({
    super.key,
    required this.orderId,
    required this.product,
  });

  @override
  ConsumerState<ReturnRequestDialog> createState() =>
      _ReturnRequestDialogState();
}

class _ReturnRequestDialogState extends ConsumerState<ReturnRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedReturnReason = 'Defective item';
  String _selectedSubReason = 'Does not work as expected';
  String _selectedPreferredOutcome = 'refund';

  bool _productNotUsed = false;
  bool _inOriginalPackaging = false;
  bool _includeAllAccessories = false;

  final List<String> _returnReasons = [
    'Defective item',
    'Wrong item received',
    'Item not as described',
    'Quality issues',
    'Changed mind',
    'Size/color issues',
    'Damaged during shipping',
    'Other',
  ];

  final List<String> _subReasons = [
    'Does not work as expected',
    'Physical damage',
    'Wrong color/size',
    'Missing parts',
    'Poor quality',
    'Not suitable for intended use',
    'Arrived late',
    'Other',
  ];

  final List<String> _preferredOutcomes = [
    'refund',
    'exchange',
    'store_credit',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final returnState = ref.watch(returnProvider);

    // Listen for success/error states
    ref.listen<ReturnState>(returnProvider, (previous, next) {
      if (next.isSuccess) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Return request submitted successfully'),
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
                      color: colors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.keyboard_return_outlined,
                      color: colors.secondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Return',
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
                                        'Qty: ${widget.product.pivot.quantity}',
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

                      // Return Reason
                      Text(
                        'Return Reason',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedReturnReason,
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
                            _returnReasons.map((reason) {
                              return DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReturnReason =
                                value ?? _returnReasons.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sub Reason
                      Text(
                        'Specific Issue',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSubReason,
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
                            _subReasons.map((reason) {
                              return DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubReason = value ?? _subReasons.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'Please provide more details about the issue...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Preferred Outcome
                      Text(
                        'Preferred Outcome',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedPreferredOutcome,
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
                            _preferredOutcomes.map((outcome) {
                              return DropdownMenuItem(
                                value: outcome,
                                child: Text(
                                  outcome.replaceAll('_', ' ').toUpperCase(),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPreferredOutcome = value ?? 'refund';
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Return Conditions
                      Text(
                        'Return Conditions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildCheckboxTile(
                        'Product has not been used',
                        _productNotUsed,
                        (value) =>
                            setState(() => _productNotUsed = value ?? false),
                      ),
                      _buildCheckboxTile(
                        'In original packaging',
                        _inOriginalPackaging,
                        (value) => setState(
                          () => _inOriginalPackaging = value ?? false,
                        ),
                      ),
                      _buildCheckboxTile(
                        'Include all accessories',
                        _includeAllAccessories,
                        (value) => setState(
                          () => _includeAllAccessories = value ?? false,
                        ),
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
                      onPressed: returnState.isLoading ? null : _submitReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          returnState.isLoading
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
                              : const Text('Submit Return Request'),
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

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReturn() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = ReturnRequestEntity(
        orderId: widget.orderId,
        productId: widget.product.id,
        returnReason: _selectedReturnReason,
        subReason: _selectedSubReason,
        description: _descriptionController.text,
        preferredOutcome: _selectedPreferredOutcome,
        productNotUsed: _productNotUsed,
        inOriginalPackaging: _inOriginalPackaging,
        includeAllAccessories: _includeAllAccessories,
      );

      ref.read(returnProvider.notifier).requestReturn(request);
    }
  }
}
