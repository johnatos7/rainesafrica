import 'dart:convert';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:equatable/equatable.dart';
import 'attribute_model.dart';

class ShippingOptionsModel extends Equatable {
  final int? hasExpeditedShipping;
  final int? standardShippingDays;
  final int? expeditedShippingDays;
  final double? standardShippingPrice;
  final double? expeditedShippingPrice;

  const ShippingOptionsModel({
    this.hasExpeditedShipping,
    this.standardShippingDays,
    this.expeditedShippingDays,
    this.standardShippingPrice,
    this.expeditedShippingPrice,
  });

  @override
  List<Object?> get props => [
    hasExpeditedShipping,
    standardShippingDays,
    expeditedShippingDays,
    standardShippingPrice,
    expeditedShippingPrice,
  ];

  factory ShippingOptionsModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values from JSON
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
        // Try parsing as double first, then convert to int
        final doubleParsed = double.tryParse(value);
        return doubleParsed?.toInt();
      }
      return null;
    }

    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    return ShippingOptionsModel(
      hasExpeditedShipping: _parseInt(json['has_expedited_shipping']),
      standardShippingDays: _parseInt(json['standard_shipping_days']),
      expeditedShippingDays: _parseInt(json['expedited_shipping_days']),
      standardShippingPrice: _parseDouble(json['standard_shipping_price']),
      expeditedShippingPrice: _parseDouble(json['expedited_shipping_price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_expedited_shipping': hasExpeditedShipping,
      'standard_shipping_days': standardShippingDays,
      'expedited_shipping_days': expeditedShippingDays,
      'standard_shipping_price': standardShippingPrice,
      'expedited_shipping_price': expeditedShippingPrice,
    };
  }

  factory ShippingOptionsModel.fromEntity(ShippingOptionsEntity entity) {
    return ShippingOptionsModel(
      hasExpeditedShipping: entity.hasExpeditedShipping == true ? 1 : 0,
      standardShippingDays: entity.standardShippingDays,
      expeditedShippingDays: entity.expeditedShippingDays,
      standardShippingPrice: entity.standardShippingPrice,
      expeditedShippingPrice: entity.expeditedShippingPrice,
    );
  }
}

extension ShippingOptionsModelX on ShippingOptionsModel {
  ShippingOptionsEntity toEntity() {
    return ShippingOptionsEntity(
      hasExpeditedShipping: (hasExpeditedShipping ?? 0) == 1,
      standardShippingDays: standardShippingDays,
      expeditedShippingDays: expeditedShippingDays,
      standardShippingPrice: standardShippingPrice,
      expeditedShippingPrice: expeditedShippingPrice,
    );
  }
}

class ProductModel extends Equatable {
  final int? id;
  final String? name;
  final String? slug;
  final String? shortDescription;
  final String? description;
  final String? type;
  final String? unit;
  final double? weight;
  final int? quantity;
  final double? price;
  final double? salePrice;
  final double? discount;
  final int? isFeatured;
  final int? shippingDays;
  final int? isCod;
  final int? isFreeShipping;
  final int? hasExpedited;
  final ShippingOptionsModel? shippingOptions;
  final int? isSaleEnable;
  final int? isReturn;
  final int? isTrending;
  final int? isApproved;
  final int? isExternal;
  final String? externalUrl;
  final String? externalButtonText;
  final DateTime? saleStartsAt;
  final DateTime? saleExpiredAt;
  final String? sku;
  final int? isRandomRelatedProducts;
  final String? stockStatus;
  final String? metaTitle;
  final int? productThumbnailId;
  final int? productMetaImageId;
  final int? sizeChartImageId;
  final String? estimatedDeliveryText;
  final String? returnPolicyText;
  final String? warranty;
  final String? specifications;
  final int? safeCheckout;
  final int? secureCheckout;
  final int? socialShare;
  final int? encourageOrder;
  final int? encourageView;
  final int? status;
  final int? storeId;
  final int? createdById;
  final int? taxId;
  final DateTime? createdAt;
  final String? searchKeywords;
  final String? searchTsv;
  final int? ordersCount;
  final int? reviewsCount;
  final String? userReview;
  final int? ratingCount;
  final double? orderAmount;
  final List<int>? reviewRatings;
  final List<ProductModel>? relatedProducts;
  final List<ProductModel>? crossSellProducts;
  final List<ProductVariationModel>? variations;
  final ProductImageModel? productThumbnail;
  final ProductImageModel? productMetaImage;
  final List<ProductImageModel>? productGalleries;
  final List<ProductCategoryModel>? categories;
  final List<ProductTagModel>? tags;
  final List<ProductReviewModel>? reviews;
  final List<AttributeModel>? attributes;
  final int? isGiftCard;

  const ProductModel({
    this.id,
    this.name,
    this.slug,
    this.shortDescription,
    this.description,
    this.type,
    this.unit,
    this.weight,
    this.quantity,
    this.price,
    this.salePrice,
    this.discount,
    this.isFeatured,
    this.shippingDays,
    this.isCod,
    this.isFreeShipping,
    this.hasExpedited,
    this.shippingOptions,
    this.isSaleEnable,
    this.isReturn,
    this.isTrending,
    this.isApproved,
    this.isExternal,
    this.externalUrl,
    this.externalButtonText,
    this.saleStartsAt,
    this.saleExpiredAt,
    this.sku,
    this.isRandomRelatedProducts,
    this.stockStatus,
    this.metaTitle,
    this.productThumbnailId,
    this.productMetaImageId,
    this.sizeChartImageId,
    this.estimatedDeliveryText,
    this.returnPolicyText,
    this.warranty,
    this.specifications,
    this.safeCheckout,
    this.secureCheckout,
    this.socialShare,
    this.encourageOrder,
    this.encourageView,
    this.status,
    this.storeId,
    this.createdById,
    this.taxId,
    this.createdAt,
    this.searchKeywords,
    this.searchTsv,
    this.ordersCount,
    this.reviewsCount,
    this.userReview,
    this.ratingCount,
    this.orderAmount,
    this.reviewRatings,
    this.relatedProducts,
    this.crossSellProducts,
    this.variations,
    this.productThumbnail,
    this.productMetaImage,
    this.productGalleries,
    this.categories,
    this.tags,
    this.reviews,
    this.attributes,
    this.isGiftCard,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    attributes,
    shortDescription,
    description,
    type,
    unit,
    weight,
    quantity,
    price,
    salePrice,
    discount,
    isFeatured,
    shippingDays,
    isCod,
    isFreeShipping,
    hasExpedited,
    shippingOptions,
    isSaleEnable,
    isReturn,
    isTrending,
    isApproved,
    isExternal,
    externalUrl,
    externalButtonText,
    saleStartsAt,
    saleExpiredAt,
    sku,
    isRandomRelatedProducts,
    stockStatus,
    metaTitle,
    productThumbnailId,
    productMetaImageId,
    sizeChartImageId,
    estimatedDeliveryText,
    returnPolicyText,
    warranty,
    specifications,
    safeCheckout,
    secureCheckout,
    socialShare,
    encourageOrder,
    encourageView,
    status,
    storeId,
    createdById,
    taxId,
    createdAt,
    searchKeywords,
    searchTsv,
    ordersCount,
    reviewsCount,
    userReview,
    ratingCount,
    orderAmount,
    reviewRatings,
    relatedProducts,
    crossSellProducts,
    variations,
    productThumbnail,
    productMetaImage,
    productGalleries,
    categories,
    tags,
    reviews,
  ];

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      shortDescription: json['short_description'] as String?,
      description: _parseFlexibleDescription(json['description']),
      type: json['type'] as String?,
      unit: json['unit'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      isFeatured: (json['is_featured'] as num?)?.toInt(),
      shippingDays: (json['shipping_days'] as num?)?.toInt(),
      isCod: (json['is_cod'] as num?)?.toInt(),
      isFreeShipping: (json['is_free_shipping'] as num?)?.toInt(),
      hasExpedited: (json['has_expedited'] as num?)?.toInt(),
      shippingOptions:
          json['shipping_options'] != null
              ? ShippingOptionsModel.fromJson(
                json['shipping_options'] as Map<String, dynamic>,
              )
              : null,
      isSaleEnable: (json['is_sale_enable'] as num?)?.toInt(),
      isReturn: (json['is_return'] as num?)?.toInt(),
      isTrending: (json['is_trending'] as num?)?.toInt(),
      isApproved: (json['is_approved'] as num?)?.toInt(),
      isExternal: (json['is_external'] as num?)?.toInt(),
      externalUrl: json['external_url'] as String?,
      externalButtonText: json['external_button_text'] as String?,
      saleStartsAt:
          json['sale_starts_at'] != null
              ? DateTime.tryParse(json['sale_starts_at'] as String)
              : null,
      saleExpiredAt:
          json['sale_expired_at'] != null
              ? DateTime.tryParse(json['sale_expired_at'] as String)
              : null,
      sku: json['sku'] as String?,
      isRandomRelatedProducts:
          (json['is_random_related_products'] as num?)?.toInt(),
      stockStatus: json['stock_status'] as String?,
      metaTitle: json['meta_title'] as String?,
      productThumbnailId: (json['product_thumbnail_id'] as num?)?.toInt(),
      productMetaImageId: (json['product_meta_image_id'] as num?)?.toInt(),
      sizeChartImageId: (json['size_chart_image_id'] as num?)?.toInt(),
      estimatedDeliveryText:
          (json['estimated_delivery_text'] as String?)?.trim().isNotEmpty ==
                  true
              ? (json['estimated_delivery_text'] as String).trim()
              : null,
      returnPolicyText: json['return_policy_text'] as String?,
      warranty: json['warranty'] as String?,
      specifications: json['specifications'] as String?,
      safeCheckout: (json['safe_checkout'] as num?)?.toInt(),
      secureCheckout: (json['secure_checkout'] as num?)?.toInt(),
      socialShare: (json['social_share'] as num?)?.toInt(),
      encourageOrder: (json['encourage_order'] as num?)?.toInt(),
      encourageView: (json['encourage_view'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      storeId: (json['store_id'] as num?)?.toInt(),
      createdById: (json['created_by_id'] as num?)?.toInt(),
      taxId: (json['tax_id'] as num?)?.toInt(),
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      searchKeywords: json['search_keywords'] as String?,
      searchTsv: json['search_tsv'] as String?,
      ordersCount: (json['orders_count'] as num?)?.toInt(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt(),
      userReview: json['user_review'] as String?,
      ratingCount: (json['rating_count'] as num?)?.toInt(),
      orderAmount: (json['order_amount'] as num?)?.toDouble(),
      reviewRatings:
          (json['review_ratings'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      relatedProducts:
          (json['related_products'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      crossSellProducts:
          (json['cross_sell_products'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      variations:
          (json['variations'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map(
                (e) =>
                    ProductVariationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      productThumbnail:
          json['product_thumbnail'] is Map<String, dynamic>
              ? ProductImageModel.fromJson(
                json['product_thumbnail'] as Map<String, dynamic>,
              )
              : null,
      productMetaImage:
          json['product_meta_image'] is Map<String, dynamic>
              ? ProductImageModel.fromJson(
                json['product_meta_image'] as Map<String, dynamic>,
              )
              : null,
      productGalleries:
          (json['product_galleries'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      categories:
          (json['categories'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map(
                (e) => ProductCategoryModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      tags:
          (json['tags'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map((e) => ProductTagModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      reviews:
          (json['reviews'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map(
                (e) => ProductReviewModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      attributes:
          (json['attributes'] as List?)
              ?.where((e) => e is Map<String, dynamic>)
              .map((e) => AttributeModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      isGiftCard: _parseBoolField(json['is_gift_card']),
    );
  }

  static String? _parseFlexibleDescription(dynamic raw) {
    if (raw == null) return null;

    try {
      String value = raw.toString().trim();

      // remove backticks if present
      if (value.startsWith('`') && value.endsWith('`')) {
        value = value.substring(1, value.length - 1);
      }

      // try to decode JSON if it's valid JSON or double encoded
      final decoded = json.decode(value);
      if (decoded is String) {
        return decoded; // double encoded string
      } else if (decoded is Map || decoded is List) {
        return jsonEncode(decoded); // convert back to string if object
      } else {
        return decoded.toString();
      }
    } catch (_) {
      // not JSON, just return as-is
      return raw.toString();
    }
  }

  /// Safely parse a field that may be bool, int, or string into int? (0/1)
  static int? _parseBoolField(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value ? 1 : 0;
    if (value is num) return value.toInt();
    if (value is String) {
      if (value == 'true' || value == '1') return 1;
      if (value == 'false' || value == '0') return 0;
      return int.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'short_description': shortDescription,
      'type': type,
      'unit': unit,
      'weight': weight,
      'quantity': quantity,
      'price': price,
      'sale_price': salePrice,
      'discount': discount,
      'is_featured': isFeatured,
      'shipping_days': shippingDays,
      'is_cod': isCod,
      'is_free_shipping': isFreeShipping,
      'has_expedited': hasExpedited,
      'shipping_options': shippingOptions?.toJson(),
      'is_sale_enable': isSaleEnable,
      'is_return': isReturn,
      'is_trending': isTrending,
      'is_approved': isApproved,
      'is_external': isExternal,
      'external_url': externalUrl,
      'external_button_text': externalButtonText,
      'sale_starts_at': saleStartsAt?.toIso8601String(),
      'sale_expired_at': saleExpiredAt?.toIso8601String(),
      'sku': sku,
      'is_random_related_products': isRandomRelatedProducts,
      'stock_status': stockStatus,
      'meta_title': metaTitle,
      'product_thumbnail_id': productThumbnailId,
      'product_meta_image_id': productMetaImageId,
      'size_chart_image_id': sizeChartImageId,
      'estimated_delivery_text': estimatedDeliveryText,
      'return_policy_text': returnPolicyText,
      'warranty': warranty,
      'specifications': specifications,
      'safe_checkout': safeCheckout,
      'secure_checkout': secureCheckout,
      'social_share': socialShare,
      'encourage_order': encourageOrder,
      'encourage_view': encourageView,
      'status': status,
      'store_id': storeId,
      'created_by_id': createdById,
      'tax_id': taxId,
      'created_at': createdAt?.toIso8601String(),
      'search_keywords': searchKeywords,
      'search_tsv': searchTsv,
      'orders_count': ordersCount,
      'reviews_count': reviewsCount,
      'user_review': userReview,
      'rating_count': ratingCount,
      'order_amount': orderAmount,
      'review_ratings': reviewRatings ?? [],
      'related_products':
          relatedProducts?.map((e) => e.toJson()).toList() ?? [],
      'cross_sell_products':
          crossSellProducts?.map((e) => e.toJson()).toList() ?? [],
      'variations': variations?.map((e) => e.toJson()).toList() ?? [],
      'product_thumbnail': productThumbnail?.toJson(),
      'product_meta_image': productMetaImage?.toJson(),
      'product_galleries':
          productGalleries?.map((e) => e.toJson()).toList() ?? [],
      'categories': categories?.map((e) => e.toJson()).toList() ?? [],
      'tags': tags?.map((e) => e.toJson()).toList() ?? [],
      'reviews': reviews?.map((e) => e.toJson()).toList() ?? [],
      'attributes': attributes?.map((e) => e.toJson()).toList() ?? [],
    };
  }

  // Factory constructor to convert ProductEntity to ProductModel
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      shortDescription: entity.shortDescription,
      description: _parseFlexibleDescription(entity.description),
      type: entity.type,
      unit: entity.unit,
      weight: entity.weight,
      quantity: entity.quantity,
      price: entity.price,
      salePrice: entity.salePrice,
      discount: entity.discount,
      isFeatured: entity.isFeatured == true ? 1 : 0,
      shippingDays: entity.shippingDays,
      isCod: entity.isCod == true ? 1 : 0,
      isFreeShipping: entity.isFreeShipping == true ? 1 : 0,
      hasExpedited: entity.hasExpedited == true ? 1 : 0,
      shippingOptions:
          entity.shippingOptions != null
              ? ShippingOptionsModel.fromEntity(entity.shippingOptions!)
              : null,
      isSaleEnable: entity.isSaleEnable == true ? 1 : 0,
      isReturn: entity.isReturn == true ? 1 : 0,
      isTrending: entity.isTrending == true ? 1 : 0,
      isApproved: entity.isApproved == true ? 1 : 0,
      isExternal: entity.isExternal == true ? 1 : 0,
      externalUrl: entity.externalUrl,
      externalButtonText: entity.externalButtonText,
      saleStartsAt: entity.saleStartsAt,
      saleExpiredAt: entity.saleExpiredAt,
      sku: entity.sku,
      isRandomRelatedProducts: entity.isRandomRelatedProducts == true ? 1 : 0,
      stockStatus: entity.stockStatus,
      metaTitle: entity.metaTitle,
      productThumbnailId: entity.productThumbnailId,
      productMetaImageId: entity.productMetaImageId,
      sizeChartImageId: entity.sizeChartImageId,
      estimatedDeliveryText: entity.estimatedDeliveryText,
      returnPolicyText: entity.returnPolicyText,
      warranty: entity.warranty,
      specifications: entity.specifications,
      safeCheckout: entity.safeCheckout == true ? 1 : 0,
      secureCheckout: entity.secureCheckout == true ? 1 : 0,
      socialShare: entity.socialShare == true ? 1 : 0,
      encourageOrder: entity.encourageOrder == true ? 1 : 0,
      encourageView: entity.encourageView == true ? 1 : 0,
      status: entity.status == true ? 1 : 0,
      storeId: entity.storeId,
      createdById: entity.createdById,
      taxId: entity.taxId,
      createdAt: entity.createdAt,
      searchKeywords: entity.searchKeywords,
      searchTsv: entity.searchTsv,
      ordersCount: entity.ordersCount,
      reviewsCount: entity.reviewsCount,
      userReview: entity.userReview,
      ratingCount: entity.ratingCount,
      orderAmount: entity.orderAmount,
      reviewRatings: entity.reviewRatings,
      relatedProducts:
          entity.relatedProducts
              ?.map((e) => ProductModel.fromEntity(e))
              .toList(),
      crossSellProducts:
          entity.crossSellProducts
              ?.map((e) => ProductModel.fromEntity(e))
              .toList(),
      variations:
          entity.variations
              ?.map((e) => ProductVariationModel.fromEntity(e))
              .toList(),
      productThumbnail:
          entity.productThumbnail != null
              ? ProductImageModel.fromEntity(entity.productThumbnail!)
              : null,
      productMetaImage:
          entity.productMetaImage != null
              ? ProductImageModel.fromEntity(entity.productMetaImage!)
              : null,
      productGalleries:
          entity.productGalleries
              ?.map((e) => ProductImageModel.fromEntity(e))
              .toList(),
      categories:
          entity.categories
              ?.map((e) => ProductCategoryModel.fromEntity(e))
              .toList(),
      tags: entity.tags?.map((e) => ProductTagModel.fromEntity(e)).toList(),
      reviews:
          entity.reviews?.map((e) => ProductReviewModel.fromEntity(e)).toList(),
      attributes:
          entity.attributes?.map((e) => AttributeModel.fromEntity(e)).toList(),
    );
  }

  // Helper getters
  bool get isOnSale => isSaleEnable == 1 && salePrice != null && salePrice! > 0;
  double get effectivePrice => isOnSale ? salePrice! : price ?? 0.0;

  /// Computed discount percentage from price and salePrice.
  double get discountPercentage {
    if (discount != null && discount! > 0) return discount!;
    if (isOnSale && (price ?? 0) > 0) {
      return ((price! - salePrice!) / price! * 100);
    }
    return 0.0;
  }

  bool get isInStock => quantity != null && quantity! > 0;
  double get averageRating =>
      reviews?.isNotEmpty == true
          ? reviews!.map((r) => r.rating ?? 0).reduce((a, b) => a + b) /
              reviews!.length
          : 0.0;
}

// Extension to convert ProductModel to ProductEntity
extension ProductModelX on ProductModel {
  ProductEntity toEntity() {
    return ProductEntity(
      id: id ?? 0,
      name: name ?? '',
      slug: slug ?? '',
      productGalleries:
          productGalleries?.map((e) => e.toEntity()).toList() ?? [],
      price: price ?? 0.0,
      shortDescription: shortDescription,
      description: description,
      type: type,
      unit: unit,
      weight: weight,
      quantity: quantity,
      salePrice: salePrice,
      discount: discount,
      isFeatured: isFeatured == 1,
      shippingDays: shippingDays,
      isCod: isCod == 1,
      isFreeShipping: isFreeShipping == 1,
      hasExpedited: hasExpedited == 1,
      shippingOptions: shippingOptions?.toEntity(),
      isSaleEnable: isSaleEnable == 1,
      isReturn: isReturn == 1,
      isTrending: isTrending == 1,
      isApproved: isApproved == 1,
      isExternal: isExternal == 1,
      externalUrl: externalUrl,
      externalButtonText: externalButtonText,
      saleStartsAt: saleStartsAt,
      saleExpiredAt: saleExpiredAt,
      sku: sku,
      isRandomRelatedProducts: isRandomRelatedProducts == 1,
      stockStatus: stockStatus,
      metaTitle: metaTitle,
      productThumbnailId: productThumbnailId,
      productMetaImageId: productMetaImageId,
      sizeChartImageId: sizeChartImageId,
      estimatedDeliveryText: estimatedDeliveryText,
      returnPolicyText: returnPolicyText,
      warranty: warranty,
      specifications: specifications,
      safeCheckout: safeCheckout == 1,
      secureCheckout: secureCheckout == 1,
      socialShare: socialShare == 1,
      encourageOrder: encourageOrder == 1,
      encourageView: encourageView == 1,
      status: status == 1,
      storeId: storeId,
      createdById: createdById,
      taxId: taxId,
      createdAt: createdAt,
      searchKeywords: searchKeywords,
      searchTsv: searchTsv,
      ordersCount: ordersCount,
      reviewsCount: reviewsCount,
      userReview: userReview,
      ratingCount: ratingCount,
      orderAmount: orderAmount,
      reviewRatings: reviewRatings,
      relatedProducts: relatedProducts?.map((e) => e.toEntity()).toList(),
      crossSellProducts: crossSellProducts?.map((e) => e.toEntity()).toList(),
      variations: variations?.map((e) => e.toEntity()).toList(),
      productThumbnail: productThumbnail?.toEntity(),
      productMetaImage: productMetaImage?.toEntity(),
      categories: categories?.map((e) => e.toEntity()).toList(),
      tags: tags?.map((e) => e.toEntity()).toList(),
      reviews: reviews?.map((e) => e.toEntity()).toList(),
      attributes: attributes?.map((e) => e.toEntity()).toList(),
      isGiftCard: isGiftCard == 1,
    );
  }
}

class ProductImageModel extends Equatable {
  final int? id;
  final String? uuid;
  final String? name;
  final String? disk;
  final String? fileName;
  final String? imageUrl;
  final String? takealotUrl;
  final String? originalUrl;
  final int? createdById;
  final DateTime? createdAt;

  const ProductImageModel({
    this.id,
    this.uuid,
    this.name,
    this.disk,
    this.fileName,
    this.imageUrl,
    this.takealotUrl,
    this.originalUrl,
    this.createdById,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    uuid,
    name,
    disk,
    fileName,
    imageUrl,
    takealotUrl,
    originalUrl,
    createdById,
    createdAt,
  ];

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      disk: json['disk'] as String?,
      fileName: json['file_name'] as String?,
      imageUrl: json['image_url'] as String?,
      takealotUrl: json['takealot_url'] as String?,
      originalUrl: json['original_url'] as String?,
      createdById: json['created_by_id'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'disk': disk,
      'file_name': fileName,
      'image_url': imageUrl,
      'takealot_url': takealotUrl,
      'original_url': originalUrl,
      'created_by_id': createdById,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory ProductImageModel.fromEntity(ProductImageEntity entity) {
    return ProductImageModel(
      id: entity.id,
      uuid: entity.uuid,
      name: entity.name,
      disk: entity.disk,
      fileName: entity.fileName,
      imageUrl: entity.imageUrl,
      takealotUrl: entity.takealotUrl,
      originalUrl: entity.originalUrl,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
    );
  }
}

extension ProductImageModelX on ProductImageModel {
  ProductImageEntity toEntity() {
    return ProductImageEntity(
      id: id ?? 0,
      uuid: uuid,
      name: name,
      disk: disk,
      fileName: fileName,
      imageUrl: imageUrl ?? 'https://placehold.co/600x400?text=No+Image+Found',
      takealotUrl:
          takealotUrl ?? 'https://placehold.co/600x400?text=No+Image+Found',
      originalUrl:
          originalUrl ?? 'https://placehold.co/600x400?text=No+Image+Found',
      createdById: createdById,
      createdAt: createdAt,
    );
  }
}

class ProductCategoryModel extends Equatable {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final int? categoryImageId;
  final int? categoryIconId;
  final int? status;
  final String? type;
  final double? commissionRate;
  final int? parentId;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? categoryImageUuid;
  final String? categoryIconUuid;
  final ProductImageModel? categoryImage;
  final ProductImageModel? categoryIcon;

  const ProductCategoryModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.categoryImageId,
    this.categoryIconId,
    this.status,
    this.type,
    this.commissionRate,
    this.parentId,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.categoryImageUuid,
    this.categoryIconUuid,
    this.categoryImage,
    this.categoryIcon,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    categoryImageId,
    categoryIconId,
    status,
    type,
    commissionRate,
    parentId,
    createdById,
    createdAt,
    updatedAt,
    deletedAt,
    categoryImageUuid,
    categoryIconUuid,
    categoryImage,
    categoryIcon,
  ];

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      categoryImageId: json['category_image_id'] as int?,
      categoryIconId: json['category_icon_id'] as int?,
      status: json['status'] as int?,
      type: json['type'] as String?,
      commissionRate: (json['commission_rate'] as num?)?.toDouble(),
      parentId: json['parent_id'] as int?,
      createdById: json['created_by_id'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.tryParse(json['deleted_at'] as String)
              : null,
      categoryImageUuid: json['category_image_uuid'] as String?,
      categoryIconUuid: json['category_icon_uuid'] as String?,
      categoryImage:
          json['category_image'] != null
              ? ProductImageModel.fromJson(
                json['category_image'] as Map<String, dynamic>,
              )
              : null,
      categoryIcon:
          json['category_icon'] != null
              ? ProductImageModel.fromJson(
                json['category_icon'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'category_image_id': categoryImageId,
      'category_icon_id': categoryIconId,
      'status': status,
      'type': type,
      'commission_rate': commissionRate,
      'parent_id': parentId,
      'created_by_id': createdById,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'category_image_uuid': categoryImageUuid,
      'category_icon_uuid': categoryIconUuid,
      'category_image': categoryImage?.toJson(),
      'category_icon': categoryIcon?.toJson(),
    };
  }

  factory ProductCategoryModel.fromEntity(ProductCategoryEntity entity) {
    return ProductCategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      categoryImageId: entity.categoryImageId,
      categoryIconId: entity.categoryIconId,
      status: entity.status == true ? 1 : 0,
      type: entity.type,
      commissionRate: entity.commissionRate,
      parentId: entity.parentId,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      categoryImageUuid: entity.categoryImageUuid,
      categoryIconUuid: entity.categoryIconUuid,
      categoryImage:
          entity.categoryImage != null
              ? ProductImageModel.fromEntity(entity.categoryImage!)
              : null,
      categoryIcon:
          entity.categoryIcon != null
              ? ProductImageModel.fromEntity(entity.categoryIcon!)
              : null,
    );
  }
}

extension ProductCategoryModelX on ProductCategoryModel {
  ProductCategoryEntity toEntity() {
    return ProductCategoryEntity(
      id: id ?? 0,
      name: name ?? '',
      slug: slug ?? '',
      description: description,
      categoryImageId: categoryImageId,
      categoryIconId: categoryIconId,
      status: status == 1,
      type: type,
      commissionRate: commissionRate,
      parentId: parentId,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      categoryImageUuid: categoryImageUuid,
      categoryIconUuid: categoryIconUuid,
      categoryImage: categoryImage?.toEntity(),
      categoryIcon: categoryIcon?.toEntity(),
    );
  }
}

class ProductTagModel extends Equatable {
  final int? id;
  final String? name;
  final String? slug;
  final String? type;
  final String? description;
  final int? createdById;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const ProductTagModel({
    this.id,
    this.name,
    this.slug,
    this.type,
    this.description,
    this.createdById,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    type,
    description,
    createdById,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  factory ProductTagModel.fromJson(Map<String, dynamic> json) {
    return ProductTagModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      createdById: json['created_by_id'] as int?,
      status: json['status'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.tryParse(json['deleted_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type,
      'description': description,
      'created_by_id': createdById,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  factory ProductTagModel.fromEntity(ProductTagEntity entity) {
    return ProductTagModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      type: entity.type,
      description: entity.description,
      createdById: entity.createdById,
      status: entity.status == true ? 1 : 0,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }
}

extension ProductTagModelX on ProductTagModel {
  ProductTagEntity toEntity() {
    return ProductTagEntity(
      id: id ?? 0,
      name: name,
      slug: slug,
      type: type,
      description: description,
      createdById: createdById,
      status: status == 1,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

class ProductVariationModel extends Equatable {
  final int? id;
  final String? name;
  final double? price;
  final int? quantity;
  final String? stockStatus;
  final double? salePrice;
  final double? discount;
  final String? sku;
  final int? status;
  final String? variationOptions;
  final int? variationImageId;
  final int? productId;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final VariationImageModel? variationImage;
  final List<AttributeValueModel>? attributeValues;

  const ProductVariationModel({
    this.id,
    this.name,
    this.price,
    this.quantity,
    this.stockStatus,
    this.salePrice,
    this.discount,
    this.sku,
    this.status,
    this.variationOptions,
    this.variationImageId,
    this.productId,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.variationImage,
    this.attributeValues,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    quantity,
    stockStatus,
    salePrice,
    discount,
    sku,
    status,
    variationOptions,
    variationImageId,
    productId,
    deletedAt,
    createdAt,
    updatedAt,
    variationImage,
    attributeValues,
  ];

  factory ProductVariationModel.fromJson(Map<String, dynamic> json) {
    return ProductVariationModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      quantity: json['quantity'] as int?,
      stockStatus: json['stock_status'] as String?,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      sku: json['sku'] as String?,
      status: json['status'] as int?,
      variationOptions: json['variation_options'] as String?,
      variationImageId: json['variation_image_id'] as int?,
      productId: json['product_id'] as int?,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.tryParse(json['deleted_at'] as String)
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
      variationImage:
          json['variation_image'] != null
              ? VariationImageModel.fromJson(
                json['variation_image'] as Map<String, dynamic>,
              )
              : null,
      attributeValues:
          json['attribute_values'] != null
              ? (json['attribute_values'] as List)
                  .map(
                    (e) =>
                        AttributeValueModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'stock_status': stockStatus,
      'sale_price': salePrice,
      'discount': discount,
      'sku': sku,
      'status': status,
      'variation_options': variationOptions,
      'variation_image_id': variationImageId,
      'product_id': productId,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'variation_image': variationImage?.toJson(),
      'attribute_values': attributeValues?.map((e) => e.toJson()).toList(),
    };
  }

  factory ProductVariationModel.fromEntity(ProductVariationEntity entity) {
    return ProductVariationModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      stockStatus: entity.stockStatus,
      salePrice: entity.salePrice,
      discount: entity.discount,
      sku: entity.sku,
      status: entity.status,
      variationOptions: entity.variationOptions,
      variationImageId: entity.variationImageId,
      productId: entity.productId,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      variationImage:
          entity.variationImage != null
              ? VariationImageModel.fromEntity(entity.variationImage!)
              : null,
      attributeValues:
          entity.attributeValues
              ?.map((e) => AttributeValueModel.fromEntity(e))
              .toList(),
    );
  }
}

class VariationImageModel extends Equatable {
  final int? id;
  final String? imageUrl;
  final String? uuid;
  final String? name;
  final String? fileName;
  final String? disk;
  final int? createdById;
  final DateTime? createdAt;
  final String? originalUrl;
  final String? takealotUrl;

  const VariationImageModel({
    this.id,
    this.imageUrl,
    this.uuid,
    this.name,
    this.fileName,
    this.disk,
    this.createdById,
    this.createdAt,
    this.originalUrl,
    this.takealotUrl,
  });

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    uuid,
    name,
    fileName,
    disk,
    createdById,
    createdAt,
    originalUrl,
    takealotUrl,
  ];

  factory VariationImageModel.fromJson(Map<String, dynamic> json) {
    return VariationImageModel(
      id: json['id'] as int?,
      imageUrl: json['image_url'] as String?,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      fileName: json['file_name'] as String?,
      disk: json['disk'] as String?,
      createdById: json['created_by_id'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      originalUrl: json['original_url'] as String?,
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
      'created_at': createdAt?.toIso8601String(),
      'original_url': originalUrl,
      'takealot_url': takealotUrl,
    };
  }

  factory VariationImageModel.fromEntity(VariationImageEntity entity) {
    return VariationImageModel(
      id: entity.id,
      imageUrl: entity.imageUrl,
      uuid: entity.uuid,
      name: entity.name,
      fileName: entity.fileName,
      disk: entity.disk,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      originalUrl: entity.originalUrl,
      takealotUrl: entity.takealotUrl,
    );
  }
}

class AttributeValueModel extends Equatable {
  final int? id;
  final String? value;
  final String? hexColor;
  final String? slug;
  final int? attributeId;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final AttributeValuePivotModel? pivot;

  const AttributeValueModel({
    this.id,
    this.value,
    this.hexColor,
    this.slug,
    this.attributeId,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.pivot,
  });

  @override
  List<Object?> get props => [
    id,
    value,
    hexColor,
    slug,
    attributeId,
    createdById,
    createdAt,
    updatedAt,
    deletedAt,
    pivot,
  ];

  factory AttributeValueModel.fromJson(Map<String, dynamic> json) {
    return AttributeValueModel(
      id: json['id'] as int?,
      value: json['value'] as String?,
      hexColor: json['hex_color'] as String?,
      slug: json['slug'] as String?,
      attributeId: json['attribute_id'] as int?,
      createdById: json['created_by_id'] as int?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.tryParse(json['deleted_at'] as String)
              : null,
      pivot:
          json['pivot'] != null
              ? AttributeValuePivotModel.fromJson(
                json['pivot'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'hex_color': hexColor,
      'slug': slug,
      'attribute_id': attributeId,
      'created_by_id': createdById,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'pivot': pivot?.toJson(),
    };
  }

  factory AttributeValueModel.fromEntity(AttributeValueEntity entity) {
    return AttributeValueModel(
      id: entity.id,
      value: entity.value,
      hexColor: entity.hexColor,
      slug: entity.slug,
      attributeId: entity.attributeId,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      pivot:
          entity.pivot != null
              ? AttributeValuePivotModel.fromEntity(entity.pivot!)
              : null,
    );
  }
}

class AttributeValuePivotModel extends Equatable {
  final int? variationId;
  final int? attributeValueId;

  const AttributeValuePivotModel({this.variationId, this.attributeValueId});

  @override
  List<Object?> get props => [variationId, attributeValueId];

  factory AttributeValuePivotModel.fromJson(Map<String, dynamic> json) {
    return AttributeValuePivotModel(
      variationId: json['variation_id'] as int?,
      attributeValueId: json['attribute_value_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variation_id': variationId,
      'attribute_value_id': attributeValueId,
    };
  }

  factory AttributeValuePivotModel.fromEntity(
    AttributeValuePivotEntity entity,
  ) {
    return AttributeValuePivotModel(
      variationId: entity.variationId,
      attributeValueId: entity.attributeValueId,
    );
  }
}

extension ProductVariationModelX on ProductVariationModel {
  ProductVariationEntity toEntity() {
    return ProductVariationEntity(
      id: id ?? 0,
      name: name,
      price: price,
      quantity: quantity,
      stockStatus: stockStatus,
      salePrice: salePrice,
      discount: discount,
      sku: sku,
      status: status,
      variationOptions: variationOptions,
      variationImageId: variationImageId,
      productId: productId,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      variationImage: variationImage?.toEntity(),
      attributeValues: attributeValues?.map((e) => e.toEntity()).toList(),
    );
  }
}

extension VariationImageModelX on VariationImageModel {
  VariationImageEntity toEntity() {
    return VariationImageEntity(
      id: id ?? 0,
      imageUrl: imageUrl,
      uuid: uuid,
      name: name,
      fileName: fileName,
      disk: disk,
      createdById: createdById,
      createdAt: createdAt,
      originalUrl: originalUrl,
      takealotUrl: takealotUrl,
    );
  }
}

extension AttributeValueModelX on AttributeValueModel {
  AttributeValueEntity toEntity() {
    return AttributeValueEntity(
      id: id ?? 0,
      value: value,
      hexColor: hexColor,
      slug: slug,
      attributeId: attributeId,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      pivot: pivot?.toEntity(),
    );
  }
}

extension AttributeValuePivotModelX on AttributeValuePivotModel {
  AttributeValuePivotEntity toEntity() {
    return AttributeValuePivotEntity(
      variationId: variationId,
      attributeValueId: attributeValueId,
    );
  }
}

class ProductReviewModel extends Equatable {
  final int? id;
  final int? userId;
  final String? userName;
  final String? userAvatar;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductReviewModel({
    this.id,
    this.userId,
    this.userName,
    this.userAvatar,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userAvatar,
    rating,
    comment,
    createdAt,
    updatedAt,
  ];

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ProductReviewModel.fromEntity(ProductReviewEntity entity) {
    return ProductReviewModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userAvatar: entity.userAvatar,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

extension ProductReviewModelX on ProductReviewModel {
  ProductReviewEntity toEntity() {
    return ProductReviewEntity(
      id: id ?? 0,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
