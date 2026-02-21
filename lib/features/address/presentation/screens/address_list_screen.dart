import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/providers/address_providers.dart';
// Removed unused direct import of AddEditAddressScreen. Navigation is via GoRouter.
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/usecases/manage_address_use_case.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final addressesAsync = ref.watch(userAddressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: addressesAsync.when(
        data: (addresses) => _buildAddressList(context, ref, addresses, colors),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, ref, error, colors),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAddress(context, ref),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddressList(
    BuildContext context,
    WidgetRef ref,
    List<AddressEntity> addresses,
    ColorScheme colors,
  ) {
    if (addresses.isEmpty) {
      return _buildEmptyState(context, ref, colors);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userAddressesProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(context, ref, address, colors);
        },
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    WidgetRef ref,
    AddressEntity address,
    ColorScheme colors,
  ) {
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (!address.isDefaultAddress) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _setAsDefault(context, ref, address),
                  icon: const Icon(Icons.star, size: 18),
                  label: const Text('Set as Default'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: colors.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Addresses Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddAddress(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    WidgetRef ref,
    Object error,
    ColorScheme colors,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(userAddressesProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAddress(BuildContext context, WidgetRef ref) {
    context
        .pushNamed('add_address', queryParameters: {'redirect': '/addresses'})
        .then((_) {
          ref.invalidate(userAddressesProvider);
        });
  }

  void _setAsDefault(
    BuildContext context,
    WidgetRef ref,
    AddressEntity address,
  ) async {
    try {
      final setDefaultUseCase = ref.read(setDefaultAddressUseCaseProvider);
      final result = await setDefaultUseCase.execute(address.id);

      result.fold((failure) => _showErrorSnackBar(context, failure.message), (
        success,
      ) {
        ref.invalidate(userAddressesProvider);
        _showSuccessSnackBar(context, 'Default address updated');
      });
    } catch (e) {
      _showErrorSnackBar(context, 'Failed to set default address: $e');
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
