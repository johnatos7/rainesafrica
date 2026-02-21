import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/address_list_screen.dart';

class AddressManagementWidget extends ConsumerWidget {
  final bool showTitle;
  final bool showAddButton;
  final int? maxAddresses;
  final VoidCallback? onAddressSelected;
  final bool isSelectionMode;

  const AddressManagementWidget({
    super.key,
    this.showTitle = true,
    this.showAddButton = true,
    this.maxAddresses,
    this.onAddressSelected,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(userAddressesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Addresses',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (showAddButton)
                TextButton.icon(
                  onPressed: () => _navigateToAddressList(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Manage'),
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        addressesAsync.when(
          data: (addresses) => _buildAddressList(context, addresses),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ],
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    List<AddressEntity> addresses,
  ) {
    if (addresses.isEmpty) {
      return _buildEmptyState(context);
    }

    // Limit addresses if maxAddresses is specified
    final displayAddresses =
        maxAddresses != null
            ? addresses.take(maxAddresses!).toList()
            : addresses;

    return Column(
      children: [
        ...displayAddresses.map(
          (address) => _buildAddressCard(context, address),
        ),
        if (maxAddresses != null && addresses.length > maxAddresses!)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () => _navigateToAddressList(context),
              child: Text('View all ${addresses.length} addresses'),
            ),
          ),
      ],
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressEntity address) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? colors.surfaceVariant : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark
                  ? colors.outline.withOpacity(0.3)
                  : colors.outline.withOpacity(0.15),
          width: 1,
        ),
        boxShadow:
            isDark
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: InkWell(
        onTap: isSelectionMode ? () => _selectAddress(context, address) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (address.isDefaultAddress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 14, color: colors.onPrimary),
                          const SizedBox(width: 4),
                          Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? colors.surface.withOpacity(0.3)
                          : colors.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 20, color: colors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        address.fullAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? colors.surface.withOpacity(0.3)
                              : colors.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.phone, size: 16, color: colors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${address.countryCode} ${address.phone}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'No addresses yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first address to get started',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddressList(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Failed to load addresses',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.red[600]),
          ),
          const SizedBox(height: 4),
          Text(
            error.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.red[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh the provider
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddressList(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddressListScreen()));
  }

  void _selectAddress(BuildContext context, AddressEntity address) {
    onAddressSelected?.call();
    Navigator.of(context).pop(address);
  }
}

// Address selection widget for checkout
class AddressSelectionWidget extends ConsumerWidget {
  final AddressEntity? selectedAddress;
  final Function(AddressEntity) onAddressSelected;

  const AddressSelectionWidget({
    super.key,
    this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AddressManagementWidget(
      showTitle: true,
      showAddButton: true,
      maxAddresses: 3,
      isSelectionMode: true,
      onAddressSelected: () => onAddressSelected(selectedAddress!),
    );
  }
}
