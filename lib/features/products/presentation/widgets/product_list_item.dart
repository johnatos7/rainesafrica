import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

class ProductListItem extends ConsumerWidget {
  final dynamic product;
  final VoidCallback? onTap;

  const ProductListItem({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap ?? () => _navigateToProductDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image + Badges
            ClipRRect(
              child: SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.productThumbnail.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, _, __) => const Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Color(0xFFB0B0B0),
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
                            _buildBadge('SALE'),
                            const SizedBox(height: 4),
                            _buildBadge(
                              '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Wishlist Button
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Icon(
                        Icons.favorite_border,
                        size: 24,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            product.effectivePrice,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.isOnSale)
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              product.price,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9AA0A6),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showQuickAddToCart(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildBadge(String text) {
    return Container(
      height: text.length > 4 ? 40 : 20,
      width: 45,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: text.length > 4 ? const Color(0xFF2EA7FF) : Colors.green,
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

  void _showQuickAddToCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add "${product.name}" to cart?'),
                const SizedBox(height: 16),
                AddToCartButton(
                  product: product,
                  quantity: 1,
                  onAdded: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }
}
