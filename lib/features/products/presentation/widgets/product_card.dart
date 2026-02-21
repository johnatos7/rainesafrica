import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_badge_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_button.dart';

class ProductCard extends ConsumerWidget {
  final dynamic product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap ?? () => _navigateToProductDetails(context),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          // borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor, width: .5),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0x11000000),
          //     blurRadius: 4,
          //     offset: Offset(0, 1),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image + Badges
            ClipRRect(
              // borderRadius: const BorderRadius.only(
              //   topLeft: Radius.circular(8),
              //   topRight: Radius.circular(8),
              // ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
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
                        iconColor: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        activeColor: Theme.of(context).colorScheme.primary,
                        iconSize: 24,
                      ),
                    ),
                    // Quick Add to Cart Button
                    // Positioned(
                    //   right: 8,
                    //   bottom: 8,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.blue,
                    //       shape: BoxShape.circle,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black.withOpacity(0.1),
                    //           blurRadius: 4,
                    //           offset: const Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //     child: IconButton(
                    //       onPressed: () => _showQuickAddToCart(context, ref),
                    //       icon: const Icon(
                    //         Icons.add_shopping_cart,
                    //         size: 18,
                    //         color: Colors.white,
                    //       ),
                    //       padding: const EdgeInsets.all(6),
                    //       constraints: const BoxConstraints(
                    //         minWidth: 32,
                    //         minHeight: 32,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

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
                    const SizedBox(height: 2),

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
                    const SizedBox(height: 1),

                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            product.effectivePrice,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (product.isOnSale)
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              product.price,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
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
