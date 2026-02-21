import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/widgets/checkout_address_selector.dart';

class CheckoutAddressSelectionScreen extends ConsumerStatefulWidget {
  final AddressEntity? initialShippingAddress;
  final AddressEntity? initialBillingAddress;
  final Function(AddressEntity?, AddressEntity?) onAddressesSelected;

  const CheckoutAddressSelectionScreen({
    super.key,
    this.initialShippingAddress,
    this.initialBillingAddress,
    required this.onAddressesSelected,
  });

  @override
  ConsumerState<CheckoutAddressSelectionScreen> createState() =>
      _CheckoutAddressSelectionScreenState();
}

class _CheckoutAddressSelectionScreenState
    extends ConsumerState<CheckoutAddressSelectionScreen> {
  AddressEntity? _shippingAddress;
  AddressEntity? _billingAddress;
  bool _useSameAddress = false;

  @override
  void initState() {
    super.initState();
    _shippingAddress = widget.initialShippingAddress;
    _billingAddress = widget.initialBillingAddress;
    _useSameAddress =
        _shippingAddress != null &&
        _billingAddress != null &&
        _shippingAddress!.id == _billingAddress!.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Addresses'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _canProceed() ? _handleContinue : null,
            child: const Text(
              'Continue',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Delivery & Billing Addresses',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select addresses for shipping and billing',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Use Same Address Option
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Checkbox(
                      value: _useSameAddress,
                      onChanged: (value) {
                        setState(() {
                          _useSameAddress = value ?? false;
                          if (_useSameAddress) {
                            _billingAddress = _shippingAddress;
                          }
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use same address for billing',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Billing address will be the same as shipping address',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Shipping Address Section
            CheckoutAddressSelector(
              selectedAddress: _shippingAddress,
              onAddressChanged: (address) {
                setState(() {
                  _shippingAddress = address;
                  if (_useSameAddress) {
                    _billingAddress = address;
                  }
                });
              },
              title: 'Shipping Address',
              subtitle: 'Where should we deliver your order?',
            ),
            const SizedBox(height: 32),

            // Billing Address Section
            if (!_useSameAddress)
              CheckoutAddressSelector(
                selectedAddress: _billingAddress,
                onAddressChanged: (address) {
                  setState(() {
                    _billingAddress = address;
                  });
                },
                title: 'Billing Address',
                subtitle: 'Where should we send the invoice?',
              ),
            const SizedBox(height: 24),

            // Address Summary
            if (_shippingAddress != null || _billingAddress != null)
              _buildAddressSummary(),
            const SizedBox(height: 24),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed() ? _handleContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Continue to Payment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Address Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Shipping Address Summary
            if (_shippingAddress != null) ...[
              _buildAddressSummaryItem(
                'Shipping Address',
                _shippingAddress!,
                Icons.local_shipping,
              ),
              const SizedBox(height: 12),
            ],

            // Billing Address Summary
            if (_billingAddress != null && !_useSameAddress) ...[
              _buildAddressSummaryItem(
                'Billing Address',
                _billingAddress!,
                Icons.receipt,
              ),
            ],

            if (_useSameAddress && _shippingAddress != null)
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSummaryItem(
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

  bool _canProceed() {
    return _shippingAddress != null && _billingAddress != null;
  }

  void _handleContinue() {
    if (_canProceed()) {
      widget.onAddressesSelected(_shippingAddress, _billingAddress);
      Navigator.of(context).pop();
    }
  }
}
