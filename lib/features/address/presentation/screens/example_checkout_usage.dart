import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/checkout_address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/widgets/checkout_address_summary_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/checkout_address_selection_screen.dart';

/// Example of how to integrate checkout address selection in your app
class ExampleCheckoutUsage extends ConsumerStatefulWidget {
  const ExampleCheckoutUsage({super.key});

  @override
  ConsumerState<ExampleCheckoutUsage> createState() =>
      _ExampleCheckoutUsageState();
}

class _ExampleCheckoutUsageState extends ConsumerState<ExampleCheckoutUsage> {
  @override
  Widget build(BuildContext context) {
    final isAddressComplete = ref.watch(checkoutAddressCompleteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Example'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Checkout',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your order by selecting addresses and payment method',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Address Selection Section
            _buildAddressSection(),
            const SizedBox(height: 24),

            // Payment Section (placeholder)
            _buildPaymentSection(),
            const SizedBox(height: 24),

            // Order Summary
            _buildOrderSummary(),
            const SizedBox(height: 24),

            // Continue Button
            _buildContinueButton(isAddressComplete),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Delivery Addresses',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _navigateToAddressSelection,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CheckoutAddressSummaryWidget(onEdit: _navigateToAddressSelection),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.payment, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Payment Methods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your preferred payment method',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to payment selection
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Payment Method'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrderItem('Subtotal', '\$99.99'),
                _buildOrderItem('Shipping', '\$5.99'),
                _buildOrderItem('Tax', '\$8.50'),
                const Divider(),
                _buildOrderItem('Total', '\$114.48', isTotal: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(bool isAddressComplete) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isAddressComplete ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Continue to Payment',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _navigateToAddressSelection() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CheckoutAddressSelectionScreen(
              initialShippingAddress:
                  ref.read(checkoutAddressProvider).shippingAddress,
              initialBillingAddress:
                  ref.read(checkoutAddressProvider).billingAddress,
              onAddressesSelected: (shipping, billing) {
                ref
                    .read(checkoutAddressProvider.notifier)
                    .setBothAddresses(shipping, billing);
              },
            ),
      ),
    );
  }

  void _handleContinue() {
    final addressState = ref.read(checkoutAddressProvider);

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Order'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping: ${addressState.shippingAddress?.title ?? "Not selected"}',
                ),
                if (addressState.useSameAddress)
                  const Text('Billing: Same as shipping')
                else
                  Text(
                    'Billing: ${addressState.billingAddress?.title ?? "Not selected"}',
                  ),
                const SizedBox(height: 16),
                const Text('Proceed to payment?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to payment screen
                  _showSuccessMessage();
                },
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Addresses selected successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Simple widget to show address selection status
class AddressSelectionStatus extends ConsumerWidget {
  const AddressSelectionStatus({super.key});

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
                Icon(
                  isComplete
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isComplete ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Address Selection',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isComplete) ...[
              Text(
                'Shipping: ${state.shippingAddress?.title ?? "Not selected"}',
              ),
              if (state.useSameAddress)
                const Text('Billing: Same as shipping')
              else
                Text(
                  'Billing: ${state.billingAddress?.title ?? "Not selected"}',
                ),
            ] else
              const Text('Please select shipping and billing addresses'),
          ],
        ),
      ),
    );
  }
}
