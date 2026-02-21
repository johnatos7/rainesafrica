import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/data/models/wishlist_model.dart';

abstract class WishlistLocalDataSource {
  Future<void> init();
  Future<List<WishlistModel>> getWishlists();
  Future<WishlistModel?> getWishlistById(String id);
  Future<WishlistModel> createWishlist(WishlistModel wishlist);
  Future<WishlistModel> updateWishlist(WishlistModel wishlist);
  Future<void> deleteWishlist(String id);
  Future<void> clearAllWishlists();
}

class WishlistLocalDataSourceImpl implements WishlistLocalDataSource {
  late Box<String> _box;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (!_initialized) {
      _box = await Hive.openBox<String>(AppConstants.wishlistBox);
      _initialized = true;
    }
  }

  @override
  Future<List<WishlistModel>> getWishlists() async {
    await init();
    try {
      final wishlistKeys = _box.keys.toList();
      final wishlists = <WishlistModel>[];

      for (final key in wishlistKeys) {
        final wishlistJson = _box.get(key);
        if (wishlistJson != null) {
          try {
            final wishlistMap =
                jsonDecode(wishlistJson) as Map<String, dynamic>;
            final wishlist = WishlistModel.fromJson(wishlistMap);
            wishlists.add(wishlist);
          } catch (e) {
            print('Error parsing wishlist $key: $e');
            // Skip corrupted entries
          }
        }
      }

      return wishlists;
    } catch (e) {
      throw Exception('Failed to get wishlists from Hive: $e');
    }
  }

  @override
  Future<WishlistModel?> getWishlistById(String id) async {
    await init();
    try {
      final wishlistJson = _box.get(id);
      if (wishlistJson != null) {
        final wishlistMap = jsonDecode(wishlistJson) as Map<String, dynamic>;
        return WishlistModel.fromJson(wishlistMap);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get wishlist by id from Hive: $e');
    }
  }

  @override
  Future<WishlistModel> createWishlist(WishlistModel wishlist) async {
    await init();
    try {
      final wishlistJson = jsonEncode(wishlist.toJson());
      await _box.put(wishlist.id, wishlistJson);
      return wishlist;
    } catch (e) {
      throw Exception('Failed to create wishlist in Hive: $e');
    }
  }

  @override
  Future<WishlistModel> updateWishlist(WishlistModel wishlist) async {
    await init();
    try {
      final wishlistJson = jsonEncode(wishlist.toJson());
      await _box.put(wishlist.id, wishlistJson);
      return wishlist;
    } catch (e) {
      throw Exception('Failed to update wishlist in Hive: $e');
    }
  }

  @override
  Future<void> deleteWishlist(String id) async {
    await init();
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete wishlist from Hive: $e');
    }
  }

  @override
  Future<void> clearAllWishlists() async {
    await init();
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to clear wishlists from Hive: $e');
    }
  }
}
