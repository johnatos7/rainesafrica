import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';

class CreateWishlistUseCase {
  final WishlistRepository _repository;

  CreateWishlistUseCase(this._repository);

  Future<WishlistEntity> call(String name, {String? description}) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Wishlist name cannot be empty');
    }
    return await _repository.createWishlist(
      name.trim(),
      description: description?.trim(),
    );
  }
}
