import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/add_edit_address_screen.dart';

class CheckoutAddressSelector extends ConsumerStatefulWidget {
  final AddressEntity? selectedAddress;
  final Function(AddressEntity?) onAddressChanged;
  final String? title;
  final String? subtitle;

  const CheckoutAddressSelector({
    super.key,
    this.selectedAddress,
    required this.onAddressChanged,
    this.title,
    this.subtitle,
  });

  @override
  ConsumerState<CheckoutAddressSelector> createState() =>
      _CheckoutAddressSelectorState();
}

class _CheckoutAddressSelectorState
    extends ConsumerState<CheckoutAddressSelector> {
  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(userAddressesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
          const SizedBox(height: 16),
        ],

        // Address Selection
        addressesAsync.when(
          data: (addresses) => _buildAddressSelection(context, addresses),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ],
    );
  }

  Widget _buildAddressSelection(
    BuildContext context,
    List<AddressEntity> addresses,
  ) {
    if (addresses.isEmpty) {
      return _buildNoAddressesState(context);
    }

    return Column(
      children: [
        // Address Options
        ...addresses.map((address) => _buildAddressOption(context, address)),

        const SizedBox(height: 16),

        // Add New Address Button
        OutlinedButton.icon(
          onPressed: () => _addNewAddress(context),
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            side: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressOption(BuildContext context, AddressEntity address) {
    final isSelected = widget.selectedAddress?.id == address.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 2 : 1,
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => widget.onAddressChanged(address),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Radio Button
              Radio<AddressEntity>(
                value: address,
                groupValue: widget.selectedAddress,
                onChanged: (value) => widget.onAddressChanged(value),
                activeColor: Theme.of(context).primaryColor,
              ),

              const SizedBox(width: 12),

              // Address Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (address.isDefaultAddress)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '+${address.countryCode} ${address.phone}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
                onPressed: () => _editAddress(context, address),
                icon: const Icon(Icons.edit, size: 20),
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoAddressesState(BuildContext context) {
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
            'No addresses found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Add an address to continue with checkout',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _addNewAddress(context),
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

  void _addNewAddress(BuildContext context) async {
    final result = await Navigator.of(context).push<AddressEntity>(
      MaterialPageRoute(builder: (context) => const AddEditAddressScreen()),
    );

    if (result != null) {
      widget.onAddressChanged(result);
      ref.invalidate(userAddressesProvider);
    }
  }

  void _editAddress(BuildContext context, AddressEntity address) async {
    final result = await Navigator.of(context).push<AddressEntity>(
      MaterialPageRoute(
        builder: (context) => AddEditAddressScreen(address: address),
      ),
    );

    if (result != null) {
      widget.onAddressChanged(result);
      ref.invalidate(userAddressesProvider);
    }
  }
}
