import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  // Wishlist management
  Future<List<WishlistEntity>> getWishlists();
  Future<WishlistEntity> getWishlistById(String id);
  Future<WishlistEntity> createWishlist(String name, {String? description});
  Future<WishlistEntity> updateWishlist(
    String id,
    String name, {
    String? description,
  });
  Future<void> deleteWishlist(String id);
  Future<void> renameWishlist(String id, String newName);

  // Wishlist items management
  Future<WishlistEntity> addProductToWishlist(
    String wishlistId,
    ProductEntity product, {
    String? notes,
  });
  Future<WishlistEntity> removeProductFromWishlist(
    String wishlistId,
    String productId,
  );
  Future<WishlistEntity> moveProductToWishlist(
    String productId,
    String fromWishlistId,
    String toWishlistId,
  );
  Future<WishlistEntity> updateWishlistItemNotes(
    String wishlistId,
    String productId,
    String? notes,
  );

  // Utility methods
  Future<bool> isProductInWishlist(String productId, {String? wishlistId});
  Future<List<WishlistEntity>> getWishlistsContainingProduct(String productId);
  Future<void> clearWishlist(String wishlistId);
  Future<void> clearAllWishlists();

  // Default wishlist management
  Future<WishlistEntity> getDefaultWishlist();
  Future<WishlistEntity> setDefaultWishlist(String id);
}
