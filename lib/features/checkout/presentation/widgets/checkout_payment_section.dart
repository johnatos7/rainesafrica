import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/providers/settings_providers.dart';
// Wallet and cart providers not needed here since wallet is not selectable

class CheckoutPaymentSection extends ConsumerWidget {
  final PaymentMethodEntity? selectedPaymentMethod;
  final Function(PaymentMethodEntity?) onPaymentMethodSelected;
  final double? totalAmount; // Add total amount parameter

  const CheckoutPaymentSection({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
    this.totalAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    // Wallet removed as selectable; no need to watch wallet/cart here
    final theme = Theme.of(context);

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
                Icon(Icons.payment, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Payment Method',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Wallet is not a direct payment option anymore

            // Async data for other payment methods
            settingsAsync.when(
              data: (settings) {
                final paymentMethods = settings.paymentMethods;
                if (paymentMethods.isEmpty) {
                  return const SizedBox.shrink();
                }

                // Filter and reorder payment methods
                final filteredAndOrderedMethods = _filterAndOrderPaymentMethods(
                  paymentMethods,
                );

                if (filteredAndOrderedMethods.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children:
                      filteredAndOrderedMethods
                          .map((method) => _buildPaymentMethod(method, context))
                          .toList(),
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

  // Wallet option removed

  Widget _buildPaymentMethod(PaymentMethodEntity method, BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = selectedPaymentMethod?.name == method.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected ? theme.colorScheme.surfaceVariant : theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onPaymentMethodSelected(method),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isSelected ? theme.colorScheme.primary : theme.dividerColor,
              ),
            ),
            child: Row(
              children: [
                // Radio Button
                Radio<PaymentMethodEntity>(
                  value: method,
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) => onPaymentMethodSelected(value),
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),

                // Image and Text in Column (instead of Row)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Icon/Image on top
                      _buildPaymentIcon(method.name, context),
                      const SizedBox(height: 8),

                      // Text below the image
                      Text(
                        _getPaymentTitle(method.name),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getPaymentDescription(method.name),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active status badge (if applicable)
                if (method.status == 'active')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Active',
                      style: theme.textTheme.labelSmall?.copyWith(
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
  }

  Widget _buildPaymentIcon(String methodName, BuildContext context) {
    final theme = Theme.of(context);
    String imagePath;

    switch (methodName.toLowerCase()) {
      case 'payfast':
        imagePath = 'assets/images/payfast.png';
        break;
      case 'pdo_zambia':
        imagePath = 'assets/images/dpozambia.png';
        break;
      case 'pese':
        imagePath = 'assets/images/pese2.png';
        break;
      case 'cod':
        imagePath = 'assets/images/cash2.png';
        break;
      case 'bank_transfer':
        imagePath = 'assets/images/banktransfer.png';
        break;
      default:
        imagePath = 'assets/images/banktransfer.png';
    }

    return Image.asset(
      imagePath,
      height: 40, // Reduced height for better proportion
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.payment, color: theme.colorScheme.primary, size: 40);
      },
    );
  }

  String _getPaymentTitle(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'payfast':
        return 'Credit & Debit Card';
      case 'pdo_zambia': // API returns "pdo_zambia"
        return 'Airtel & MTN Money';
      case 'pese': // API returns "pese"
        return 'Ecocash & InnBucks';
      case 'office_payment':
      case 'office':
      case 'cod':
        return 'Office Payment';
      case 'bank_transfer':
      case 'bank':
        return 'Bank Transfer';
      default:
        // Return the original title from API if we don't have a custom mapping
        return methodName;
    }
  }

  String _getPaymentDescription(String methodName) {
    switch (methodName.toLowerCase()) {
      case 'payfast':
        return 'Pay with Credit & Debit Card, Apple Pay, Samsung and more';
      case 'pdo_zambia': // API returns "pdo_zambia"
        return 'Pay with Airtel Money and MTN Money';
      case 'pese': // API returns "pese"
        return 'Pay with Ecocash, InnBucks & Zimswitch Card';
      case 'cod':
        return 'Pay with Cash or Card at the nearest Office';
      case 'bank_transfer':
        return 'You can pay with EFT or Direct Deposit into our FNB and CBZ account';
      default:
        return 'Payment method';
    }
  }

  List<PaymentMethodEntity> _filterAndOrderPaymentMethods(
    List<PaymentMethodEntity> methods,
  ) {
    // Define the desired order and filter out PayPal, Yoco and wallet
    final desiredOrder = [
      'payfast',
      'pdo_zambia', // Note: API returns "pdo_zambia" not "dpo_zambia"
      'pese', // Note: API returns "pese" not "pesepay"
      'office_payment',
      'office',
      'cash',
      'bank_transfer',
      'bank',
    ];

    // Debug: Print all available payment methods
    print('DEBUG: Available payment methods from API:');
    for (final method in methods) {
      print(
        ' - Name: "${method.name}", Title: "${method.title}", Status: ${method.status}',
      );
    }

    // Filter out PayPal, Yoco and wallet payment methods, keep all others
    final filteredMethods =
        methods.where((method) {
          final methodName = method.name.toLowerCase();
          return methodName != 'paypal' &&
              methodName != 'wallet' &&
              methodName != 'yoco';
        }).toList();

    print('DEBUG: After filtering, ${filteredMethods.length} methods remain');

    // Sort according to desired order
    filteredMethods.sort((a, b) {
      final aIndex = desiredOrder.indexOf(a.name.toLowerCase());
      final bIndex = desiredOrder.indexOf(b.name.toLowerCase());

      // If both are in the desired order, sort by their position
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }

      // If only one is in the desired order, prioritize it
      if (aIndex != -1) return -1;
      if (bIndex != -1) return 1;

      // If neither is in the desired order, maintain original order
      return 0;
    });

    print('DEBUG: Final ordered methods:');
    for (final method in filteredMethods) {
      print(' - ${method.name}');
    }

    return filteredMethods;
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
            'Failed to load payment methods',
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
