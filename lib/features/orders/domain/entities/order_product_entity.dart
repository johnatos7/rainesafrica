class OrderProductEntity {
  final int id;
  final String name;
  final int? productThumbnailId;
  final dynamic userReview;
  final int? ratingCount;
  final double orderAmount;
  final List<int> reviewRatings;
  final List<dynamic> relatedProducts;
  final List<dynamic> crossSellProducts;
  final OrderProductPivotEntity pivot;
  final List<dynamic> variations;
  final OrderProductThumbnailEntity? productThumbnail;
  final dynamic productMetaImage;
  final List<OrderProductGalleryEntity> productGalleries;
  final List<dynamic> reviews;

  const OrderProductEntity({
    required this.id,
    required this.name,
    this.productThumbnailId,
    this.userReview,
    this.ratingCount,
    required this.orderAmount,
    required this.reviewRatings,
    required this.relatedProducts,
    required this.crossSellProducts,
    required this.pivot,
    required this.variations,
    this.productThumbnail,
    this.productMetaImage,
    required this.productGalleries,
    required this.reviews,
  });

  factory OrderProductEntity.fromJson(Map<String, dynamic> json) {
    return OrderProductEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      productThumbnailId: (json['product_thumbnail_id'] as num?)?.toInt(),
      userReview: json['user_review'],
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      orderAmount: (json['order_amount'] as num?)?.toDouble() ?? 0.0,
      reviewRatings:
          (json['review_ratings'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      relatedProducts: json['related_products'] as List<dynamic>? ?? [],
      crossSellProducts: json['cross_sell_products'] as List<dynamic>? ?? [],
      pivot:
          json['pivot'] != null
              ? OrderProductPivotEntity.fromJson(
                json['pivot'] as Map<String, dynamic>,
              )
              : OrderProductPivotEntity.empty(),
      variations: json['variations'] as List<dynamic>? ?? [],
      productThumbnail:
          json['product_thumbnail'] != null
              ? OrderProductThumbnailEntity.fromJson(
                json['product_thumbnail'] as Map<String, dynamic>,
              )
              : null,
      productMetaImage: json['product_meta_image'],
      productGalleries:
          (json['product_galleries'] as List<dynamic>?)
              ?.map(
                (e) => OrderProductGalleryEntity.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      reviews: json['reviews'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'product_thumbnail_id': productThumbnailId,
      'user_review': userReview,
      'rating_count': ratingCount,
      'order_amount': orderAmount,
      'review_ratings': reviewRatings,
      'related_products': relatedProducts,
      'cross_sell_products': crossSellProducts,
      'pivot': pivot.toJson(),
      'variations': variations,
      'product_thumbnail': productThumbnail?.toJson(),
      'product_meta_image': productMetaImage,
      'product_galleries': productGalleries.map((e) => e.toJson()).toList(),
      'reviews': reviews,
    };
  }
}

class OrderProductPivotEntity {
  final int orderId;
  final int productId;
  final int? variationId;
  final List<int>? selectedAttributeIds;
  final String? variationDisplayName;
  final int quantity;
  final double singlePrice;
  final double tax;
  final double shippingCost;
  final double fastShippingCost;
  final String? itemShippingMethod;
  final bool hasFastShipping;
  final dynamic refundStatus;
  final String? itemStatus;
  final String? cancellationReason;
  final String? eta;
  final double subtotal;

  const OrderProductPivotEntity({
    required this.orderId,
    required this.productId,
    this.variationId,
    this.selectedAttributeIds,
    this.variationDisplayName,
    required this.quantity,
    required this.singlePrice,
    required this.tax,
    required this.shippingCost,
    required this.fastShippingCost,
    this.itemShippingMethod,
    required this.hasFastShipping,
    this.refundStatus,
    this.itemStatus,
    this.cancellationReason,
    this.eta,
    required this.subtotal,
  });

  factory OrderProductPivotEntity.empty() {
    return const OrderProductPivotEntity(
      orderId: 0,
      productId: 0,
      quantity: 0,
      singlePrice: 0,
      tax: 0,
      shippingCost: 0,
      fastShippingCost: 0,
      hasFastShipping: false,
      subtotal: 0,
    );
  }

  factory OrderProductPivotEntity.fromJson(Map<String, dynamic> json) {
    return OrderProductPivotEntity(
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      variationId: (json['variation_id'] as num?)?.toInt(),
      selectedAttributeIds:
          json['selected_attribute_ids'] != null
              ? (json['selected_attribute_ids'] as List<dynamic>)
                  .map((e) => (e as num).toInt())
                  .toList()
              : null,
      variationDisplayName: json['variation_display_name']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      singlePrice: (json['single_price'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      fastShippingCost: (json['fast_shipping_cost'] as num?)?.toDouble() ?? 0.0,
      itemShippingMethod: json['item_shipping_method']?.toString(),
      hasFastShipping: json['has_fast_shipping'] as bool? ?? false,
      refundStatus: json['refund_status'],
      itemStatus: json['item_status']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      eta: json['eta']?.toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'variation_id': variationId,
      'selected_attribute_ids': selectedAttributeIds,
      'variation_display_name': variationDisplayName,
      'quantity': quantity,
      'single_price': singlePrice,
      'tax': tax,
      'shipping_cost': shippingCost,
      'fast_shipping_cost': fastShippingCost,
      'item_shipping_method': itemShippingMethod,
      'has_fast_shipping': hasFastShipping,
      'refund_status': refundStatus,
      'item_status': itemStatus,
      'cancellation_reason': cancellationReason,
      'eta': eta,
      'subtotal': subtotal,
    };
  }
}

class OrderProductThumbnailEntity {
  final int id;
  final String imageUrl;
  final String? uuid;
  final String? name;
  final String? fileName;
  final String disk;
  final int createdById;
  final DateTime createdAt;
  final String originalUrl;
  final String? takealotUrl;

  const OrderProductThumbnailEntity({
    required this.id,
    required this.imageUrl,
    this.uuid,
    this.name,
    this.fileName,
    required this.disk,
    required this.createdById,
    required this.createdAt,
    required this.originalUrl,
    this.takealotUrl,
  });

  factory OrderProductThumbnailEntity.fromJson(Map<String, dynamic> json) {
    return OrderProductThumbnailEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      uuid: json['uuid']?.toString(),
      name: json['name']?.toString(),
      fileName: json['file_name']?.toString(),
      disk: json['disk']?.toString() ?? 'public',
      createdById: (json['created_by_id'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      originalUrl: json['original_url']?.toString() ?? '',
      takealotUrl: json['takealot_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'uuid': uuid,
      'name': name,
      'file_name': fileName,
      'disk': disk,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'original_url': originalUrl,
      'takealot_url': takealotUrl,
    };
  }
}

class OrderProductGalleryEntity {
  final int id;
  final String imageUrl;
  final String? uuid;
  final String? name;
  final String? fileName;
  final String disk;
  final int createdById;
  final DateTime createdAt;
  final String originalUrl;
  final String? takealotUrl;

  const OrderProductGalleryEntity({
    required this.id,
    required this.imageUrl,
    this.uuid,
    this.name,
    this.fileName,
    required this.disk,
    required this.createdById,
    required this.createdAt,
    required this.originalUrl,
    this.takealotUrl,
  });

  factory OrderProductGalleryEntity.fromJson(Map<String, dynamic> json) {
    return OrderProductGalleryEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      uuid: json['uuid']?.toString(),
      name: json['name']?.toString(),
      fileName: json['file_name']?.toString(),
      disk: json['disk']?.toString() ?? 'public',
      createdById: (json['created_by_id'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      originalUrl: json['original_url']?.toString() ?? '',
      takealotUrl: json['takealot_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'uuid': uuid,
      'name': name,
      'file_name': fileName,
      'disk': disk,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'original_url': originalUrl,
      'takealot_url': takealotUrl,
    };
  }
}
