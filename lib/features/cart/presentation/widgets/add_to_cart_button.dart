import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';

class AddToCartButton extends ConsumerStatefulWidget {
  final ProductEntity product;
  final int quantity;
  final List<ProductVariationEntity>? selectedVariations;
  final Map<String, String>? selectedAttributes;
  final VoidCallback? onAdded;
  final VoidCallback? onError;
  final bool isDisabled;

  const AddToCartButton({
    super.key,
    required this.product,
    this.quantity = 1,
    this.selectedVariations,
    this.selectedAttributes,
    this.onAdded,
    this.onError,
    this.isDisabled = false,
  });

  @override
  ConsumerState<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends ConsumerState<AddToCartButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ElevatedButton(
      onPressed: (_isLoading || widget.isDisabled) ? null : _addToCart,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.isDisabled ? colors.surfaceVariant : colors.primary,
        foregroundColor:
            widget.isDisabled ? colors.onSurfaceVariant : colors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child:
          _isLoading
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isDisabled
                        ? colors.onSurfaceVariant
                        : colors.onPrimary,
                  ),
                ),
              )
              : Text(widget.isDisabled ? 'Select Options' : 'Add to Cart'),
    );
  }

  Future<void> _addToCart() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Extract selected attribute IDs and variation display name from selected variations
      List<int>? selectedAttributeIds;
      String? variationDisplayName;
      int? selectedVariationId;

      print(
        'DEBUG: AddToCart - selectedVariations: ${widget.selectedVariations?.length ?? 0}',
      );
      if (widget.selectedVariations != null &&
          widget.selectedVariations!.isNotEmpty) {
        print(
          'DEBUG: AddToCart - selectedVariations[0].id: ${widget.selectedVariations!.first.id}',
        );
        print(
          'DEBUG: AddToCart - selectedVariations[0].attributeValues: ${widget.selectedVariations!.first.attributeValues?.length ?? 0}',
        );
      }
      print(
        'DEBUG: AddToCart - selectedAttributes: ${widget.selectedAttributes?.keys.length ?? 0}',
      );
      print(
        'DEBUG: AddToCart - product variations: ${widget.product.variations?.length ?? 0}',
      );
      if (widget.product.variations != null &&
          widget.product.variations!.isNotEmpty) {
        print(
          'DEBUG: AddToCart - First variation has attributeValues: ${widget.product.variations!.first.attributeValues?.length ?? 0}',
        );
      }

      if (widget.selectedVariations != null &&
          widget.selectedVariations!.isNotEmpty) {
        final variation = widget.selectedVariations!.first;
        selectedVariationId = variation.id;
        print(
          'DEBUG: AddToCart - Found variation ID from selectedVariations: $selectedVariationId',
        );

        // Build variation display name from attribute values
        if (variation.attributeValues != null &&
            variation.attributeValues!.isNotEmpty) {
          final displayParts =
              variation.attributeValues!
                  .map((attrValue) => attrValue.value ?? '')
                  .where((value) => value.isNotEmpty)
                  .toList();
          variationDisplayName = displayParts.join(' - ');

          // Extract attribute value IDs
          selectedAttributeIds =
              variation.attributeValues!
                  .map((attrValue) => attrValue.id)
                  .toList();
        }
      }

      // If still no attribute IDs found but selectedAttributes is provided, try to extract from product variations
      if ((selectedAttributeIds == null || selectedAttributeIds.isEmpty) &&
          widget.selectedAttributes != null &&
          widget.selectedAttributes!.isNotEmpty &&
          widget.product.variations != null) {
        selectedAttributeIds = [];
        final displayParts = <String>[];
        final selectedAttrs = widget.selectedAttributes;

        // Find attribute value IDs by matching attribute IDs and values from product variations
        if (selectedAttrs != null) {
          for (final entry in selectedAttrs.entries) {
            final attributeId = int.tryParse(entry.key);
            if (attributeId == null) continue;

            final attributeValueText = entry.value;
            if (attributeValueText.isEmpty) continue;

            // Find the attribute value entity from product variations
            bool found = false;
            for (final variation in widget.product.variations!) {
              if (found) break;
              for (final attrValue in variation.attributeValues ?? []) {
                if (attrValue.attributeId == attributeId &&
                    attrValue.value == attributeValueText) {
                  selectedAttributeIds.add(attrValue.id);
                  displayParts.add(attributeValueText);
                  found = true;
                  break;
                }
              }
            }
          }
        }

        if (displayParts.isNotEmpty && variationDisplayName == null) {
          variationDisplayName = displayParts.join(' - ');
        }

        // Find matching variation based on selected attributes to get variation_id
        if (selectedVariationId == null &&
            selectedAttributeIds.isNotEmpty &&
            widget.product.variations != null) {
          print(
            'DEBUG: AddToCart - Looking for variation with attribute IDs: $selectedAttributeIds',
          );
          // Find variation that contains all selected attribute value IDs
          for (final variation in widget.product.variations!) {
            final variationAttributeValueIds =
                (variation.attributeValues ?? [])
                    .map((attrValue) => attrValue.id)
                    .toList();

            print(
              'DEBUG: AddToCart - Checking variation ${variation.id} with attribute value IDs: $variationAttributeValueIds',
            );

            // Check if this variation has all selected attribute value IDs
            bool hasAllSelectedIds = true;
            if (variationAttributeValueIds.length !=
                selectedAttributeIds.length) {
              hasAllSelectedIds = false;
            } else {
              for (final selectedId in selectedAttributeIds) {
                if (!variationAttributeValueIds.contains(selectedId)) {
                  hasAllSelectedIds = false;
                  break;
                }
              }
            }

            if (hasAllSelectedIds) {
              selectedVariationId = variation.id;
              print(
                'DEBUG: AddToCart - Found matching variation ID: $selectedVariationId',
              );
              break;
            }
          }

          if (selectedVariationId == null) {
            print(
              'DEBUG: AddToCart - WARNING: No variation found for attribute IDs: $selectedAttributeIds',
            );
          }
        }
      }

      // Final check: If we have selectedAttributeIds but no variationId, find the matching variation
      // Try matching by attribute value IDs first
      if (selectedVariationId == null &&
          selectedAttributeIds != null &&
          selectedAttributeIds.isNotEmpty &&
          widget.product.variations != null) {
        print(
          'DEBUG: Final check - Looking for variation with attribute IDs: $selectedAttributeIds',
        );
        print(
          'DEBUG: Product has ${widget.product.variations!.length} variations',
        );

        for (final variation in widget.product.variations!) {
          final variationAttributeValueIds =
              (variation.attributeValues ?? [])
                  .map((attrValue) => attrValue.id)
                  .toList();

          print(
            'DEBUG: Variation ${variation.id} has attribute value IDs: $variationAttributeValueIds',
          );

          // Check if this variation has all selected attribute value IDs
          if (variationAttributeValueIds.length ==
              selectedAttributeIds.length) {
            bool hasAllSelectedIds = true;
            for (final selectedId in selectedAttributeIds) {
              if (!variationAttributeValueIds.contains(selectedId)) {
                hasAllSelectedIds = false;
                break;
              }
            }

            if (hasAllSelectedIds) {
              selectedVariationId = variation.id;
              print(
                'DEBUG: Found matching variation ID: $selectedVariationId for attribute IDs: $selectedAttributeIds',
              );
              break;
            }
          }
        }

        // If still not found, try matching by attribute IDs and values (like _findMatchingVariation does)
        if (selectedVariationId == null &&
            widget.selectedAttributes != null &&
            widget.selectedAttributes!.isNotEmpty) {
          print(
            'DEBUG: Trying alternative matching by attribute IDs and values',
          );
          for (final variation in widget.product.variations!) {
            final variationAttributeValues = variation.attributeValues ?? [];
            bool hasAllSelectedAttributes = true;

            for (final entry in widget.selectedAttributes!.entries) {
              final attributeId = int.tryParse(entry.key);
              if (attributeId == null) continue;

              final found = variationAttributeValues.any(
                (attrValue) =>
                    attrValue.attributeId == attributeId &&
                    attrValue.value == entry.value,
              );

              if (!found) {
                hasAllSelectedAttributes = false;
                break;
              }
            }

            if (hasAllSelectedAttributes &&
                variationAttributeValues.length ==
                    widget.selectedAttributes!.length) {
              selectedVariationId = variation.id;
              print(
                'DEBUG: Found matching variation ID by attribute matching: $selectedVariationId',
              );
              break;
            }
          }
        }

        // Last resort: If still not found, use the last variation that contains any of the selected attribute IDs
        if (selectedVariationId == null && selectedAttributeIds.isNotEmpty) {
          print(
            'DEBUG: Last resort - Looking for any variation containing selected attribute IDs',
          );
          ProductVariationEntity? lastMatchingVariation;
          int maxMatches = 0;

          for (final variation in widget.product.variations!) {
            final variationAttributeValueIds =
                (variation.attributeValues ?? [])
                    .map((attrValue) => attrValue.id)
                    .toList();

            int matchCount = 0;
            for (final selectedId in selectedAttributeIds) {
              if (variationAttributeValueIds.contains(selectedId)) {
                matchCount++;
              }
            }

            if (matchCount > maxMatches) {
              maxMatches = matchCount;
              lastMatchingVariation = variation;
            }
          }

          if (lastMatchingVariation != null && maxMatches > 0) {
            selectedVariationId = lastMatchingVariation.id;
            print(
              'DEBUG: Using last resort variation ID: $selectedVariationId (matched $maxMatches/${selectedAttributeIds.length} attributes)',
            );
          } else {
            print(
              'DEBUG: WARNING - No matching variation found for attribute IDs: $selectedAttributeIds',
            );
          }
        }
      }

      await ref.read(
        addToCartProvider({
          'productId': widget.product.id,
          'quantity': widget.quantity,
          'selectedVariationId': selectedVariationId,
          'selectedVariation': variationDisplayName,
          'selectedAttributes': widget.selectedAttributes,
          'selectedAttributeIds': selectedAttributeIds,
          'variationDisplayName': variationDisplayName,
        }).future,
      );

      // Refresh cart providers to update UI
      ref.invalidate(cartProvider);
      ref.invalidate(cartItemCountProvider);
      ref.invalidate(cartSummaryProvider);

      if (mounted) {
        _showAddToCartBottomSheet();
      }

      widget.onAdded?.call();
    } catch (e) {
      if (mounted) {
        _showErrorBottomSheet(e.toString());
      }
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddToCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _AddToCartBottomSheet(
            product: widget.product,
            quantity: widget.quantity,
          ),
    );
  }

  void _showErrorBottomSheet(String error) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _ErrorBottomSheet(product: widget.product, error: error),
    );
  }
}

class _AddToCartBottomSheet extends StatelessWidget {
  final ProductEntity product;
  final int quantity;

  const _AddToCartBottomSheet({required this.product, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: colors.primary, size: 32),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Added to Cart!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Product name
            Text(
              product.name,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Quantity info
            Text(
              'Quantity: $quantity',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.outline.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(AppConstants.cartRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Cart',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBottomSheet extends StatelessWidget {
  final ProductEntity product;
  final String error;

  const _ErrorBottomSheet({required this.product, required this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Error icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, color: colors.error, size: 32),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Failed to Add to Cart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Product name
            Text(
              product.name,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Error message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.error.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                error,
                style: TextStyle(fontSize: 14, color: colors.error),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: colors.outline.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // You can add retry logic here if needed
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
