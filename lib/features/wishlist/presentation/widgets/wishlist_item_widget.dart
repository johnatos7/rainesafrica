import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/responsive_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';

class WishlistItemWidget extends ConsumerWidget {
  final dynamic item;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveToCart;

  const WishlistItemWidget({
    super.key,
    required this.item,
    this.onRemove,
    this.onMoveToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetails(context, product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: ResponsiveUtils.cartItemImageSize(context),
                  height: ResponsiveUtils.cartItemImageSize(context),
                  child: Image.network(
                    product.productThumbnail.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, _, __) => Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.image,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            size: 30,
                          ),
                        ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Product Price
                    Text(
                      ref.watch(currencyFormattingProvider)(
                        product.effectivePrice,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Added date
                    Text(
                      'Added ${_formatDate(item.addedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),

                    // Notes if available
                    if (item.notes != null && item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${item.notes}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  // Remove button
                  IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    onPressed: onRemove,
                    tooltip: 'Remove from wishlist',
                  ),

                  // Move to cart button
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: onMoveToCart,
                    tooltip: 'Move to cart',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context, dynamic product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}
