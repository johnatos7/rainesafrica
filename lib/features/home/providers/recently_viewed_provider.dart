import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/services/recently_viewed_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

/// Singleton service provider.
final recentlyViewedServiceProvider = Provider<RecentlyViewedService>(
  (_) => RecentlyViewedService(),
);

/// StateNotifier that manages the in-memory list of recently viewed items
/// while persisting to SharedPreferences via [RecentlyViewedService].
class RecentlyViewedNotifier extends StateNotifier<List<RecentlyViewedItem>> {
  final RecentlyViewedService _service;

  RecentlyViewedNotifier(this._service) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.getAll();
  }

  /// Record a product view from a [ProductEntity].
  Future<void> trackView(ProductEntity product) async {
    final thumbnail =
        product.productThumbnail?.imageUrl ??
        (product.productGalleries.isNotEmpty
            ? product.productGalleries.first.imageUrl
            : '');

    final item = RecentlyViewedItem(
      productId: product.id,
      name: product.name,
      slug: product.slug,
      price: product.price,
      salePrice: product.salePrice,
      discount: product.discount,
      imageUrl: thumbnail,
      reviewRatings: product.reviewRatings,
      viewedAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = await _service.addView(item);
  }

  /// Clear all recently viewed items.
  Future<void> clearAll() async {
    await _service.clearAll();
    state = [];
  }
}

/// Provider for [RecentlyViewedNotifier].
final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<RecentlyViewedItem>>(
      (ref) => RecentlyViewedNotifier(ref.watch(recentlyViewedServiceProvider)),
    );
