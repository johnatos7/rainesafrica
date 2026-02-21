import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';

class DeleteWishlistUseCase {
  final WishlistRepository _repository;

  DeleteWishlistUseCase(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteWishlist(id);
  }
}
