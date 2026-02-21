import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/checkout_address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/widgets/checkout_address_summary_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/checkout_address_selection_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressState = ref.watch(checkoutAddressProvider);
    final isAddressComplete = ref.watch(checkoutAddressCompleteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildAddressStep(),
                _buildPaymentStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(addressState, isAddressComplete),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Address', _currentStep >= 0),
          _buildStepConnector(_currentStep > 0),
          _buildStepIndicator(1, 'Payment', _currentStep >= 1),
          _buildStepConnector(_currentStep > 1),
          _buildStepIndicator(2, 'Review', _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  isActive ? Theme.of(context).primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  isActive ? Theme.of(context).primaryColor : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      height: 2,
      width: 20,
      color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery & Billing Addresses',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select where to deliver your order and where to send the invoice',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Address Selection
          CheckoutAddressSummaryWidget(
            onEdit: () => _navigateToAddressSelection(),
          ),
          const SizedBox(height: 24),

          // Address Tips
          _buildAddressTips(),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred payment method',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Payment methods will be implemented here
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
                    'Payment method selection will be implemented here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Order',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your order details before placing it',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Address Summary
          CheckoutAddressSummaryWidget(
            showEditButton: false,
            title: 'Delivery Addresses',
          ),
          const SizedBox(height: 16),

          // Order Summary (placeholder)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
      ),
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

  Widget _buildAddressTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Address Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              Icons.local_shipping,
              'Accurate shipping address',
              'Make sure your shipping address is correct for successful delivery',
            ),
            const SizedBox(height: 8),
            _buildTipItem(
              Icons.receipt,
              'Billing address',
              'Your billing address should match your payment method',
            ),
            const SizedBox(height: 8),
            _buildTipItem(
              Icons.phone,
              'Contact information',
              'Keep your phone number updated for delivery notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    CheckoutAddressState addressState,
    bool isAddressComplete,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceedToNext() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0:
        return ref.read(checkoutAddressCompleteProvider);
      case 1:
        return true; // Payment step - implement validation
      case 2:
        return true; // Review step - ready to place order
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continue to Payment';
      case 1:
        return 'Review Order';
      case 2:
        return 'Place Order';
      default:
        return 'Next';
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _placeOrder();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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

  void _placeOrder() {
    // Implement order placement logic
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Order Placed'),
            content: const Text('Your order has been placed successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
