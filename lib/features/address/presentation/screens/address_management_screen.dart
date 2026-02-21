import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/add_edit_address_screen.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_loading.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_error.dart'
    as app_error;
import 'package:go_router/go_router.dart';

class AddressManagementScreen extends ConsumerStatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  ConsumerState<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState
    extends ConsumerState<AddressManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load addresses when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(refreshUserAddressesProvider)();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(userAddressesProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Address Book',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: colors.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 22, color: colors.onSurface),
            onPressed: () {
              ref.read(refreshUserAddressesProvider)();
            },
          ),
        ],
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return _buildEmptyState(colors);
          }
          return _buildAddressList(addresses, colors);
        },
        loading: () => const AppLoading(),
        error:
            (error, stackTrace) => app_error.AppError(
              message: error.toString(),
              onRetry: () {
                ref.read(refreshUserAddressesProvider)();
              },
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddAddress(),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 3),
            ),
            child: Icon(Icons.location_off, size: 60, color: colors.primary),
          ),
          const SizedBox(height: 32),

          // Empty state title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NO ADDRESSES',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.onPrimary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Add your first address to get started',
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Add address button
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _navigateToAddAddress(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_location, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'ADD YOUR FIRST ADDRESS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(List<AddressEntity> addresses, ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(refreshUserAddressesProvider)();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(address, colors);
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity address, ColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address header with default status
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.label, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
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

            // Address details in highlighted container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark
                        ? colors.surface.withOpacity(0.3)
                        : colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address lines
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 20, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.street,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.onSurface.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${address.city}${address.pincode != null ? ', ${address.pincode}' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.onSurface.withOpacity(0.8),
                              ),
                            ),
                            if (address.state != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                address.state!.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ],
                            if (address.country != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                address.country!.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.onSurface.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Phone number
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
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddAddress() {
    print('DEBUG: _navigateToAddAddress called');
    print('DEBUG: Navigating to AddEditAddressScreen');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => AddEditAddressScreen(
              onAddressSaved: (address) {
                print('DEBUG: onAddressSaved callback triggered');
                print('DEBUG: Address saved: $address');
                // Refresh addresses after adding new one
                print('DEBUG: Refreshing user addresses...');
                ref.read(refreshUserAddressesProvider)();
                print(
                  'DEBUG: Navigation completed (AddEditAddressScreen handles pop)',
                );
                // Don't call Navigator.pop() here - AddEditAddressScreen already handles it
              },
            ),
      ),
    );
    print('DEBUG: Navigation initiated');
  }
}
