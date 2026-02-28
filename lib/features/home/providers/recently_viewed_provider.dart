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

    // Extract colour slugs from attributes
    List<String>? colourSlugs;
    bool hasMoreOptions = false;
    try {
      if (product.attributes != null) {
        for (final attr in product.attributes!) {
          if (attr.slug == 'colour' && attr.attributeValues != null) {
            colourSlugs =
                attr.attributeValues!
                    .map<String>((v) => v.slug ?? '')
                    .where((s) => s.isNotEmpty)
                    .toList();
          }
        }
      }
      // Check variations for non-colour options
      if (product.variations != null && product.variations!.isNotEmpty) {
        for (final variation in product.variations!) {
          if (variation.attributeValues != null) {
            for (final av in variation.attributeValues!) {
              if (av.attributeName?.toLowerCase() != 'colour') {
                hasMoreOptions = true;
                break;
              }
            }
          }
          if (hasMoreOptions) break;
        }
      }
    } catch (_) {}

    final item = RecentlyViewedItem(
      productId: product.id,
      name: product.name,
      slug: product.slug,
      price: product.price,
      salePrice: product.salePrice,
      discount: product.discount,
      imageUrl: thumbnail,
      reviewRatings: product.reviewRatings,
      estimatedDeliveryText: product.estimatedDeliveryText,
      isSaleEnable: product.isSaleEnable,
      colourSlugs: colourSlugs,
      hasMoreOptions: hasMoreOptions,
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
