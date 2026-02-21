import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/attribute_entity.dart';

class AttributeModel extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? style;
  final int? status;
  final int? createdById;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final AttributePivot? pivot;

  const AttributeModel({
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
  });

  factory AttributeModel.fromJson(Map<String, dynamic> json) {
    return AttributeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      style: json['style'] as String?,
      status: json['status'] as int?,
      createdById: json['created_by_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      pivot: json['pivot'] != null
          ? AttributePivot.fromJson(json['pivot'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'style': style,
      'status': status,
      'created_by_id': createdById,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'pivot': pivot?.toJson(),
    };
  }

  factory AttributeModel.fromEntity(AttributeEntity entity) {
    return AttributeModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      style: entity.style,
      status: entity.status,
      createdById: entity.createdById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      pivot: entity.pivot != null
          ? AttributePivot.fromEntity(entity.pivot!)
          : null,
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
      ];
}

class AttributePivot extends Equatable {
  final int productId;
  final int attributeId;

  const AttributePivot({required this.productId, required this.attributeId});

  factory AttributePivot.fromJson(Map<String, dynamic> json) {
    return AttributePivot(
      productId: json['product_id'] as int,
      attributeId: json['attribute_id'] as int,
    );
  }

  factory AttributePivot.fromEntity(AttributePivotEntity entity) {
    return AttributePivot(
      productId: entity.productId,
      attributeId: entity.attributeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'attribute_id': attributeId,
    };
  }

  @override
  List<Object?> get props => [productId, attributeId];
}

extension AttributeModelX on AttributeModel {
  AttributeEntity toEntity() {
    return AttributeEntity(
      id: id,
      name: name,
      slug: slug,
      style: style,
      status: status,
      createdById: createdById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      pivot: pivot?.toEntity(),
    );
  }
}

extension AttributePivotX on AttributePivot {
  AttributePivotEntity toEntity() {
    return AttributePivotEntity(
      productId: productId,
      attributeId: attributeId,
    );
  }
}