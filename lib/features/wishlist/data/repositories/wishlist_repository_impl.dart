import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/datasources/wishlist_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/models/wishlist_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:uuid/uuid.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final WishlistLocalDataSource _localDataSource;
  // ignore: unused_field
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<List<WishlistEntity>> getWishlists() async {
    try {
      // Try to get from local storage first
      final localWishlists = await _localDataSource.getWishlists();

      // If no local wishlists exist, create a default one
      if (localWishlists.isEmpty) {
        final defaultWishlist = WishlistModel(
          id: const Uuid().v4(),
          name: 'My Wishlist',
          description: 'Default wishlist',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isDefault: true,
        );
        await _localDataSource.createWishlist(defaultWishlist);
        return [defaultWishlist.toEntity()];
      }

      return localWishlists.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to creating a default wishlist
      final defaultWishlist = WishlistModel(
        id: const Uuid().v4(),
        name: 'My Wishlist',
        description: 'Default wishlist',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      );
      await _localDataSource.createWishlist(defaultWishlist);
      return [defaultWishlist.toEntity()];
    }
  }

  @override
  Future<WishlistEntity> getWishlistById(String id) async {
    final wishlist = await _localDataSource.getWishlistById(id);
    if (wishlist == null) {
      throw Exception('Wishlist not found');
    }
    return wishlist.toEntity();
  }

  @override
  Future<WishlistEntity> createWishlist(
    String name, {
    String? description,
  }) async {
    final wishlist = WishlistModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      items: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDefault: false,
    );

    final createdWishlist = await _localDataSource.createWishlist(wishlist);
    return createdWishlist.toEntity();
  }

  @override
  Future<WishlistEntity> updateWishlist(
    String id,
    String name, {
    String? description,
  }) async {
    final existingWishlist = await _localDataSource.getWishlistById(id);
    if (existingWishlist == null) {
      throw Exception('Wishlist not found');
    }

    final updatedWishlist = WishlistModel(
      id: id,
      name: name,
      description: description,
      items: existingWishlist.items,
      createdAt: existingWishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: existingWishlist.isDefault,
    );

    final result = await _localDataSource.updateWishlist(updatedWishlist);
    return result.toEntity();
  }

  @override
  Future<void> deleteWishlist(String id) async {
    final wishlist = await _localDataSource.getWishlistById(id);
    if (wishlist == null) {
      throw Exception('Wishlist not found');
    }

    if (wishlist.isDefault == true) {
      throw Exception('Cannot delete default wishlist');
    }

    await _localDataSource.deleteWishlist(id);
  }

  @override
  Future<void> renameWishlist(String id, String newName) async {
    final existingWishlist = await _localDataSource.getWishlistById(id);
    if (existingWishlist == null) {
      throw Exception('Wishlist not found');
    }

    final updatedWishlist = WishlistModel(
      id: id,
      name: newName,
      description: existingWishlist.description,
      items: existingWishlist.items,
      createdAt: existingWishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: existingWishlist.isDefault,
    );

    await _localDataSource.updateWishlist(updatedWishlist);
  }

  @override
  Future<WishlistEntity> addProductToWishlist(
    String wishlistId,
    ProductEntity product, {
    String? notes,
  }) async {
    final wishlist = await _localDataSource.getWishlistById(wishlistId);
    if (wishlist == null) {
      throw Exception('Wishlist not found');
    }

    // Check if product is already in the wishlist
    final existingItem = wishlist.items?.firstWhere(
      (item) => item.product?.id == product.id,
      orElse: () => const WishlistItemModel(),
    );

    if (existingItem?.id != null) {
      throw Exception('Product is already in this wishlist');
    }

    final newItem = WishlistItemModel(
      id: const Uuid().v4(),
      wishlistId: wishlistId,
      product: ProductModel.fromEntity(product),
      addedAt: DateTime.now(),
      notes: notes,
    );

    final updatedItems = <WishlistItemModel>[
      ...(wishlist.items ?? []),
      newItem,
    ];
    final updatedWishlist = WishlistModel(
      id: wishlistId,
      name: wishlist.name,
      description: wishlist.description,
      items: updatedItems,
      createdAt: wishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: wishlist.isDefault,
    );

    final result = await _localDataSource.updateWishlist(updatedWishlist);
    return result.toEntity();
  }

  @override
  Future<WishlistEntity> removeProductFromWishlist(
    String wishlistId,
    String productId,
  ) async {
    final wishlist = await _localDataSource.getWishlistById(wishlistId);
    if (wishlist == null) {
      throw Exception('Wishlist not found');
    }

    final updatedItems =
        wishlist.items
            ?.where((item) => item.product?.id.toString() != productId)
            .toList() ??
        [];

    final updatedWishlist = WishlistModel(
      id: wishlistId,
      name: wishlist.name,
      description: wishlist.description,
      items: updatedItems,
      createdAt: wishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: wishlist.isDefault,
    );

    final result = await _localDataSource.updateWishlist(updatedWishlist);
    return result.toEntity();
  }

  @override
  Future<WishlistEntity> moveProductToWishlist(
    String productId,
    String fromWishlistId,
    String toWishlistId,
  ) async {
    // Remove from source wishlist
    await removeProductFromWishlist(fromWishlistId, productId);

    // Get the product from the source wishlist before removal
    final sourceWishlistModel = await _localDataSource.getWishlistById(
      fromWishlistId,
    );
    final itemToMove = sourceWishlistModel?.items?.firstWhere(
      (item) => item.product?.id.toString() == productId,
      orElse: () => const WishlistItemModel(),
    );

    if (itemToMove?.product == null) {
      throw Exception('Product not found in source wishlist');
    }

    // Add to destination wishlist
    final productEntity = itemToMove!.product!.toEntity();
    return await addProductToWishlist(
      toWishlistId,
      productEntity,
      notes: itemToMove.notes,
    );
  }

  @override
  Future<WishlistEntity> updateWishlistItemNotes(
    String wishlistId,
    String productId,
    String? notes,
  ) async {
    final wishlist = await _localDataSource.getWishlistById(wishlistId);
    if (wishlist == null) {
      throw Exception('Wishlist not found');
    }

    final updatedItems =
        wishlist.items?.map((item) {
          if (item.product?.id.toString() == productId) {
            return WishlistItemModel(
              id: item.id,
              wishlistId: item.wishlistId,
              product: item.product,
              addedAt: item.addedAt,
              notes: notes,
            );
          }
          return item;
        }).toList() ??
        [];

    final updatedWishlist = WishlistModel(
      id: wishlistId,
      name: wishlist.name,
      description: wishlist.description,
      items: updatedItems,
      createdAt: wishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: wishlist.isDefault,
    );

    final result = await _localDataSource.updateWishlist(updatedWishlist);
    return result.toEntity();
  }

  @override
  Future<bool> isProductInWishlist(
    String productId, {
    String? wishlistId,
  }) async {
    if (wishlistId != null) {
      final wishlist = await _localDataSource.getWishlistById(wishlistId);
      if (wishlist == null) return false;

      return wishlist.items?.any(
            (item) => item.product?.id.toString() == productId,
          ) ??
          false;
    } else {
      final wishlists = await _localDataSource.getWishlists();
      return wishlists.any(
        (wishlist) =>
            wishlist.items?.any(
              (item) => item.product?.id.toString() == productId,
            ) ??
            false,
      );
    }
  }

  @override
  Future<List<WishlistEntity>> getWishlistsContainingProduct(
    String productId,
  ) async {
    final wishlists = await _localDataSource.getWishlists();
    final containingWishlists =
        wishlists
            .where(
              (wishlist) =>
                  wishlist.items?.any(
                    (item) => item.product?.id.toString() == productId,
                  ) ??
                  false,
            )
            .toList();

    return containingWishlists.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> clearWishlist(String wishlistId) async {
    final wishlist = await _localDataSource.getWishlistById(wishlistId);
    if (wishlist == null) {
      throw Exception('Wishlist not found');
    }

    final clearedWishlist = WishlistModel(
      id: wishlistId,
      name: wishlist.name,
      description: wishlist.description,
      items: [],
      createdAt: wishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: wishlist.isDefault,
    );

    await _localDataSource.updateWishlist(clearedWishlist);
  }

  @override
  Future<void> clearAllWishlists() async {
    await _localDataSource.clearAllWishlists();
  }

  @override
  Future<WishlistEntity> getDefaultWishlist() async {
    final wishlists = await _localDataSource.getWishlists();
    final defaultWishlist = wishlists.firstWhere(
      (wishlist) => wishlist.isDefault == true,
      orElse: () => throw Exception('No default wishlist found'),
    );
    return defaultWishlist.toEntity();
  }

  @override
  Future<WishlistEntity> setDefaultWishlist(String id) async {
    final wishlists = await _localDataSource.getWishlists();

    // Remove default flag from all wishlists
    for (final wishlist in wishlists) {
      if (wishlist.isDefault == true) {
        final updatedWishlist = WishlistModel(
          id: wishlist.id,
          name: wishlist.name,
          description: wishlist.description,
          items: wishlist.items,
          createdAt: wishlist.createdAt,
          updatedAt: DateTime.now(),
          isDefault: false,
        );
        await _localDataSource.updateWishlist(updatedWishlist);
      }
    }

    // Set the specified wishlist as default
    final targetWishlist = await _localDataSource.getWishlistById(id);
    if (targetWishlist == null) {
      throw Exception('Wishlist not found');
    }

    final defaultWishlist = WishlistModel(
      id: id,
      name: targetWishlist.name,
      description: targetWishlist.description,
      items: targetWishlist.items,
      createdAt: targetWishlist.createdAt,
      updatedAt: DateTime.now(),
      isDefault: true,
    );

    final result = await _localDataSource.updateWishlist(defaultWishlist);
    return result.toEntity();
  }
}
