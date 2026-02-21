import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/category_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/paginated_categories_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final List<CategoryModel> categoryModels = await remoteDataSource
            .getCategories(page: page, paginate: paginate, status: status);
        final List<CategoryEntity> categories =
            categoryModels.map((model) => model.toEntity()).toList();
        return Right(categories);
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getFeaturedCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final List<CategoryModel> categoryModels =
            await remoteDataSource.getFeaturedCategories();
        final List<CategoryEntity> categories =
            categoryModels.map((model) => model.toEntity()).toList();
        return Right(categories);
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final CategoryModel categoryModel = await remoteDataSource
            .getCategoryById(id);
        return Right(categoryModel.toEntity());
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> getCategoryBySlug(String slug) async {
    if (await networkInfo.isConnected) {
      try {
        final CategoryModel categoryModel = await remoteDataSource
            .getCategoryBySlug(slug);
        return Right(categoryModel.toEntity());
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getSubcategories(
    int parentId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final List<CategoryModel> categoryModels = await remoteDataSource
            .getSubcategories(parentId);
        final List<CategoryEntity> categories =
            categoryModels.map((model) => model.toEntity()).toList();
        return Right(categories);
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedCategoriesModel>> getPaginatedCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final PaginatedCategoriesModel paginatedCategories =
            await remoteDataSource.getPaginatedCategories(
              page: page,
              paginate: paginate,
              status: status,
            );
        return Right(paginatedCategories);
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
