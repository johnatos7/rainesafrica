import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/product_action_buttons.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';

class OrderProductsList extends StatelessWidget {
  final List<OrderProductEntity> products;
  final String currencySymbol;
  final double orderExchangeRate;
  final int orderId;
  final int consumerId;
  final bool showActionButtons;
  final String? orderStatusName;

  const OrderProductsList({
    super.key,
    required this.products,
    this.currencySymbol = '\$',
    required this.orderExchangeRate,
    required this.orderId,
    required this.consumerId,
    this.showActionButtons = true,
    this.orderStatusName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
        ),
        child: Column(
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No products found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ordered Products',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${products.length} item${products.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Products List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(context, theme, colors, product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    OrderProductEntity product,
  ) {
    return InkWell(
      onTap: () {
        // Create a minimal ProductEntity from the order product for navigation
        final productEntity = ProductEntity(
          id: product.id,
          name: product.name,
          slug: '',
          price: product.pivot.singlePrice,
          productGalleries:
              product.productGalleries
                  .map(
                    (g) => ProductImageEntity(
                      id: g.id,
                      imageUrl: g.imageUrl,
                      originalUrl: g.originalUrl,
                    ),
                  )
                  .toList(),
          productThumbnail:
              product.productThumbnail != null
                  ? ProductImageEntity(
                    id: product.productThumbnail!.id,
                    imageUrl: product.productThumbnail!.imageUrl,
                    originalUrl: product.productThumbnail!.originalUrl,
                  )
                  : null,
          reviewRatings: product.reviewRatings,
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: productEntity),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        product.productThumbnail != null
                            ? Image.network(
                              product.productThumbnail!.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_outlined,
                                  color: colors.onSurface.withOpacity(0.4),
                                  size: 24,
                                );
                              },
                            )
                            : Icon(
                              Icons.image_outlined,
                              color: colors.onSurface.withOpacity(0.4),
                              size: 24,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Variation name (if present)
                      if (_getVariationName(product) != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: colors.outline.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getVariationName(product)!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurface.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Qty: ${product.pivot.quantity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Price: ${(product.pivot.singlePrice * orderExchangeRate).toStringAsFixed(2)} ${_getCurrencySymbol(product)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal: ${(product.pivot.subtotal * orderExchangeRate).toStringAsFixed(2)} ${_getCurrencySymbol(product)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                          if (product.pivot.shippingCost > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '+ Shipping',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Per-item Status & ETA row
            // Hide entire section when order status is "Ready for Collection"
            if (!_isReadyForCollection())
              if ((product.pivot.itemStatus != null &&
                      product.pivot.itemStatus!.trim().isNotEmpty) ||
                  (product.pivot.eta != null &&
                      product.pivot.eta!.trim().isNotEmpty &&
                      !_isTerminalStatus(product.pivot.itemStatus))) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.outline.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status row
                      if (product.pivot.itemStatus != null &&
                          product.pivot.itemStatus!.trim().isNotEmpty) ...[
                        _buildStatusRow(
                          product.pivot.itemStatus!,
                          colors,
                          theme,
                        ),
                      ],
                      // ETA row – hidden once order is collected or delivered
                      if (product.pivot.eta != null &&
                          product.pivot.eta!.trim().isNotEmpty &&
                          !_isTerminalStatus(product.pivot.itemStatus)) ...[
                        if (product.pivot.itemStatus != null &&
                            product.pivot.itemStatus!.trim().isNotEmpty)
                          const SizedBox(height: 8),
                        _buildEtaRow(product.pivot.eta!, colors, theme),
                      ],
                    ],
                  ),
                ),
              ],
            const SizedBox(height: 12),
            ProductActionButtons(
              orderId: orderId,
              consumerId: consumerId,
              product: product,
              currencySymbol: currencySymbol,
              showActions: showActionButtons,
            ),
          ],
        ),
      ),
    );
  }

  /// Returns true if the order-level status is "Ready for Collection".
  bool _isReadyForCollection() {
    if (orderStatusName == null) return false;
    return orderStatusName!.toLowerCase().trim().contains(
      'ready for collection',
    );
  }

  /// Returns true if the item status indicates the order is completed
  /// (collected or delivered), meaning ETA is no longer relevant.
  bool _isTerminalStatus(String? itemStatus) {
    // Check per-item status
    if (itemStatus != null && itemStatus.trim().isNotEmpty) {
      final s = itemStatus.toLowerCase().trim();
      if (s.contains('ready for collection') ||
          s.contains('deliver') ||
          s.contains('collected')) {
        return true;
      }
    }
    // Check order-level status
    if (orderStatusName != null && orderStatusName!.trim().isNotEmpty) {
      final o = orderStatusName!.toLowerCase().trim();
      if (o.contains('ready for collection') ||
          o.contains('deliver') ||
          o.contains('collected')) {
        return true;
      }
    }
    return false;
  }

  Widget _buildStatusRow(String status, ColorScheme colors, ThemeData theme) {
    final statusLower = status.toLowerCase().trim();
    Color statusColor;
    IconData statusIcon;

    if (statusLower.contains('deliver') || statusLower.contains('collected')) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (statusLower.contains('transit') ||
        statusLower.contains('shipped') ||
        statusLower.contains('dispatched')) {
      statusColor = Colors.blue;
      statusIcon = Icons.local_shipping_outlined;
    } else if (statusLower.contains('ready') ||
        statusLower.contains('collection')) {
      statusColor = Colors.orange;
      statusIcon = Icons.store_outlined;
    } else if (statusLower.contains('cancel') ||
        statusLower.contains('refund')) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    } else if (statusLower.contains('packing') ||
        statusLower.contains('warehouse')) {
      statusColor = Colors.teal;
      statusIcon = Icons.inventory_2_outlined;
    } else {
      statusColor = Colors.indigo;
      statusIcon = Icons.hourglass_top_outlined;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(statusIcon, size: 16, color: statusColor),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colors.onSurface,
              ),
              children: [
                const TextSpan(
                  text: 'Status: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: _titleCase(status),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEtaRow(String eta, ColorScheme colors, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.calendar_today_outlined, size: 16, color: colors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colors.onSurface,
              ),
              children: [
                const TextSpan(
                  text: 'Est. Date of Arrival: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: _formatEtaDate(eta),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatEtaDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('EEEE, dd MMMM yyyy').format(dt);
    } catch (_) {
      return raw; // fallback to raw string if parsing fails
    }
  }

  String _titleCase(String text) {
    return text
        .split(' ')
        .map(
          (w) =>
              w.isNotEmpty
                  ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
                  : '',
        )
        .join(' ');
  }

  String _getCurrencySymbol(OrderProductEntity product) {
    // Use the currency symbol passed from the parent widget
    return currencySymbol;
  }

  String? _getVariationName(OrderProductEntity product) {
    try {
      // First, check if variation_display_name is available (most direct and accurate)
      if (product.pivot.variationDisplayName != null &&
          product.pivot.variationDisplayName!.trim().isNotEmpty) {
        return product.pivot.variationDisplayName;
      }

      // Fallback to existing logic
      final variationId = product.pivot.variationId;
      if (variationId == null) return null;

      // variations is a List<dynamic> with maps that include id and name
      for (final v in product.variations) {
        if (v is Map<String, dynamic>) {
          final id = v['id'];
          if (id == variationId) {
            final name = v['name'] as String?;
            if (name != null && name.trim().isNotEmpty) return name;

            // Fallback: build from attribute_values if name missing
            final attrs = v['attribute_values'] as List<dynamic>?;
            if (attrs != null && attrs.isNotEmpty) {
              final values =
                  attrs
                      .whereType<Map<String, dynamic>>()
                      .map((a) => (a['value'] as String?)?.trim())
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .toList();
              if (values.isNotEmpty) return values.join(' / ');
            }
            return null;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
