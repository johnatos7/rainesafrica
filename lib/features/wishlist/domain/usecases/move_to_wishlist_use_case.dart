import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';

class MoveToWishlistUseCase {
  final WishlistRepository _repository;

  MoveToWishlistUseCase(this._repository);

  Future<WishlistEntity> call(
    String productId,
    String fromWishlistId,
    String toWishlistId,
  ) async {
    if (fromWishlistId == toWishlistId) {
      throw ArgumentError(
        'Source and destination wishlists cannot be the same',
      );
    }

    return await _repository.moveProductToWishlist(
      productId,
      fromWishlistId,
      toWishlistId,
    );
  }
}
