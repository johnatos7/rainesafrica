import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/providers/wishlist_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/add_to_wishlist_dialog.dart';

class WishlistButton extends ConsumerWidget {
  final dynamic product;
  final Color? iconColor;
  final Color? activeColor;
  final double? iconSize;
  final bool showSnackbar;

  const WishlistButton({
    super.key,
    required this.product,
    this.iconColor,
    this.activeColor,
    this.iconSize,
    this.showSnackbar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWishlistAsync = ref.watch(
      isProductInWishlistProvider(product.id.toString()),
    );

    return isInWishlistAsync.when(
      data:
          (isInWishlist) => IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color:
                  isInWishlist
                      ? (activeColor ?? Colors.red)
                      : (iconColor ?? Colors.grey),
              size: iconSize ?? 24,
            ),
            onPressed: () => _handleWishlistAction(context, ref, isInWishlist),
            tooltip: isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
          ),
      loading:
          () => IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor ?? Colors.grey,
              size: iconSize ?? 24,
            ),
            onPressed: null,
          ),
      error:
          (_, __) => IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor ?? Colors.grey,
              size: iconSize ?? 24,
            ),
            onPressed: () => _handleWishlistAction(context, ref, false),
          ),
    );
  }

  void _handleWishlistAction(
    BuildContext context,
    WidgetRef ref,
    bool isInWishlist,
  ) {
    if (isInWishlist) {
      _removeFromWishlist(context, ref);
    } else {
      _showAddToWishlistDialog(context, ref);
    }
  }

  void _showAddToWishlistDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToWishlistDialog(product: product),
    );
  }

  void _removeFromWishlist(BuildContext context, WidgetRef ref) async {
    try {
      // Get wishlists containing this product
      final repository = ref.read(wishlistRepositoryProvider);
      final wishlistsContainingProduct = await repository
          .getWishlistsContainingProduct(product.id.toString());

      if (wishlistsContainingProduct.isEmpty) {
        if (showSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found in any wishlist')),
          );
        }
        return;
      }

      // Remove from all wishlists containing the product
      for (final wishlist in wishlistsContainingProduct) {
        await ref.read(
          removeFromWishlistProvider((
            wishlistId: wishlist.id,
            productId: product.id.toString(),
          )).future,
        );
      }

      ref.invalidate(isProductInWishlistProvider(product.id.toString()));
      ref.invalidate(wishlistsProvider);

      if (showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from wishlist'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from wishlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
