import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlistsUseCase {
  final WishlistRepository _repository;

  GetWishlistsUseCase(this._repository);

  Future<List<WishlistEntity>> call() async {
    return await _repository.getWishlists();
  }
}
