import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:equatable/equatable.dart';

class CartModel extends Equatable {
  final String? id;
  final List<CartItemModel>? items;
  final double? subtotal;
  final double? tax;
  final double? shipping;
  final double? discount;
  final double? total;
  final String? currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartModel({
    this.id,
    this.items,
    this.subtotal,
    this.tax,
    this.shipping,
    this.discount,
    this.total,
    this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) => CartItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      shipping: (json['shipping'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items?.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CartEntity toEntity() {
    return CartEntity(
      id: id ?? '',
      items: items?.map((item) => item.toEntity()).toList() ?? [],
      subtotal: subtotal ?? 0.0,
      tax: tax ?? 0.0,
      shipping: shipping ?? 0.0,
      discount: discount ?? 0.0,
      total: total ?? 0.0,
      currency: currency ?? 'ZAR',
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    items,
    subtotal,
    tax,
    shipping,
    discount,
    total,
    currency,
    createdAt,
    updatedAt,
  ];
}

class CartItemModel extends Equatable {
  final String? id;
  final String? cartId;
  final int? productId;
  final ProductModel? product;
  final int? quantity;
  final double? unitPrice;
  final double? totalPrice;
  final int? selectedVariationId;
  final String? selectedVariation;
  final Map<String, String>? selectedAttributes;
  final List<int>? selectedAttributeIds;
  final String? variationDisplayName;
  final String? itemShippingMethod;
  final DateTime? addedAt;
  final DateTime? updatedAt;

  const CartItemModel({
    this.id,
    this.cartId,
    this.productId,
    this.product,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.selectedVariationId,
    this.selectedVariation,
    this.selectedAttributes,
    this.selectedAttributeIds,
    this.variationDisplayName,
    this.itemShippingMethod,
    this.addedAt,
    this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String?,
      cartId: json['cart_id'] as String?,
      productId: json['product_id'] as int?,
      product:
          json['product'] != null
              ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
              : null,
      quantity: json['quantity'] as int?,
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      selectedVariationId: json['selected_variation_id'] as int?,
      selectedVariation: json['selected_variation'] as String?,
      selectedAttributes:
          json['selected_attributes'] != null
              ? Map<String, String>.from(json['selected_attributes'] as Map)
              : null,
      selectedAttributeIds: json['selected_attribute_ids'] != null
          ? List<int>.from(json['selected_attribute_ids'] as List)
          : null,
      variationDisplayName: json['variation_display_name'] as String?,
      itemShippingMethod: json['item_shipping_method'] as String?,
      addedAt:
          json['added_at'] != null
              ? DateTime.parse(json['added_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'product': product?.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'selected_variation_id': selectedVariationId,
      'selected_variation': selectedVariation,
      'selected_attributes': selectedAttributes,
      'selected_attribute_ids': selectedAttributeIds,
      'variation_display_name': variationDisplayName,
      'item_shipping_method': itemShippingMethod,
      'added_at': addedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id ?? '',
      cartId: cartId ?? '',
      productId: productId,
      product: product?.toEntity(),
      quantity: quantity ?? 1,
      unitPrice: unitPrice ?? 0.0,
      totalPrice: totalPrice ?? 0.0,
      selectedVariationId: selectedVariationId,
      selectedVariation: selectedVariation,
      selectedAttributes: selectedAttributes,
      selectedAttributeIds: selectedAttributeIds,
      variationDisplayName: variationDisplayName,
      itemShippingMethod: itemShippingMethod,
      addedAt: addedAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    cartId,
    productId,
    product,
    quantity,
    unitPrice,
    totalPrice,
    selectedVariation,
    selectedAttributes,
    itemShippingMethod,
    addedAt,
    updatedAt,
  ];
}

class CartSummaryModel extends Equatable {
  final int? totalItems;
  final double? subtotal;
  final double? tax;
  final double? shipping;
  final double? discount;
  final double? expeditedShippingFee;
  final double? total;
  final String? currency;

  const CartSummaryModel({
    this.totalItems,
    this.subtotal,
    this.tax,
    this.shipping,
    this.discount,
    this.expeditedShippingFee,
    this.total,
    this.currency,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    return CartSummaryModel(
      totalItems: json['total_items'] as int?,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      shipping: (json['shipping'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      expeditedShippingFee:
          (json['expedited_shipping_fee'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'expedited_shipping_fee': expeditedShippingFee,
      'total': total,
      'currency': currency,
    };
  }

  CartSummaryEntity toEntity() {
    return CartSummaryEntity(
      totalItems: totalItems ?? 0,
      subtotal: subtotal ?? 0.0,
      tax: tax ?? 0.0,
      shipping: shipping ?? 0.0,
      discount: discount ?? 0.0,
      expeditedShippingFee: expeditedShippingFee ?? 0.0,
      total: total ?? 0.0,
      currency: currency ?? 'ZAR',
    );
  }

  @override
  List<Object?> get props => [
    totalItems,
    subtotal,
    tax,
    shipping,
    discount,
    expeditedShippingFee,
    total,
    currency,
  ];
}
