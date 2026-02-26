import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/paginated_products_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final LocalStorageService _localStorageService;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required LocalStorageService localStorageService,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo,
       _localStorageService = localStorageService;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int? page,
    int? limit,
    String? search,
    int? categoryId,
    String? sortBy,
    String? sortOrder,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    bool? isTrending,
    bool? isOnSale,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getProducts(
          page: page,
          limit: limit,
          search: search,
          categoryId: categoryId,
          sortBy: sortBy,
          sortOrder: sortOrder,
          minPrice: minPrice,
          maxPrice: maxPrice,
          isFeatured: isFeatured,
          isTrending: isTrending,
          isOnSale: isOnSale,
        );

        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    try {
      if (await _networkInfo.isConnected) {
        final product = await _remoteDataSource.getProductById(id);
        return Right(product.toEntity());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductBySlug(String slug) async {
    try {
      if (await _networkInfo.isConnected) {
        final product = await _remoteDataSource.getProductBySlug(slug);
        return Right(product.toEntity());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory({
    required int categoryId,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getProductsByCategory(
          categoryId: categoryId,
          page: page,
          limit: limit,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print(
        'Repository: Starting getProductsByCategorySlug for slug: $categorySlug',
      );

      if (await _networkInfo.isConnected) {
        print('Repository: Network is connected, calling remote data source');

        final products = await _remoteDataSource.getProductsByCategorySlug(
          categorySlug: categorySlug,
          page: page,
          limit: limit,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        print(
          'Repository: Remote data source returned ${products.length} products',
        );
        final entities = products.map((model) => model.toEntity()).toList();
        print('Repository: Converted to ${entities.length} entities');

        return Right(entities);
      } else {
        print('Repository: Network is not connected');
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      print('Repository: ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      print('Repository: NetworkException: $e');
      return const Left(NetworkFailure());
    } on Exception catch (e) {
      print('Repository: General Exception: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedProductsModel>>
  getPaginatedProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print(
        'Repository: Starting getPaginatedProductsByCategorySlug for slug: $categorySlug',
      );

      if (await _networkInfo.isConnected) {
        print('Repository: Network is connected, calling remote data source');

        final paginatedProducts = await _remoteDataSource
            .getPaginatedProductsByCategorySlug(
              categorySlug: categorySlug,
              page: page,
              limit: limit,
              sortBy: sortBy,
              sortOrder: sortOrder,
            );

        print(
          'Repository: Remote data source returned ${paginatedProducts.products.length} products with pagination: ${paginatedProducts.pagination}',
        );

        return Right(paginatedProducts);
      } else {
        print('Repository: Network is not connected');
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      print('Repository: ServerException: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      print('Repository: NetworkException: $e');
      return const Left(NetworkFailure());
    } on Exception catch (e) {
      print('Repository: General Exception: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getFeaturedProducts(
          limit: limit,
        );
        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts({
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getTrendingProducts(
          limit: limit,
        );
        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>>
  getTrendingProductsByCategoryIds({
    required List<int> categoryIds,
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        // Add retry logic for failed requests
        int maxRetries = 3;
        int currentTry = 0;
        while (currentTry < maxRetries) {
          try {
            final products = await _remoteDataSource
                .getTrendingProductsByCategoryIds(
                  categoryIds: categoryIds,
                  limit: limit,
                );
            return Right(products.map((model) => model.toEntity()).toList());
          } catch (e) {
            currentTry++;
            if (currentTry == maxRetries) {
              rethrow;
            }
            // Wait before retrying, with exponential backoff
            await Future.delayed(Duration(seconds: currentTry * 2));
          }
        }
        return const Left(
          ServerFailure(
            message: 'Failed to load trending products after retries',
          ),
        );
      } else {
        return const Left(NetworkFailure());
      }
    } on TimeoutException {
      return const Left(
        ServerFailure(
          message: 'Request timeout - trending products could not be loaded',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to load trending products: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsOnSale({
    int? page,
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getProductsOnSale(
          page: page,
          limit: limit,
        );
        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
    String? sku,
    String? price,
    String? category,
    int? rating,
    String? attribute,
    String? brand,
    String? field,
  }) async {
    print('Repository: Starting search with query: "$query"');
    try {
      final isConnected = await _networkInfo.isConnected;
      print(
        'Repository: Network connection status: ${isConnected ? 'connected' : 'not connected'}',
      );

      if (isConnected) {
        print('Repository: Calling remote data source');
        final products = await _remoteDataSource.searchProducts(
          query: query,
          page: page,
          limit: limit,
          sortBy: sortBy,
          sortOrder: sortOrder,
          sku: sku,
          price: price,
          category: category,
          rating: rating,
          attribute: attribute,
          brand: brand,
          field: field,
        );
        print(
          'Repository: Got ${products.length} products from remote data source',
        );
        final entities = products.map((model) => model.toEntity()).toList();
        print(
          'Repository: Converted to entities, returning ${entities.length} products',
        );
        return Right(entities);
      } else {
        print('Repository: No network connection');
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      print('Repository: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      print('Repository: Network exception');
      return const Left(NetworkFailure());
    } on Exception catch (e) {
      print('Repository: Unexpected exception: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts({
    required int productId,
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        // Add timeout to prevent endless loading
        final products = await _remoteDataSource
            .getRelatedProducts(productId: productId, limit: limit)
            .timeout(
              Duration(seconds: 8),
            ); // 8 second timeout at repository level

        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on TimeoutException {
      return const Left(
        ServerFailure(
          message: 'Request timeout - related products could not be loaded',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to load related products: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getCrossSellProducts({
    required int productId,
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getCrossSellProducts(
          productId: productId,
          limit: limit,
        );
        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductReviewEntity>>> getProductReviews({
    required int productId,
    int? page,
    int? limit,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final reviews = await _remoteDataSource.getProductReviews(
          productId: productId,
          page: page,
          limit: limit,
        );
        return Right(reviews.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ProductReviewEntity>> addProductReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final review = await _remoteDataSource.addProductReview(
          productId: productId,
          rating: rating,
          comment: comment,
        );
        return Right(review.toEntity());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductCategoryEntity>>> getCategories({
    int? parentId,
    bool? includeChildren,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final categories = await _remoteDataSource.getCategories(
          parentId: parentId,
          includeChildren: includeChildren,
        );
        return Right(categories.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductTagEntity>>> getTags() async {
    try {
      if (await _networkInfo.isConnected) {
        final tags = await _remoteDataSource.getTags();
        return Right(tags.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductVariationEntity>>> getProductVariations({
    required int productId,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final variations = await _remoteDataSource.getProductVariations(
          productId: productId,
        );
        return Right(variations.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkProductStock({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final isAvailable = await _remoteDataSource.checkProductStock(
          productId: productId,
          quantity: quantity,
        );
        return Right(isAvailable);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  // Local storage methods for recently viewed and wishlist
  @override
  Future<Either<Failure, List<ProductEntity>>> getRecentlyViewedProducts({
    int? limit,
  }) async {
    try {
      final recentlyViewed =
          _localStorageService.getList('recently_viewed_products') ?? [];
      final productIds = recentlyViewed.cast<int>();

      if (productIds.isEmpty) {
        return const Right([]);
      }

      // Get products from remote source
      final products = <ProductEntity>[];
      for (final id in productIds.take(limit ?? productIds.length)) {
        final result = await getProductById(id);
        result.fold(
          (failure) => null, // Skip failed products
          (product) => products.add(product),
        );
      }

      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addToRecentlyViewed({
    required int productId,
  }) async {
    try {
      final recentlyViewed =
          _localStorageService.getList('recently_viewed_products') ?? [];
      final productIds = recentlyViewed.cast<int>();

      // Remove if already exists to avoid duplicates
      productIds.remove(productId);

      // Add to beginning of list
      productIds.insert(0, productId);

      // Keep only last 20 items
      if (productIds.length > 20) {
        productIds.removeRange(20, productIds.length);
      }

      await _localStorageService.setList(
        'recently_viewed_products',
        productIds,
      );
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getWishlistProducts() async {
    try {
      final wishlist = _localStorageService.getList('wishlist_products') ?? [];
      final productIds = wishlist.cast<int>();

      if (productIds.isEmpty) {
        return const Right([]);
      }

      // Get products from remote source
      final products = <ProductEntity>[];
      for (final id in productIds) {
        final result = await getProductById(id);
        result.fold(
          (failure) => null, // Skip failed products
          (product) => products.add(product),
        );
      }

      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addToWishlist({required int productId}) async {
    try {
      final wishlist = _localStorageService.getList('wishlist_products') ?? [];
      final productIds = wishlist.cast<int>();

      if (!productIds.contains(productId)) {
        productIds.add(productId);
        await _localStorageService.setList('wishlist_products', productIds);
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> removeFromWishlist({
    required int productId,
  }) async {
    try {
      final wishlist = _localStorageService.getList('wishlist_products') ?? [];
      final productIds = wishlist.cast<int>();

      productIds.remove(productId);
      await _localStorageService.setList('wishlist_products', productIds);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isInWishlist({required int productId}) async {
    try {
      final wishlist = _localStorageService.getList('wishlist_products') ?? [];
      final productIds = wishlist.cast<int>();

      return Right(productIds.contains(productId));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByIds({
    required List<int> ids,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final products = await _remoteDataSource.getProductsByIds(ids: ids);
        return Right(products.map((model) => model.toEntity()).toList());
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}
