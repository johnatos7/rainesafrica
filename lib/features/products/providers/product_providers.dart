import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/cache_notifier.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/repositories/product_repository.dart';

// Data source providers
final productApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(productApiClientProvider);
  return ProductRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  final localStorageService = ref.watch(localStorageServiceProvider);

  return ProductRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
    localStorageService: localStorageService,
  );
});

// Use case providers (you can add these later when you create use cases)
// Example:
// final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
//   final repository = ref.watch(productRepositoryProvider);
//   return GetProductsUseCase(repository);
// });

// State providers for common product operations
final productsProvider =
    FutureProvider.family<List<ProductEntity>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getProducts(
        page: params['page'] as int?,
        limit: params['limit'] as int?,
        search: params['search'] as String?,
        categoryId: params['categoryId'] as int?,
        sortBy: params['sortBy'] as String?,
        sortOrder: params['sortOrder'] as String?,
        minPrice: params['minPrice'] as double?,
        maxPrice: params['maxPrice'] as double?,
        isFeatured: params['isFeatured'] as bool?,
        isTrending: params['isTrending'] as bool?,
        isOnSale: params['isOnSale'] as bool?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

final productByIdProvider = FutureProvider.family<ProductEntity, int>((
  ref,
  id,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductById(id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});

final productBySlugProvider = FutureProvider.family<ProductEntity, String>((
  ref,
  slug,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductBySlug(slug);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});

final featuredProductsProvider =
    FutureProvider.family<List<ProductEntity>, int?>((ref, limit) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getFeaturedProducts(limit: limit);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

final trendingProductsProvider =
    FutureProvider.family<List<ProductEntity>, int?>((ref, limit) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getTrendingProducts(limit: limit);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

final productsOnSaleProvider =
    FutureProvider.family<List<ProductEntity>, Map<String, int?>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getProductsOnSale(
        page: params['page'],
        limit: params['limit'],
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

final searchProductsProvider = FutureProvider.family<
  List<ProductEntity>,
  Map<String, dynamic>
>((ref, params) async {
  print('Search Provider: Starting search with params: $params');

  try {
    final repository = ref.watch(productRepositoryProvider);
    print('Search Provider: Got repository instance');

    final result = await repository
        .searchProducts(
          query: params['query'] as String,
          page: params['page'] as int?,
          limit: params['limit'] as int?,
          sortBy: params['sortBy'] as String?,
          sortOrder: params['sortOrder'] as String?,
        )
        .timeout(Duration(seconds: 15));

    print('Search Provider: Got result from repository');

    return result.fold(
      (failure) {
        print('Search Provider: Search failed with error: ${failure.message}');
        throw Exception(failure.message);
      },
      (products) {
        print(
          'Search Provider: Search successful, found ${products.length} products',
        );
        return products;
      },
    );
  } on TimeoutException {
    print('Search Provider: Search timed out after 15 seconds');
    throw Exception('Search timed out. Please try again.');
  } catch (e, stackTrace) {
    print('Search Provider: Unexpected error: $e');
    print('Search Provider: Stack trace: $stackTrace');
    throw Exception('An error occurred while searching. Please try again.');
  }
});

final productsByCategoryProvider =
    FutureProvider.family<List<ProductEntity>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getProductsByCategory(
        categoryId: params['categoryId'] as int,
        page: params['page'] as int?,
        limit: params['limit'] as int?,
        sortBy: params['sortBy'] as String?,
        sortOrder: params['sortOrder'] as String?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

// Temporary test provider to debug the infinite loop issue
final productsByCategorySlugTestProvider =
    FutureProvider.family<List<ProductEntity>, String>((
      ref,
      categorySlug,
    ) async {
      print('Test Provider: Starting for category: $categorySlug');
      await Future.delayed(Duration(seconds: 1)); // Simulate API call
      print('Test Provider: Returning empty list');
      return <ProductEntity>[]; // Return empty list for testing
    });

final productsByCategorySlugProvider = FutureProvider.family<
  List<ProductEntity>,
  Map<String, dynamic>
>((ref, params) async {
  print('Provider: Starting to fetch products by category slug');
  print('Provider: Category slug: ${params['categorySlug']}');

  try {
    final repository = ref.read(productRepositoryProvider);
    print('Provider: Repository obtained');

    // Add timeout to prevent endless loading
    final result = await repository
        .getProductsByCategorySlug(
          categorySlug: params['categorySlug'] as String,
          page: params['page'] as int?,
          limit: params['limit'] as int?,
          sortBy: params['sortBy'] as String?,
          sortOrder: params['sortOrder'] as String?,
        )
        .timeout(Duration(seconds: 15)); // Reduced timeout to 15 seconds

    print('Provider: Repository call completed');

    final products = result.fold(
      (failure) {
        print(
          'Provider: Error fetching products by category slug: ${failure.message}',
        );
        return <ProductEntity>[]; // Return empty list instead of throwing
      },
      (products) {
        print(
          'Provider: Successfully fetched ${products.length} products by category slug',
        );
        print('Provider: About to return products to UI');
        return products;
      },
    );

    print('Provider: Final products count: ${products.length}');
    print('Provider: Returning products to UI now');

    print('Provider: Future completed, returning products');
    return products;
  } on TimeoutException {
    print(
      'Provider: Timeout occurred while fetching products by category slug',
    );
    // Try to get products using a different approach as fallback
    try {
      print(
        'Provider: Attempting fallback - getting all products and filtering by category',
      );
      final fallbackRepository = ref.read(productRepositoryProvider);
      final fallbackResult = await fallbackRepository.getProducts(
        limit: 50, // Get more products to filter from
      );

      return fallbackResult.fold(
        (failure) {
          print('Provider: Fallback also failed: ${failure.message}');
          return <ProductEntity>[];
        },
        (allProducts) {
          // Filter products by category slug
          final categorySlug = params['categorySlug'] as String;
          final filteredProducts =
              allProducts
                  .where((product) {
                    return (product.categories ?? []).any(
                      (category) =>
                          category.slug.toLowerCase() ==
                          categorySlug.toLowerCase(),
                    );
                  })
                  .take(10)
                  .toList();

          print('Provider: Fallback found ${filteredProducts.length} products');
          return filteredProducts;
        },
      );
    } catch (fallbackError) {
      print('Provider: Fallback also failed: $fallbackError');
      return <ProductEntity>[];
    }
  } catch (e, stackTrace) {
    print('Provider: Exception in productsByCategorySlugProvider: $e');
    print('Provider: Stack trace: $stackTrace');
    return <ProductEntity>[]; // Return empty list instead of throwing
  }
});

// Related products with timeout and proper error handling
final relatedProductsProvider = FutureProvider.family<
  List<ProductEntity>,
  Map<String, int?>
>((ref, params) async {
  try {
    final repository = ref.read(productRepositoryProvider);

    // Add timeout to prevent endless loading
    final result = await repository
        .getRelatedProducts(
          productId: params['productId'] as int,
          limit: params['limit'],
        )
        .timeout(Duration(seconds: 10)); // 10 second timeout

    return result.fold(
      (failure) {
        print(
          'Related Products Provider: Error fetching related products: ${failure.message}',
        );
        return <ProductEntity>[]; // Return empty list instead of throwing
      },
      (products) {
        print(
          'Related Products Provider: Successfully fetched ${products.length} related products',
        );
        return products;
      },
    );
  } on TimeoutException {
    print(
      'Related Products Provider: Timeout occurred while fetching related products',
    );
    return <ProductEntity>[]; // Return empty list on timeout
  } catch (e, stackTrace) {
    print(
      'Related Products Provider: Exception in relatedProductsProvider: $e',
    );
    print('Related Products Provider: Stack trace: $stackTrace');
    return <ProductEntity>[]; // Return empty list instead of throwing
  }
});

// Trending products by category IDs with timeout and proper error handling
final trendingProductsByCategoryIdsProvider = FutureProvider.family<
  List<ProductEntity>,
  Map<String, dynamic>
>((ref, params) async {
  try {
    final repository = ref.read(productRepositoryProvider);
    final categoryIds = params['categoryIds'] as List<int>;
    final limit = params['limit'] as int?;

    // Add caching key based on params
    final cacheKey = 'trending_products_${categoryIds.join("_")}_$limit';

    // Try to get from cache first
    final cached = ref.read(productCacheProvider)[cacheKey];
    if (cached != null) {
      print('Returning cached trending products for categories: $categoryIds');
      return cached;
    }

    // Add timeout and retry logic
    int maxRetries = 2;
    int currentTry = 0;
    List<ProductEntity> products = [];

    while (currentTry < maxRetries) {
      try {
        final result = await repository
            .getTrendingProductsByCategoryIds(
              categoryIds: categoryIds,
              limit: limit,
            )
            .timeout(Duration(seconds: 15)); // Increased timeout

        result.fold(
          (failure) {
            print(
              'Trending Products Provider: Error fetching trending products (attempt ${currentTry + 1}/${maxRetries}): ${failure.message}',
            );
            throw failure; // Throw to trigger retry
          },
          (fetchedProducts) {
            print(
              'Trending Products Provider: Successfully fetched ${fetchedProducts.length} trending products',
            );
            products = fetchedProducts;

            // Cache the results
            ref.read(productCacheProvider.notifier);

            currentTry = maxRetries; // Exit loop on success
          },
        );
      } catch (e) {
        currentTry++;
        if (currentTry < maxRetries) {
          // Wait before retrying, with exponential backoff
          await Future.delayed(Duration(seconds: currentTry * 2));
        }
      }
    }

    return products; // Return products (empty list if all retries failed)
  } on TimeoutException {
    print(
      'Trending Products Provider: Timeout occurred while fetching trending products',
    );
    return <ProductEntity>[]; // Return empty list on timeout
  } catch (e, stackTrace) {
    print(
      'Trending Products Provider: Exception in trendingProductsByCategoryIdsProvider: $e',
    );
    print('Trending Products Provider: Stack trace: $stackTrace');
    return <ProductEntity>[]; // Return empty list instead of throwing
  }
});

final crossSellProductsProvider =
    FutureProvider.family<List<ProductEntity>, Map<String, int?>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getCrossSellProducts(
        productId: params['productId'] as int,
        limit: params['limit'],
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

final productReviewsProvider =
    FutureProvider.family<List<ProductReviewEntity>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getProductReviews(
        productId: params['productId'] as int,
        page: params['page'] as int?,
        limit: params['limit'] as int?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (reviews) => reviews,
      );
    });

final categoriesProvider =
    FutureProvider.family<List<ProductCategoryEntity>, Map<String, dynamic>?>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getCategories(
        parentId: params?['parentId'] as int?,
        includeChildren: params?['includeChildren'] as bool?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (categories) => categories,
      );
    });

final tagsProvider = FutureProvider<List<ProductTagEntity>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getTags();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (tags) => tags,
  );
});

final productVariationsProvider = FutureProvider.family<
  List<ProductVariationEntity>,
  int
>((ref, productId) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductVariations(productId: productId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (variations) => variations,
  );
});

final productStockProvider = FutureProvider.family<bool, Map<String, dynamic>>((
  ref,
  params,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.checkProductStock(
    productId: params['productId'] as int,
    quantity: params['quantity'] as int? ?? 1,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (isAvailable) => isAvailable,
  );
});

// Local storage providers
final recentlyViewedProductsProvider =
    FutureProvider.family<List<ProductEntity>, int?>((ref, limit) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.getRecentlyViewedProducts(limit: limit);

      return result.fold(
        (failure) => throw Exception(failure.message),
        (products) => products,
      );
    });

final wishlistProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getWishlistProducts();

  return result.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

final isInWishlistProvider = FutureProvider.family<bool, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.isInWishlist(productId: productId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (isInWishlist) => isInWishlist,
  );
});

// Action providers for mutations
final addToWishlistProvider = FutureProvider.family<void, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.addToWishlist(productId: productId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

final removeFromWishlistProvider = FutureProvider.family<void, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.removeFromWishlist(productId: productId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

final addToRecentlyViewedProvider = FutureProvider.family<void, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.addToRecentlyViewed(productId: productId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
});

final addProductReviewProvider =
    FutureProvider.family<ProductReviewEntity, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(productRepositoryProvider);
      final result = await repository.addProductReview(
        productId: params['productId'] as int,
        rating: params['rating'] as int,
        comment: params['comment'] as String?,
      );

      return result.fold(
        (failure) => throw Exception(failure.message),
        (review) => review,
      );
    });
