import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

class ShippingSelectionWidget extends StatelessWidget {
  final ProductEntity product;
  final String? selectedShippingMethod;
  final Function(String?) onShippingMethodChanged;

  const ShippingSelectionWidget({
    super.key,
    required this.product,
    required this.selectedShippingMethod,
    required this.onShippingMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Only show shipping options if product has expedited shipping
    if (product.hasExpedited != true || product.shippingOptions == null) {
      return const SizedBox.shrink();
    }

    final shippingOptions = product.shippingOptions!;
    final standardDays = shippingOptions.standardShippingDays;
    final expeditedDays = shippingOptions.expeditedShippingDays;
    final standardPrice = shippingOptions.standardShippingPrice;
    final expeditedPrice = shippingOptions.expeditedShippingPrice;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Standard Shipping Option
          _buildShippingOption(
            context: context,
            title: 'Standard',
            subtitle: '($standardDays Days +)',
            price: standardPrice ?? 0.0,
            isSelected:
                selectedShippingMethod == null ||
                selectedShippingMethod == 'standard',
            onTap: () => onShippingMethodChanged(null),
          ),

          const SizedBox(height: 8),

          // Expedited Shipping Option
          _buildShippingOption(
            context: context,
            title: 'Fast',
            subtitle: '($expeditedDays Days)',
            price: expeditedPrice ?? 0.0,
            isSelected: selectedShippingMethod == 'expedited',
            onTap: () => onShippingMethodChanged('expedited'),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
            ),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                  ),
                  child:
                      isSelected
                          ? Icon(
                            Icons.check,
                            size: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                          : null,
                ),

                const SizedBox(width: 12),

                // Shipping info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Text(
                  ref.watch(currencyFormattingProvider)(price),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
