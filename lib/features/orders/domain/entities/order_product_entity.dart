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
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      productThumbnailId: json['product_thumbnail_id'] as int?,
      userReview: json['user_review'],
      ratingCount: json['rating_count'] as int?,
      orderAmount: (json['order_amount'] as num).toDouble(),
      reviewRatings:
          (json['review_ratings'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      relatedProducts: json['related_products'] as List<dynamic>? ?? [],
      crossSellProducts: json['cross_sell_products'] as List<dynamic>? ?? [],
      pivot: OrderProductPivotEntity.fromJson(
        json['pivot'] as Map<String, dynamic>,
      ),
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

  factory OrderProductPivotEntity.fromJson(Map<String, dynamic> json) {
    return OrderProductPivotEntity(
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      variationId: json['variation_id'] as int?,
      selectedAttributeIds: json['selected_attribute_ids'] != null
          ? (json['selected_attribute_ids'] as List<dynamic>)
              .map((e) => e as int)
              .toList()
          : null,
      variationDisplayName: json['variation_display_name'] as String?,
      quantity: json['quantity'] as int,
      singlePrice: (json['single_price'] as num).toDouble(),
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      fastShippingCost: (json['fast_shipping_cost'] as num?)?.toDouble() ?? 0.0,
      itemShippingMethod: json['item_shipping_method'] as String?,
      hasFastShipping: json['has_fast_shipping'] as bool? ?? false,
      refundStatus: json['refund_status'],
      itemStatus: json['item_status'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      eta: json['eta'] as String?,
      subtotal: (json['subtotal'] as num).toDouble(),
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
      id: json['id'] as int,
      imageUrl: json['image_url'] as String? ?? '',
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      fileName: json['file_name'] as String?,
      disk: json['disk'] as String? ?? 'public',
      createdById: json['created_by_id'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      originalUrl: json['original_url'] as String? ?? '',
      takealotUrl: json['takealot_url'] as String?,
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
      id: json['id'] as int,
      imageUrl: json['image_url'] as String? ?? '',
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      fileName: json['file_name'] as String?,
      disk: json['disk'] as String? ?? 'public',
      createdById: json['created_by_id'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      originalUrl: json['original_url'] as String? ?? '',
      takealotUrl: json['takealot_url'] as String?,
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
