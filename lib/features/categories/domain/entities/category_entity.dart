import 'package:equatable/equatable.dart';
import 'media_file_entity.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String? name;
  final String? slug;
  final String? description;
  final MediaFileEntity? categoryImage;
  final MediaFileEntity? categoryIcon;
  final int? parentId;
  final CategoryEntity? parent;
  final List<CategoryEntity> subcategories;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.categoryImage,
    this.categoryIcon,
    this.parentId,
    this.parent,
    required this.subcategories,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    categoryImage,
    categoryIcon,
    parentId,
    parent,
    subcategories,
    status,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, slug: $slug, description: $description, categoryImage: $categoryImage, categoryIcon: $categoryIcon, parentId: $parentId, parent: $parent, subcategories: $subcategories, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
