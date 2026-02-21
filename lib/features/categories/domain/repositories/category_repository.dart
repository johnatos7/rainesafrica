import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/paginated_categories_model.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  });

  Future<Either<Failure, List<CategoryEntity>>> getFeaturedCategories();

  Future<Either<Failure, CategoryEntity>> getCategoryById(int id);

  Future<Either<Failure, CategoryEntity>> getCategoryBySlug(String slug);

  Future<Either<Failure, List<CategoryEntity>>> getSubcategories(int parentId);

  Future<Either<Failure, PaginatedCategoriesModel>> getPaginatedCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  });
}
