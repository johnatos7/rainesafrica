import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/responsive_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_badge_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_button.dart';

class ProductCard extends ConsumerWidget {
  final dynamic product;
  final VoidCallback? onTap;

  /// When true, the card fills available width (for use inside GridView).
  /// When false (default), the card uses a fixed width for horizontal lists.
  final bool isGridItem;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isGridItem = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardWidth =
        isGridItem ? null : ResponsiveUtils.productCardWidth(context);
    final imageHeight = ResponsiveUtils.productCardImageHeight(context);

    return InkWell(
      onTap: onTap ?? () => _navigateToProductDetails(context),
      child: Container(
        width: cardWidth,
        margin: isGridItem ? null : const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor, width: .5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image + Badges
            _buildImageSection(context, imageHeight),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rating
                    Builder(
                      builder: (context) {
                        final ratings = product.reviewRatings;
                        final totalReviews =
                            ratings.isNotEmpty
                                ? ratings.fold(0, (sum, count) => sum + count)
                                : 0;
                        final avgRating =
                            totalReviews > 0
                                ? ratings.asMap().entries.fold(
                                      0,
                                      (sum, entry) =>
                                          sum + (entry.value * (entry.key + 1)),
                                    ) /
                                    totalReviews
                                : 0.0;
                        if (totalReviews == 0) return const SizedBox.shrink();
                        return Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '($totalReviews)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),

                    // Price Row
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 6,
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            product.effectivePrice,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (product.isOnSale)
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              product.price,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    // Shipping / Delivery info
                    if (product.estimatedDeliveryText != null &&
                        (product.estimatedDeliveryText as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          product.estimatedDeliveryText as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Layby badge
                    LaybyBadgeWidget(
                      productPrice: product.effectivePrice,
                      threshold: AppConstants.laybyEligibilityThreshold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the image section. In grid mode, uses Expanded so the image
  /// fills the available flex space. In list mode, uses a fixed height.
  Widget _buildImageSection(BuildContext context, double imageHeight) {
    final imageStack = Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          product.productThumbnail.imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (context, _, __) => Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
        ),
        // Sale Badges
        if (product.isOnSale) ...[
          Positioned(
            left: 8,
            top: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadge('SALE', context),
                const SizedBox(height: 6),
                _buildBadge(
                  '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                  context,
                ),
              ],
            ),
          ),
        ],
        // Wishlist Button
        Positioned(
          right: 8,
          top: 8,
          child: WishlistButton(
            product: product,
            iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            activeColor: Theme.of(context).colorScheme.primary,
            iconSize: 24,
          ),
        ),
        // Image count badge (Takealot-style)
        Builder(
          builder: (context) {
            int imageCount = 0;
            if (product.productThumbnail != null) imageCount++;
            imageCount += (product.productGalleries.length as int);
            if (imageCount > 1) {
              return Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Color(0xFF555555),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$imageCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    return ClipRRect(
      child: SizedBox(
        height: imageHeight,
        width: double.infinity,
        child: imageStack,
      ),
    );
  }

  Widget _buildBadge(String text, BuildContext context) {
    return Container(
      height: text.length > 4 ? 40 : 20,
      width: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            text.length > 4
                ? Theme.of(context).colorScheme.primary
                : Colors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }
}
