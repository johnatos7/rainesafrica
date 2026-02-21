import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/providers/points_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/providers/checkout_providers.dart';

class CheckoutSummarySection extends ConsumerWidget {
  final CartEntity cart;
  final double shippingCost;

  const CheckoutSummarySection({
    super.key,
    required this.cart,
    required this.shippingCost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = ref.watch(currencyFormattingProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final subtotal = cart.calculatedSubtotal;
    final tax = 0.0;
    // Determine free shipping threshold at USD 100 equivalent
    final currencyState = ref.watch(currencyProvider);
    final exchangeRate =
        currencyState.selectedCurrency?.exchangeRateAsDouble ?? 1.0;
    final subtotalInUsd = subtotal / exchangeRate;

    // Shipping fee: applies only if subtotal (USD) < 100; fixed $10 USD
    // Keep this value in USD and let the formatter handle conversion
    const double defaultUsdShipping = 10.0;
    final double shippingFee =
        subtotal >= 100.0 ? 0.0 : defaultUsdShipping;

    // Delivery fee: comes from selected shipping option price passed in as shippingCost
    final double deliveryFee = shippingCost;

    // Fast shipping fee: calculated from cart items with expedited shipping
    final double fastShippingFee = cart.calculatedExpeditedShippingFee;

    final total = subtotal + tax + shippingFee + deliveryFee + fastShippingFee;

    final walletState = ref.watch(walletProvider);
    final pointsState = ref.watch(pointsProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    final checkoutState = ref.watch(checkoutProvider);

    // Compute payable total after applying points and wallet (if enabled)
    double payableTotal = total;
    final settingsValue = settingsAsync.hasValue ? settingsAsync.value : null;
    if (settingsValue != null) {
      final ratio =
          double.tryParse(settingsValue.walletPoints.pointCurrencyRatio) ?? 0.0;
      final availablePoints = pointsState.points?.balance ?? 0.0;
      final pointsValue = ratio > 0 ? (availablePoints / ratio) : 0.0;
      final walletBalance = walletState.wallet?.balance ?? 0.0;

      final pointsApplied =
          checkoutState.usePoints ? pointsValue.clamp(0.0, total) : 0.0;
      final remainingAfterPoints = (total - pointsApplied).clamp(
        0.0,
        double.infinity,
      );
      final walletApplied =
          checkoutState.useWallet
              ? walletBalance.clamp(0.0, remainingAfterPoints)
              : 0.0;

      payableTotal = (total - pointsApplied - walletApplied).clamp(
        0.0,
        double.infinity,
      );
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildCartItems(context),

            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 16),

            _buildPriceBreakdown(
              context,
              formatCurrency,
              subtotal,
              tax,
              shippingFee,
              deliveryFee,
              fastShippingFee,
            ),

            const SizedBox(height: 16),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 16),

            // Points & Wallet usage controls and info
            settingsAsync.when(
              data: (settings) {
                final ratio =
                    double.tryParse(settings.walletPoints.pointCurrencyRatio) ??
                    0.0;
                final availablePoints = pointsState.points?.balance ?? 0.0;
                final pointsValue = ratio > 0 ? (availablePoints / ratio) : 0.0;
                final walletBalance = walletState.wallet?.balance ?? 0.0;

                // Compute remaining wallet balance after applying points first, then wallet
                final pointsApplied =
                    checkoutState.usePoints
                        ? pointsValue.clamp(0.0, total)
                        : 0.0;
                final remainingAfterPoints = (total - pointsApplied).clamp(
                  0.0,
                  double.infinity,
                );
                final walletApplied =
                    checkoutState.useWallet
                        ? walletBalance.clamp(0.0, remainingAfterPoints)
                        : 0.0;
                final walletBalanceAfter = (walletBalance - walletApplied)
                    .clamp(0.0, double.infinity);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Points', style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available: ${availablePoints.toStringAsFixed(0)}',
                        ),
                        Text('Equivalence: ' + formatCurrency(pointsValue)),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use Points'),
                      value: checkoutState.usePoints,
                      onChanged:
                          (availablePoints <= 0.0 || ratio <= 0.0)
                              ? null
                              : (v) => checkoutNotifier.setUsePoints(v),
                    ),
                    const SizedBox(height: 8),
                    Text('Wallet', style: textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available: ' + formatCurrency(walletBalance)),
                        Text(
                          'Balance after: ' +
                              formatCurrency(walletBalanceAfter),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Use Wallet Credit'),
                      value: checkoutState.useWallet,
                      onChanged:
                          walletBalance <= 0.0
                              ? null
                              : (v) => checkoutNotifier.setUseWallet(v),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Theme.of(context).dividerColor, height: 1),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            _buildTotal(formatCurrency, payableTotal, context),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${cart.items.length})',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...cart.items.take(3).map((item) => _buildCartItem(item, context)),
        if (cart.items.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '+ ${cart.items.length - 3} more items',
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartItem(CartItemEntity item, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final hasFastShipping = item.itemShippingMethod == 'expedited';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child:
                (item.product?.productThumbnail?.imageUrl.isNotEmpty ?? false)
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        item.product!.productThumbnail!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Icon(
                              Icons.image,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                      ),
                    )
                    : Icon(
                      Icons.image,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.product?.name ?? 'Product',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasFastShipping)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Fast',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // Show variation if available
                if (item.variationDisplayName != null || item.selectedVariation != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.variationDisplayName ?? item.selectedVariation ?? '',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Qty: ${item.quantity}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final formatCurrency = ref.watch(currencyFormattingProvider);
              return Text(
                formatCurrency(item.totalPrice),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(
    BuildContext context,
    String Function(double) formatCurrency,
    double subtotal,
    double tax,
    double shippingFee,
    double deliveryFee,
    double fastShippingFee,
  ) {
    return Column(
      children: [
        _buildPriceRow(context, 'Subtotal', formatCurrency(subtotal)),
        _buildPriceRow(
          context,
          'Shipping',
          shippingFee == 0 ? 'FREE' : formatCurrency(shippingFee),
          isFree: shippingFee == 0,
        ),
        _buildPriceRow(
          context,
          'Delivery Fee',
          deliveryFee == 0 ? 'FREE' : formatCurrency(deliveryFee),
          isFree: deliveryFee == 0,
        ),
        if (fastShippingFee > 0)
          _buildFastShippingFeeRow(
            context,
            'Fast Shipping Fee',
            formatCurrency(fastShippingFee),
          ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isFree = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isFree ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFastShippingFeeRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                onPressed: () => _showFastShippingHelpDialog(context),
                icon: Icon(Icons.help_outline, color: colorScheme.primary),
                label: Text(
                  'WTF',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showFastShippingHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return AlertDialog(
          title: Text(
            'Why am I being charged a Fast Shipping Fee?',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This fee applies when you\'ve selected Fast Shipping for one or more items in your order.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'At Raines Africa, standard delivery is free and takes 7–14 days using our own trucks from Johannesburg. For faster delivery (3–5 days), we use third-party couriers, which comes with a small extra fee to cover freight and insurance costs.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotal(
    String Function(double) formatCurrency,
    double total,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            formatCurrency(total),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
