import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import '../../domain/entities/media_file_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.slug,
    super.description,
    super.categoryImage,
    super.categoryIcon,
    super.parentId,
    super.parent,
    required super.subcategories,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    MediaFileEntity? parseMediaFile(dynamic field) {
      if (field == null) return null;
      if (field is Map<String, dynamic>) {
        return MediaFileEntity(
          id: (field['id'] as num).toInt(),
          uuid: field['uuid'] ?? '',
          name: field['name'] ?? '',
          disk: field['disk'] ?? '',
          fileName: field['file_name'] ?? '',
          imageUrl: field['image_url'] ?? '',
          originalUrl: field['original_url'] ?? '',
        );
      }
      return null;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        final dt = DateTime.tryParse(value);
        if (dt != null) return dt;
      }
      // Fallback to current time if parsing fails
      return DateTime.now();
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) {
        for (final v in value.values) {
          if (v is String) return v;
        }
      }
      return value.toString();
    }

    List<CategoryEntity> parseSubcategories(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map((subcategory) {
              try {
                return CategoryModel.fromJson(subcategory);
              } catch (e) {
                // Skip invalid subcategory
                return null;
              }
            })
            .whereType<CategoryEntity>()
            .toList();
      }
      return [];
    }

    // --- Required fields ---
    if (json['id'] == null || json['id'] is! num) {
      throw Exception(
        "Invalid or missing 'id' field in category: ${json['id']}",
      );
    }
    if (json['status'] == null || json['status'] is! num) {
      throw Exception(
        "Invalid or missing 'status' field in category: ${json['status']}",
      );
    }

    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: parseString(json['name']),
      slug: parseString(json['slug']),
      description: json['description'] as String?,
      categoryImage: parseMediaFile(json['category_image']),
      categoryIcon: parseMediaFile(json['category_icon']),
      parentId:
          json['parent_id'] == null || json['parent_id'] is! num
              ? null
              : (json['parent_id'] as num).toInt(),
      parent:
          json['parent'] != null && json['parent'] is Map<String, dynamic>
              ? CategoryModel.fromJson(json['parent'] as Map<String, dynamic>)
              : null,
      subcategories: parseSubcategories(json['subcategories']),
      status: (json['status'] as num).toInt(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? mediaFileToJson(MediaFileEntity? media) {
      if (media == null) return null;
      return {
        'id': media.id,
        'uuid': media.uuid,
        'name': media.name,
        'disk': media.disk,
        'file_name': media.fileName,
        'image_url': media.imageUrl,
        'original_url': media.originalUrl,
      };
    }

    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'category_image': mediaFileToJson(categoryImage),
      'category_icon': mediaFileToJson(categoryIcon),
      'parent_id': parentId,
      'parent': parent != null ? (parent as CategoryModel).toJson() : null,
      'subcategories':
          subcategories
              .map((subcategory) => (subcategory as CategoryModel).toJson())
              .toList(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      categoryImage: entity.categoryImage,
      categoryIcon: entity.categoryIcon,
      parentId: entity.parentId,
      parent:
          entity.parent != null
              ? CategoryModel.fromEntity(entity.parent!)
              : null,
      subcategories:
          entity.subcategories
              .map((subcategory) => CategoryModel.fromEntity(subcategory))
              .toList(),
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      slug: slug,
      description: description,
      categoryImage: categoryImage,
      categoryIcon: categoryIcon,
      parentId: parentId,
      parent: parent != null ? (parent as CategoryModel).toEntity() : null,
      subcategories:
          subcategories
              .map((subcategory) => (subcategory as CategoryModel).toEntity())
              .toList(),
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
