import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';

class WishlistModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<WishlistItemModel>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDefault;

  const WishlistModel({
    required this.id,
    required this.name,
    this.description,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.isDefault,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    WishlistItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      isDefault: json['is_default'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items?.map((item) => item.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_default': isDefault,
    };
  }

  WishlistEntity toEntity() {
    return WishlistEntity(
      id: id,
      name: name,
      description: description,
      items: items?.map((item) => item.toEntity()).toList() ?? [],
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isDefault: isDefault ?? false,
    );
  }

  factory WishlistModel.fromEntity(WishlistEntity entity) {
    return WishlistModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      items:
          entity.items
              .map((item) => WishlistItemModel.fromEntity(item))
              .toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDefault: entity.isDefault,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    items,
    createdAt,
    updatedAt,
    isDefault,
  ];
}

class WishlistItemModel extends Equatable {
  final String? id;
  final String? wishlistId;
  final ProductModel? product;
  final DateTime? addedAt;
  final String? notes;

  const WishlistItemModel({
    this.id,
    this.wishlistId,
    this.product,
    this.addedAt,
    this.notes,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      id: json['id'] as String?,
      wishlistId: json['wishlist_id'] as String?,
      product:
          json['product'] != null
              ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
              : null,
      addedAt:
          json['added_at'] != null
              ? DateTime.parse(json['added_at'] as String)
              : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wishlist_id': wishlistId,
      'product': product?.toJson(),
      'added_at': addedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  WishlistItemEntity toEntity() {
    if (product == null) {
      throw Exception('Product is required for WishlistItemEntity');
    }

    return WishlistItemEntity(
      id: id ?? '',
      wishlistId: wishlistId ?? '',
      product: product!.toEntity(),
      addedAt: addedAt ?? DateTime.now(),
      notes: notes,
    );
  }

  factory WishlistItemModel.fromEntity(WishlistItemEntity entity) {
    return WishlistItemModel(
      id: entity.id,
      wishlistId: entity.wishlistId,
      product: ProductModel.fromEntity(entity.product),
      addedAt: entity.addedAt,
      notes: entity.notes,
    );
  }

  @override
  List<Object?> get props => [id, wishlistId, product, addedAt, notes];
}
