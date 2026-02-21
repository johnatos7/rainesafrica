import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/providers/wishlist_providers.dart';

class WishlistIconWidget extends ConsumerWidget {
  final Color? iconColor;
  final Color? activeColor;
  final double? iconSize;

  const WishlistIconWidget({
    super.key,
    this.iconColor,
    this.activeColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistsAsync = ref.watch(wishlistsProvider);

    return wishlistsAsync.when(
      data: (wishlists) {
        final totalItems = wishlists.fold<int>(
          0,
          (sum, wishlist) => sum + wishlist.itemCount,
        );

        return Stack(
          children: [
            Icon(
              Icons.favorite_border,
              color: iconColor ?? Colors.grey,
              size: iconSize ?? 24,
            ),
            if (totalItems > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: activeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    totalItems > 99 ? '99+' : totalItems.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
      loading:
          () => Icon(
            Icons.favorite_border,
            color: iconColor ?? Colors.grey,
            size: iconSize ?? 24,
          ),
      error:
          (_, __) => Icon(
            Icons.favorite_border,
            color: iconColor ?? Colors.grey,
            size: iconSize ?? 24,
          ),
    );
  }
}
