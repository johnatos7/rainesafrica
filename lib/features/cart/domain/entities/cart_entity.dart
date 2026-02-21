import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

class CartEntity extends Equatable {
  final String id;
  final List<CartItemEntity> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

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

  CartEntity copyWith({
    String? id,
    List<CartItemEntity>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? discount,
    double? total,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartEntity(
      id: id ?? this.id,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  // Calculate totals
  double get calculatedSubtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get calculatedTotal => calculatedSubtotal + tax + shipping - discount;

  // Calculate total expedited shipping fee
  double get calculatedExpeditedShippingFee {
    double totalFee = 0.0;
    for (final item in items) {
      if (item.itemShippingMethod == 'expedited' && item.product != null) {
        final expeditedPrice =
            item.product!.shippingOptions?.expeditedShippingPrice ?? 0.0;
        totalFee += expeditedPrice * item.quantity;
      }
    }
    return totalFee;
  }
}

class CartItemEntity extends Equatable {
  final String id;
  final String cartId;
  final int? productId;
  final ProductEntity? product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? selectedVariationId;
  final String? selectedVariation;
  final Map<String, String>? selectedAttributes;
  final List<int>? selectedAttributeIds;
  final String? variationDisplayName;
  final String? itemShippingMethod;
  final DateTime addedAt;
  final DateTime updatedAt;

  const CartItemEntity({
    required this.id,
    required this.cartId,
    this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.selectedVariationId,
    this.selectedVariation,
    this.selectedAttributes,
    this.selectedAttributeIds,
    this.variationDisplayName,
    this.itemShippingMethod,
    required this.addedAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    cartId,
    productId,
    product,
    quantity,
    unitPrice,
    totalPrice,
    selectedVariationId,
    selectedVariation,
    selectedAttributes,
    selectedAttributeIds,
    variationDisplayName,
    itemShippingMethod,
    addedAt,
    updatedAt,
  ];

  CartItemEntity copyWith({
    String? id,
    String? cartId,
    int? productId,
    ProductEntity? product,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    int? selectedVariationId,
    String? selectedVariation,
    Map<String, String>? selectedAttributes,
    List<int>? selectedAttributeIds,
    String? variationDisplayName,
    String? itemShippingMethod,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      selectedVariationId: selectedVariationId ?? this.selectedVariationId,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      selectedAttributeIds: selectedAttributeIds ?? this.selectedAttributeIds,
      variationDisplayName: variationDisplayName ?? this.variationDisplayName,
      itemShippingMethod: itemShippingMethod ?? this.itemShippingMethod,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isInStock => product?.isInStock ?? true;
  bool get isCodEligible => product?.isCod ?? false;
  double get effectiveUnitPrice => product?.effectivePrice ?? unitPrice;
  double get calculatedTotalPrice => effectiveUnitPrice * quantity;
}

class CartSummaryEntity extends Equatable {
  final int totalItems;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double expeditedShippingFee;
  final double total;
  final String currency;

  const CartSummaryEntity({
    required this.totalItems,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.expeditedShippingFee,
    required this.total,
    required this.currency,
  });

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

  CartSummaryEntity copyWith({
    int? totalItems,
    double? subtotal,
    double? tax,
    double? shipping,
    double? discount,
    double? expeditedShippingFee,
    double? total,
    String? currency,
  }) {
    return CartSummaryEntity(
      totalItems: totalItems ?? this.totalItems,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      discount: discount ?? this.discount,
      expeditedShippingFee: expeditedShippingFee ?? this.expeditedShippingFee,
      total: total ?? this.total,
      currency: currency ?? this.currency,
    );
  }
}
