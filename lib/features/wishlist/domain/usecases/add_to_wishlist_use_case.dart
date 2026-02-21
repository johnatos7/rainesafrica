import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

class AddToWishlistUseCase {
  final WishlistRepository _repository;

  AddToWishlistUseCase(this._repository);

  Future<WishlistEntity> call(
    String wishlistId,
    ProductEntity product, {
    String? notes,
  }) async {
    // Check if product is already in the wishlist
    final isInWishlist = await _repository.isProductInWishlist(
      product.id.toString(),
      wishlistId: wishlistId,
    );
    if (isInWishlist) {
      throw Exception('Product is already in this wishlist');
    }

    return await _repository.addProductToWishlist(
      wishlistId,
      product,
      notes: notes,
    );
  }
}
