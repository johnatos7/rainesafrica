import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistModel>> getWishlists();
  Future<WishlistModel> getWishlistById(String id);
  Future<WishlistModel> createWishlist(WishlistModel wishlist);
  Future<WishlistModel> updateWishlist(WishlistModel wishlist);
  Future<void> deleteWishlist(String id);
  Future<WishlistModel> addProductToWishlist(
    String wishlistId,
    int productId, {
    String? notes,
  });
  Future<WishlistModel> removeProductFromWishlist(
    String wishlistId,
    int productId,
  );
  Future<WishlistModel> moveProductToWishlist(
    int productId,
    String fromWishlistId,
    String toWishlistId,
  );
  Future<WishlistModel> updateWishlistItemNotes(
    String wishlistId,
    int productId,
    String? notes,
  );
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  // TODO: Implement actual API calls when backend is ready
  // For now, this will throw UnimplementedError

  @override
  Future<List<WishlistModel>> getWishlists() async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> getWishlistById(String id) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> createWishlist(WishlistModel wishlist) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> updateWishlist(WishlistModel wishlist) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<void> deleteWishlist(String id) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> addProductToWishlist(
    String wishlistId,
    int productId, {
    String? notes,
  }) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> removeProductFromWishlist(
    String wishlistId,
    int productId,
  ) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> moveProductToWishlist(
    int productId,
    String fromWishlistId,
    String toWishlistId,
  ) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }

  @override
  Future<WishlistModel> updateWishlistItemNotes(
    String wishlistId,
    int productId,
    String? notes,
  ) async {
    throw UnimplementedError('Remote wishlist API not implemented yet');
  }
}
