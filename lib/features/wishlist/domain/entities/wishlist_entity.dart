import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

class WishlistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<WishlistItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  const WishlistEntity({
    required this.id,
    required this.name,
    this.description,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
  });

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

  WishlistEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<WishlistItemEntity>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return WishlistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Helper methods
  int get itemCount => items.length;
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

class WishlistItemEntity extends Equatable {
  final String id;
  final String wishlistId;
  final ProductEntity product;
  final DateTime addedAt;
  final String? notes;

  const WishlistItemEntity({
    required this.id,
    required this.wishlistId,
    required this.product,
    required this.addedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, wishlistId, product, addedAt, notes];

  WishlistItemEntity copyWith({
    String? id,
    String? wishlistId,
    ProductEntity? product,
    DateTime? addedAt,
    String? notes,
  }) {
    return WishlistItemEntity(
      id: id ?? this.id,
      wishlistId: wishlistId ?? this.wishlistId,
      product: product ?? this.product,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
    );
  }
}
