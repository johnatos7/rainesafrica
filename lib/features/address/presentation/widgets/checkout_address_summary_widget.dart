import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/checkout_address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/checkout_address_selection_screen.dart';

class CheckoutAddressSummaryWidget extends ConsumerWidget {
  final VoidCallback? onEdit;
  final bool showEditButton;
  final String? title;

  const CheckoutAddressSummaryWidget({
    super.key,
    this.onEdit,
    this.showEditButton = true,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutAddressProvider);
    final isComplete = ref.watch(checkoutAddressCompleteProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title ?? 'Delivery & Billing Addresses',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showEditButton)
                  TextButton.icon(
                    onPressed:
                        onEdit ?? () => _navigateToAddressSelection(context),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (!isComplete)
              _buildIncompleteState(context)
            else
              _buildCompleteState(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildIncompleteState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Addresses not selected',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please select shipping and billing addresses to continue',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.orange[700]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToAddressSelection(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Select Addresses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteState(BuildContext context, CheckoutAddressState state) {
    return Column(
      children: [
        // Shipping Address
        _buildAddressItem(
          context,
          'Shipping Address',
          state.shippingAddress!,
          Icons.local_shipping,
        ),
        const SizedBox(height: 12),

        // Billing Address
        if (state.useSameAddress)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Billing address is the same as shipping address',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _buildAddressItem(
            context,
            'Billing Address',
            state.billingAddress!,
            Icons.receipt,
          ),
      ],
    );
  }

  Widget _buildAddressItem(
    BuildContext context,
    String title,
    AddressEntity address,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            address.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.phone, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '+${address.countryCode} ${address.phone}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToAddressSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CheckoutAddressSelectionScreen(
              onAddressesSelected: (shipping, billing) {
                // This will be handled by the parent widget
              },
            ),
      ),
    );
  }
}

// Quick address selection widget for checkout
class QuickAddressSelectionWidget extends ConsumerWidget {
  final String? title;
  final VoidCallback? onSelect;

  const QuickAddressSelectionWidget({super.key, this.title, this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutAddressProvider);
    final isComplete = ref.watch(checkoutAddressCompleteProvider);

    return Card(
      child: InkWell(
        onTap: onSelect ?? () => _navigateToAddressSelection(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title ?? 'Delivery Addresses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isComplete)
                _buildAddressPreview(context, state)
              else
                _buildSelectAddressPrompt(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressPreview(
    BuildContext context,
    CheckoutAddressState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping: ${state.shippingAddress?.title ?? "Not selected"}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (state.useSameAddress)
          Text(
            'Billing: Same as shipping',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          )
        else
          Text(
            'Billing: ${state.billingAddress?.title ?? "Not selected"}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }

  Widget _buildSelectAddressPrompt(BuildContext context) {
    return Text(
      'Tap to select delivery addresses',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
    );
  }

  void _navigateToAddressSelection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CheckoutAddressSelectionScreen(
              onAddressesSelected: (shipping, billing) {
                // This will be handled by the parent widget
              },
            ),
      ),
    );
  }
}
