import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_type.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/widgets/address_form_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';

/// Demo screen showing how to use the address form for both shipping and billing addresses
class AddressFormDemoScreen extends ConsumerStatefulWidget {
  const AddressFormDemoScreen({super.key});

  @override
  ConsumerState<AddressFormDemoScreen> createState() =>
      _AddressFormDemoScreenState();
}

class _AddressFormDemoScreenState extends ConsumerState<AddressFormDemoScreen> {
  AddressEntity? _selectedShippingAddress;
  AddressEntity? _selectedBillingAddress;
  bool _useSameAddress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address Form Demo'),
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
              'Address Management Demo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This demo shows how to use the address form for both shipping and billing addresses in checkout.',
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
                            _selectedBillingAddress = _selectedShippingAddress;
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
            _buildAddressSection(
              title: 'Shipping Address',
              subtitle: 'Where should we deliver your order?',
              selectedAddress: _selectedShippingAddress,
              onAddressSelected: (address) {
                setState(() {
                  _selectedShippingAddress = address;
                  if (_useSameAddress) {
                    _selectedBillingAddress = address;
                  }
                });
              },
              onAddNewAddress: () => _showAddAddressForm(AddressType.shipping),
            ),
            const SizedBox(height: 24),

            // Billing Address Section
            if (!_useSameAddress)
              _buildAddressSection(
                title: 'Billing Address',
                subtitle: 'Where should we send the invoice?',
                selectedAddress: _selectedBillingAddress,
                onAddressSelected: (address) {
                  setState(() {
                    _selectedBillingAddress = address;
                  });
                },
                onAddNewAddress: () => _showAddAddressForm(AddressType.billing),
              ),
            const SizedBox(height: 24),

            // Address Summary
            if (_selectedShippingAddress != null ||
                _selectedBillingAddress != null)
              _buildAddressSummary(),
            const SizedBox(height: 24),

            // Demo Instructions
            _buildDemoInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection({
    required String title,
    required String subtitle,
    required AddressEntity? selectedAddress,
    required Function(AddressEntity?) onAddressSelected,
    required VoidCallback onAddNewAddress,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  title.contains('Shipping')
                      ? Icons.local_shipping
                      : Icons.receipt,
                  color: const Color(0xFF1890FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onAddNewAddress,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1890FF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: const Text('Add New', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Address List
            _buildAddressList(selectedAddress, onAddressSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(
    AddressEntity? selectedAddress,
    Function(AddressEntity?) onAddressSelected,
  ) {
    final addressesAsync = ref.watch(userAddressesProvider);

    return addressesAsync.when(
      data: (addresses) {
        if (addresses.isEmpty) {
          return _buildEmptyAddress();
        }

        return Column(
          children:
              addresses.map((address) {
                final isSelected = selectedAddress?.id == address.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected ? Colors.grey[50] : Colors.white,
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
                                    ? const Color(0xFF1890FF)
                                    : Colors.grey[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<AddressEntity>(
                              value: address,
                              groupValue: selectedAddress,
                              onChanged: (value) => onAddressSelected(value),
                              activeColor: const Color(0xFF1890FF),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    address.fullAddress,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                  ),
                                  if (address.phone > 0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Phone: ${address.phone}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
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
                                  color: const Color(0xFF1890FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
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
      },
      loading:
          () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEmptyAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 32, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No addresses found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a new address to continue',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 24),
          const SizedBox(height: 8),
          Text(
            'Failed to load addresses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.red[500]),
            textAlign: TextAlign.center,
          ),
        ],
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
            if (_selectedShippingAddress != null) ...[
              _buildAddressSummaryItem(
                'Shipping Address',
                _selectedShippingAddress!,
                Icons.local_shipping,
              ),
              const SizedBox(height: 12),
            ],

            // Billing Address Summary
            if (_selectedBillingAddress != null && !_useSameAddress) ...[
              _buildAddressSummaryItem(
                'Billing Address',
                _selectedBillingAddress!,
                Icons.receipt,
              ),
            ],

            if (_useSameAddress && _selectedShippingAddress != null)
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

  Widget _buildDemoInstructions() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Demo Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This demo shows how to:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            _buildInstructionItem('1. Load user addresses from API'),
            _buildInstructionItem('2. Select shipping and billing addresses'),
            _buildInstructionItem(
              '3. Use same address for both shipping and billing',
            ),
            _buildInstructionItem(
              '4. Add new addresses using the address form',
            ),
            _buildInstructionItem('5. Display address summaries'),
            const SizedBox(height: 12),
            Text(
              'The address form supports:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            _buildInstructionItem('• Title, street, city, pincode fields'),
            _buildInstructionItem('• Country/state selection with flags'),
            _buildInstructionItem('• Phone number with country code'),
            _buildInstructionItem('• Form validation'),
            _buildInstructionItem('• Both shipping and billing address types'),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.blue[600]),
      ),
    );
  }

  void _showAddAddressForm(AddressType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Add ${type.name} Address',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AddressFormWidget(
                      submitButtonText: 'Save ${type.name} Address',
                      onSaved: () {
                        // Refresh addresses
                        ref.invalidate(userAddressesProvider);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${type.name} address added successfully',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onCancel: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
