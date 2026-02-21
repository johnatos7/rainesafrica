import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase {
  final WishlistRepository _repository;

  RemoveFromWishlistUseCase(this._repository);

  Future<WishlistEntity> call(String wishlistId, String productId) async {
    return await _repository.removeProductFromWishlist(wishlistId, productId);
  }
}
