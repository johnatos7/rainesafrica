import 'package:equatable/equatable.dart';
import 'attribute_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';

class ShippingOptionsEntity extends Equatable {
  final bool? hasExpeditedShipping;
  final int? standardShippingDays;
  final int? expeditedShippingDays;
  final double? standardShippingPrice;
  final double? expeditedShippingPrice;

  const ShippingOptionsEntity({
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

  factory ShippingOptionsEntity.empty() {
    return const ShippingOptionsEntity(
      hasExpeditedShipping: false,
      standardShippingDays: 0,
      expeditedShippingDays: 0,
      standardShippingPrice: 0.0,
      expeditedShippingPrice: 0.0,
    );
  }
}

class ProductEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? shortDescription;
  final String? description;
  final String? type;
  final String? unit;
  final double? weight;
  final int? quantity;
  final double price;
  final double? salePrice;
  final double? discount;
  final bool? isFeatured;
  final int? shippingDays;
  final bool? isCod;
  final bool? isFreeShipping;
  final bool? hasExpedited;
  final ShippingOptionsEntity? shippingOptions;
  final bool? isSaleEnable;
  final bool? isReturn;
  final bool? isTrending;
  final bool? isApproved;
  final bool? isExternal;
  final String? externalUrl;
  final String? externalButtonText;
  final DateTime? saleStartsAt;
  final DateTime? saleExpiredAt;
  final String? sku;
  final bool? isRandomRelatedProducts;
  final String? stockStatus;
  final String? metaTitle;
  final int? productThumbnailId;
  final int? productMetaImageId;
  final int? sizeChartImageId;
  final String? estimatedDeliveryText;
  final String? returnPolicyText;
  final String? warranty;
  final String? specifications;
  final bool? safeCheckout;
  final bool? secureCheckout;
  final bool? socialShare;
  final bool? encourageOrder;
  final bool? encourageView;
  final bool? status;
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
  final List<ProductEntity>? relatedProducts;
  final List<ProductEntity>? crossSellProducts;
  final List<ProductVariationEntity>? variations;
  final ProductImageEntity? productThumbnail;
  final ProductImageEntity? productMetaImage;
  final List<ProductImageEntity> productGalleries;
  final List<ProductCategoryEntity>? categories;
  final List<ProductTagEntity>? tags;
  final List<ProductReviewEntity>? reviews;
  final List<AttributeEntity>? attributes;
  final bool? isGiftCard;
  final LaybyEligibility? laybyEligibility;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.productGalleries,
    required this.price,
    this.attributes,
    this.shortDescription,
    this.description,
    this.type,
    this.unit,
    this.weight,
    this.quantity,
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
    this.categories,
    this.tags,
    this.reviews,
    this.isGiftCard,
    this.laybyEligibility,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    productGalleries,
    price,
    shortDescription,
    description,
    type,
    unit,
    weight,
    quantity,
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
    categories,
    tags,
    reviews,
    attributes,
    isGiftCard,
    laybyEligibility,
  ];

  // Factory constructor to create an empty product
  factory ProductEntity.empty() {
    return ProductEntity(
      id: 0,
      name: '',
      slug: '',
      productGalleries: [],
      price: 0.0,
      shortDescription: null,
      description: null,
      type: null,
      unit: null,
      weight: null,
      quantity: null,
      salePrice: null,
      discount: null,
      isFeatured: null,
      shippingDays: null,
      isCod: null,
      isFreeShipping: null,
      hasExpedited: null,
      shippingOptions: null,
      isSaleEnable: null,
      isReturn: null,
      isTrending: null,
      isApproved: null,
      isExternal: null,
      externalUrl: null,
      externalButtonText: null,
      saleStartsAt: null,
      saleExpiredAt: null,
      sku: null,
      isRandomRelatedProducts: null,
      stockStatus: null,
      metaTitle: null,
      productThumbnailId: null,
      productMetaImageId: null,
      sizeChartImageId: null,
      estimatedDeliveryText: null,
      returnPolicyText: null,
      warranty: null,
      specifications: null,
      safeCheckout: null,
      secureCheckout: null,
      socialShare: null,
      encourageOrder: null,
      encourageView: null,
      status: null,
      storeId: null,
      createdById: null,
      taxId: null,
      createdAt: null,
      searchKeywords: null,
      searchTsv: null,
      ordersCount: null,
      reviewsCount: null,
      userReview: null,
      ratingCount: null,
      orderAmount: null,
      reviewRatings: null,
      relatedProducts: null,
      crossSellProducts: null,
      variations: null,
      productThumbnail: ProductImageEntity.empty(),
      productMetaImage: null,
      categories: null,
      tags: null,
      reviews: null,
      attributes: null,
      isGiftCard: false,
      laybyEligibility: null,
    );
  }

  // CopyWith method for creating a new instance with some updated properties
  ProductEntity copyWith({
    int? id,
    String? name,
    String? slug,
    List<ProductImageEntity>? productGalleries,
    double? price,
    String? shortDescription,
    String? description,
    String? type,
    String? unit,
    double? weight,
    int? quantity,
    double? salePrice,
    double? discount,
    bool? isFeatured,
    int? shippingDays,
    bool? isCod,
    bool? isFreeShipping,
    bool? hasExpedited,
    ShippingOptionsEntity? shippingOptions,
    bool? isSaleEnable,
    bool? isReturn,
    bool? isTrending,
    bool? isApproved,
    bool? isExternal,
    String? externalUrl,
    String? externalButtonText,
    DateTime? saleStartsAt,
    DateTime? saleExpiredAt,
    String? sku,
    bool? isRandomRelatedProducts,
    String? stockStatus,
    String? metaTitle,
    int? productThumbnailId,
    int? productMetaImageId,
    int? sizeChartImageId,
    String? estimatedDeliveryText,
    String? returnPolicyText,
    String? warranty,
    String? specifications,
    bool? safeCheckout,
    bool? secureCheckout,
    bool? socialShare,
    bool? encourageOrder,
    bool? encourageView,
    bool? status,
    int? storeId,
    int? createdById,
    int? taxId,
    DateTime? createdAt,
    String? searchKeywords,
    String? searchTsv,
    int? ordersCount,
    int? reviewsCount,
    String? userReview,
    int? ratingCount,
    double? orderAmount,
    List<int>? reviewRatings,
    List<ProductEntity>? relatedProducts,
    List<ProductEntity>? crossSellProducts,
    List<ProductVariationEntity>? variations,
    ProductImageEntity? productThumbnail,
    ProductImageEntity? productMetaImage,
    List<ProductCategoryEntity>? categories,
    List<ProductTagEntity>? tags,
    List<ProductReviewEntity>? reviews,
    List<AttributeEntity>? attributes,
    bool? isGiftCard,
    LaybyEligibility? laybyEligibility,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      productGalleries: productGalleries ?? this.productGalleries,
      price: price ?? this.price,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      salePrice: salePrice ?? this.salePrice,
      discount: discount ?? this.discount,
      isFeatured: isFeatured ?? this.isFeatured,
      shippingDays: shippingDays ?? this.shippingDays,
      isCod: isCod ?? this.isCod,
      isFreeShipping: isFreeShipping ?? this.isFreeShipping,
      hasExpedited: hasExpedited ?? this.hasExpedited,
      shippingOptions: shippingOptions ?? this.shippingOptions,
      isSaleEnable: isSaleEnable ?? this.isSaleEnable,
      isReturn: isReturn ?? this.isReturn,
      isTrending: isTrending ?? this.isTrending,
      isApproved: isApproved ?? this.isApproved,
      isExternal: isExternal ?? this.isExternal,
      externalUrl: externalUrl ?? this.externalUrl,
      externalButtonText: externalButtonText ?? this.externalButtonText,
      saleStartsAt: saleStartsAt ?? this.saleStartsAt,
      saleExpiredAt: saleExpiredAt ?? this.saleExpiredAt,
      sku: sku ?? this.sku,
      isRandomRelatedProducts:
          isRandomRelatedProducts ?? this.isRandomRelatedProducts,
      stockStatus: stockStatus ?? this.stockStatus,
      metaTitle: metaTitle ?? this.metaTitle,
      productThumbnailId: productThumbnailId ?? this.productThumbnailId,
      productMetaImageId: productMetaImageId ?? this.productMetaImageId,
      sizeChartImageId: sizeChartImageId ?? this.sizeChartImageId,
      estimatedDeliveryText:
          estimatedDeliveryText ?? this.estimatedDeliveryText,
      returnPolicyText: returnPolicyText ?? this.returnPolicyText,
      warranty: warranty ?? this.warranty,
      specifications: specifications ?? this.specifications,
      safeCheckout: safeCheckout ?? this.safeCheckout,
      secureCheckout: secureCheckout ?? this.secureCheckout,
      socialShare: socialShare ?? this.socialShare,
      encourageOrder: encourageOrder ?? this.encourageOrder,
      encourageView: encourageView ?? this.encourageView,
      status: status ?? this.status,
      storeId: storeId ?? this.storeId,
      createdById: createdById ?? this.createdById,
      taxId: taxId ?? this.taxId,
      createdAt: createdAt ?? this.createdAt,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      searchTsv: searchTsv ?? this.searchTsv,
      ordersCount: ordersCount ?? this.ordersCount,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      userReview: userReview ?? this.userReview,
      ratingCount: ratingCount ?? this.ratingCount,
      orderAmount: orderAmount ?? this.orderAmount,
      reviewRatings: reviewRatings ?? this.reviewRatings,
      relatedProducts: relatedProducts ?? this.relatedProducts,
      crossSellProducts: crossSellProducts ?? this.crossSellProducts,
      variations: variations ?? this.variations,
      productThumbnail: productThumbnail ?? this.productThumbnail,
      productMetaImage: productMetaImage ?? this.productMetaImage,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      reviews: reviews ?? this.reviews,
      attributes: attributes ?? this.attributes,
      isGiftCard: isGiftCard ?? this.isGiftCard,
      laybyEligibility: laybyEligibility ?? this.laybyEligibility,
    );
  }

  // Method to check if product is empty
  bool get isEmpty => id == 0 && name.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Helper methods
  bool get isOnSale =>
      (isSaleEnable ?? false) && salePrice != null && salePrice! > 0;
  double get effectivePrice => isOnSale ? salePrice! : price;

  /// Computed discount percentage from price and salePrice.
  /// Falls back to the API-provided `discount` field if available.
  double get discountPercentage {
    if (discount != null && discount! > 0) return discount!;
    if (isOnSale && price > 0) {
      return ((price - salePrice!) / price * 100);
    }
    return 0.0;
  }

  /// Returns the list of colour attribute values for this product.
  /// First checks top-level attributes (detail API), then falls back to
  /// extracting unique colours from variations where attributeName == 'Colour'.
  List<AttributeValueEntity> get colourAttributeValues {
    // 1. Try top-level attributes (available on product detail endpoint)
    if (attributes != null) {
      for (final attr in attributes!) {
        if (attr.slug == 'colour' &&
            attr.attributeValues != null &&
            attr.attributeValues!.isNotEmpty) {
          return attr.attributeValues!;
        }
      }
    }

    // 2. Fall back to extracting from variations (available on list endpoints)
    //    Only include attribute values whose attributeName is 'Colour'
    if (variations != null && variations!.isNotEmpty) {
      final seen = <String>{};
      final result = <AttributeValueEntity>[];
      for (final variation in variations!) {
        if (variation.attributeValues != null) {
          for (final av in variation.attributeValues!) {
            // Only include colour attributes, skip size/shipping/etc.
            if (av.attributeName?.toLowerCase() != 'colour') continue;
            final key = av.slug ?? av.value ?? av.id.toString();
            if (seen.add(key)) {
              result.add(av);
            }
          }
        }
      }
      if (result.isNotEmpty) return result;
    }

    return [];
  }

  bool get isInStock => (stockStatus == 'in_stock') && (quantity ?? 0) > 0;
  double get averageRating {
    if (reviewRatings == null || reviewRatings!.isEmpty) return 0.0;
    int total = reviewRatings!.fold(0, (sum, rating) => sum + rating);
    return total / reviewRatings!.length;
  }
}

class ProductImageEntity extends Equatable {
  final int id;
  final String? uuid;
  final String? name;
  final String? disk;
  final String? fileName;
  final String imageUrl;
  final String takealotUrl;
  final String? originalUrl;
  final int? createdById;
  final DateTime? createdAt;

  const ProductImageEntity({
    required this.id,
    this.uuid,
    this.name,
    this.disk,
    this.fileName,
    this.imageUrl = 'https://placehold.co/600x400?text=No+Image+Found',
    this.takealotUrl = 'https://placehold.co/600x400?text=No+Image+Found',
    this.originalUrl = 'https://placehold.co/600x400?text=No+Image+Found',
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

  factory ProductImageEntity.empty() {
    return const ProductImageEntity(
      id: 0,
      disk: null,
      fileName: null,
      imageUrl: 'https://placehold.co/600x400?text=No+Image+Found',
      takealotUrl: 'https://placehold.co/600x400?text=No+Image+Found',
      originalUrl: 'https://placehold.co/600x400?text=No+Image+Found',
    );
  }
}

class ProductCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int? categoryImageId;
  final int? categoryIconId;
  final bool? status;
  final String? type;
  final double? commissionRate;
  final int? parentId;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? categoryImageUuid;
  final String? categoryIconUuid;
  final ProductImageEntity? categoryImage;
  final ProductImageEntity? categoryIcon;

  const ProductCategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
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
}

class ProductTagEntity extends Equatable {
  final int id;
  final String? name;
  final String? slug;
  final String? type;
  final String? description;
  final int? createdById;
  final bool? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const ProductTagEntity({
    required this.id,
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
}

class ProductVariationEntity extends Equatable {
  final int id;
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
  final VariationImageEntity? variationImage;
  final List<AttributeValueEntity>? attributeValues;

  const ProductVariationEntity({
    required this.id,
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
}

class VariationImageEntity extends Equatable {
  final int id;
  final String? imageUrl;
  final String? uuid;
  final String? name;
  final String? fileName;
  final String? disk;
  final int? createdById;
  final DateTime? createdAt;
  final String? originalUrl;
  final String? takealotUrl;

  const VariationImageEntity({
    required this.id,
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
}

class AttributeValueEntity extends Equatable {
  final int id;
  final String? value;
  final String? hexColor;
  final String? slug;
  final int? attributeId;
  final String? attributeName;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final AttributeValuePivotEntity? pivot;

  const AttributeValueEntity({
    required this.id,
    this.value,
    this.hexColor,
    this.slug,
    this.attributeId,
    this.attributeName,
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
    attributeName,
    createdById,
    createdAt,
    updatedAt,
    deletedAt,
    pivot,
  ];
}

class AttributeValuePivotEntity extends Equatable {
  final int? variationId;
  final int? attributeValueId;

  const AttributeValuePivotEntity({this.variationId, this.attributeValueId});

  @override
  List<Object?> get props => [variationId, attributeValueId];
}

class ProductReviewEntity extends Equatable {
  final int id;
  final int? userId;
  final String? userName;
  final String? userAvatar;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductReviewEntity({
    required this.id,
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
}
