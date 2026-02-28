import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

class AttributeEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? style;
  final int? status;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final AttributePivotEntity? pivot;
  final List<AttributeValueEntity>? attributeValues;

  const AttributeEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.style,
    this.status,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.pivot,
    this.attributeValues,
  });

  AttributeEntity copyWith({
    int? id,
    String? name,
    String? slug,
    String? style,
    int? status,
    int? createdById,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    AttributePivotEntity? pivot,
    List<AttributeValueEntity>? attributeValues,
  }) {
    return AttributeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      style: style ?? this.style,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      pivot: pivot ?? this.pivot,
      attributeValues: attributeValues ?? this.attributeValues,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    style,
    status,
    createdById,
    createdAt,
    updatedAt,
    deletedAt,
    pivot,
    attributeValues,
  ];
}

class AttributePivotEntity extends Equatable {
  final int productId;
  final int attributeId;

  const AttributePivotEntity({
    required this.productId,
    required this.attributeId,
  });

  AttributePivotEntity copyWith({int? productId, int? attributeId}) {
    return AttributePivotEntity(
      productId: productId ?? this.productId,
      attributeId: attributeId ?? this.attributeId,
    );
  }

  @override
  List<Object?> get props => [productId, attributeId];
}
