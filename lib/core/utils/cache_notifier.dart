import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

/// A simple cache notifier that stores data in memory
class CacheNotifier<T> extends StateNotifier<Map<String, T>> {
  CacheNotifier() : super({});

  void put(String key, T value) {
    state = {...state, key: value};
  }

  T? get(String key) => state[key];

  void remove(String key) {
    state = {...state}..remove(key);
  }

  void clear() {
    state = {};
  }
}

/// Provider for product cache
final productCacheProvider = StateNotifierProvider<
  CacheNotifier<List<ProductEntity>>,
  Map<String, List<ProductEntity>>
>((ref) => CacheNotifier<List<ProductEntity>>());
