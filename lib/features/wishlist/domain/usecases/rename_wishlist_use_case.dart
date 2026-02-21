import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';

class RenameWishlistUseCase {
  final WishlistRepository _repository;

  RenameWishlistUseCase(this._repository);

  Future<void> call(String id, String newName) async {
    if (newName.trim().isEmpty) {
      throw ArgumentError('Wishlist name cannot be empty');
    }
    return await _repository.renameWishlist(id, newName.trim());
  }
}
