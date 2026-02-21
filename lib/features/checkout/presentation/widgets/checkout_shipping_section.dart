import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/providers/settings_providers.dart';

class CheckoutShippingSection extends ConsumerWidget {
  final ShippingOptionEntity? selectedShipping;
  final Function(ShippingOptionEntity?) onShippingSelected;

  const CheckoutShippingSection({
    super.key,
    required this.selectedShipping,
    required this.onShippingSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Shipping Options',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            settingsAsync.when(
              data: (settings) {
                final shippingOptions = settings.delivery.shippingOptions;

                if (shippingOptions.isEmpty) {
                  return _buildEmptyShipping(context);
                }

                return Column(
                  children:
                      shippingOptions.map((option) {
                        return _buildShippingOption(option, context);
                      }).toList(),
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              error:
                  (error, stackTrace) =>
                      _buildErrorState(error.toString(), context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyShipping(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 32,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No shipping options available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please contact support',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingOption(
    ShippingOptionEntity option,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedShipping?.title == option.title;

    // Transform the title from "Free Collection - Branch Name" to "Collection at Branch Name"
    String displayTitle = option.title;
    if (displayTitle.startsWith('Free Collection - ')) {
      displayTitle = displayTitle.replaceFirst(
        'Free Collection - ',
        'Collection at ',
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color:
            isSelected
                ? colorScheme.primary.withOpacity(0.05)
                : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onShippingSelected(option),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Radio<ShippingOptionEntity>(
                  value: option,
                  groupValue: selectedShipping,
                  onChanged: (value) => onShippingSelected(value),
                  activeColor: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayTitle, // Use the transformed title here
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            option.price == 0
                                ? 'FREE'
                                : '\$${option.price.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  option.price == 0
                                      ? Colors.green
                                      : colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (option.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          option.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 24),
          const SizedBox(height: 8),
          Text(
            'Failed to load shipping options',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onErrorContainer.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
