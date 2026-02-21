import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight snapshot of a product for local "recently viewed" storage.
class RecentlyViewedItem {
  final int productId;
  final String name;
  final String slug;
  final double price;
  final double? salePrice;
  final double? discount;
  final String imageUrl;
  final List<int>? reviewRatings;
  final int viewedAt; // epoch millis

  RecentlyViewedItem({
    required this.productId,
    required this.name,
    required this.slug,
    required this.price,
    this.salePrice,
    this.discount,
    required this.imageUrl,
    this.reviewRatings,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'slug': slug,
    'price': price,
    'salePrice': salePrice,
    'discount': discount,
    'imageUrl': imageUrl,
    'reviewRatings': reviewRatings,
    'viewedAt': viewedAt,
  };

  factory RecentlyViewedItem.fromJson(Map<String, dynamic> json) {
    return RecentlyViewedItem(
      productId: json['productId'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      price: (json['price'] as num).toDouble(),
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String,
      reviewRatings:
          (json['reviewRatings'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      viewedAt: json['viewedAt'] as int,
    );
  }
}

/// SharedPreferences-backed service that stores up to [maxItems] recently
/// viewed product snapshots, ordered most-recent-first.
class RecentlyViewedService {
  static const String _key = 'recently_viewed_products';
  static const int maxItems = 30;

  /// Load all recently viewed items (most recent first).
  Future<List<RecentlyViewedItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list =
          (jsonDecode(raw) as List<dynamic>)
              .map(
                (e) => RecentlyViewedItem.fromJson(e as Map<String, dynamic>),
              )
              .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Add a product view. Moves to front if already present, trims to [maxItems].
  Future<List<RecentlyViewedItem>> addView(RecentlyViewedItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final items = await getAll();

    // Remove duplicate (same product id)
    items.removeWhere((e) => e.productId == item.productId);

    // Insert at front
    items.insert(0, item);

    // Trim
    if (items.length > maxItems) {
      items.removeRange(maxItems, items.length);
    }

    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
    return items;
  }

  /// Clear all recently viewed items.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
