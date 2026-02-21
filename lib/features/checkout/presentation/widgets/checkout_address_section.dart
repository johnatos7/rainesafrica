import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_type.dart';
// import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';

class CheckoutAddressSection extends ConsumerWidget {
  final String title;
  final AddressType addressType;
  final AddressEntity? selectedAddress;
  final Function(AddressEntity?) onAddressSelected;
  final VoidCallback onAddNewAddress;

  const CheckoutAddressSection({
    super.key,
    required this.title,
    required this.addressType,
    required this.selectedAddress,
    required this.onAddressSelected,
    required this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final addressesAsync = ref.watch(userAddressesProvider);

    return Card(
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  addressType == AddressType.shipping
                      ? Icons.local_shipping
                      : Icons.receipt,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onAddNewAddress,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: const Text('Add New', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            addressesAsync.when(
              data: (addresses) {
                if (addresses.isEmpty) {
                  return _buildEmptyAddress(context);
                }

                return Column(
                  children: [
                    if (selectedAddress != null) ...[
                      _buildSelectedAddress(selectedAddress!, context),
                      const SizedBox(height: 12),
                    ],
                    _buildAddressList(addresses, context),
                  ],
                );
              },
              loading:
                  () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              error: (error, _) => _buildErrorState(error.toString(), context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAddress(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 32, color: theme.hintColor),
          const SizedBox(height: 8),
          Text(
            'No ${addressType.name} address found',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.hintColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a new address to continue',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddress(AddressEntity address, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Selected ${addressType.name} address',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              height: 1.3,
            ),
          ),
          if (address.phone > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Phone: ${address.phone}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressList(
    List<AddressEntity> addresses,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Column(
      children:
          addresses.map((address) {
            final isSelected = selectedAddress?.id == address.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Material(
                color:
                    isSelected
                        ? theme.colorScheme.surfaceVariant
                        : theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onAddressSelected(address),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<AddressEntity>(
                          value: address,
                          groupValue: selectedAddress,
                          onChanged: (value) => onAddressSelected(value),
                          activeColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                address.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address.fullAddress,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  height: 1.3,
                                ),
                              ),
                              if (address.phone > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Phone: ${address.phone}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (address.isDefaultAddress)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildErrorState(String error, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 24),
          const SizedBox(height: 8),
          Text(
            'Failed to load addresses',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
