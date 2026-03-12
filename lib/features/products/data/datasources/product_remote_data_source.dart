import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/paginated_products_model.dart';

abstract class ProductRemoteDataSource {
  /// Get all products with optional pagination and filters
  Future<List<ProductModel>> getProducts({
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
  });

  /// Get a single product by ID
  Future<ProductModel> getProductById(int id);

  /// Get a single product by slug
  Future<ProductModel> getProductBySlug(String slug);

  /// Get products by category ID
  Future<List<ProductModel>> getProductsByCategory({
    required int categoryId,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  });

  /// Get products by category slug
  Future<List<ProductModel>> getProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  });

  /// Get paginated products by category slug
  Future<PaginatedProductsModel> getPaginatedProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
    String? field,
  });

  /// Get featured products
  Future<List<ProductModel>> getFeaturedProducts({int? limit});

  /// Get trending products
  Future<List<ProductModel>> getTrendingProducts({int? limit});

  /// Get trending products by category IDs
  Future<List<ProductModel>> getTrendingProductsByCategoryIds({
    required List<int> categoryIds,
    int? limit,
  });

  /// Get products on sale
  Future<List<ProductModel>> getProductsOnSale({int? page, int? limit});

  /// Search products by keyword
  Future<List<ProductModel>> searchProducts({
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
  });

  /// Get related products for a given product
  Future<List<ProductModel>> getRelatedProducts({
    required int productId,
    int? limit,
  });

  /// Get cross-sell products for a given product
  Future<List<ProductModel>> getCrossSellProducts({
    required int productId,
    int? limit,
  });

  /// Get product reviews
  Future<List<ProductReviewModel>> getProductReviews({
    required int productId,
    int? page,
    int? limit,
  });

  /// Add a product review
  Future<ProductReviewModel> addProductReview({
    required int productId,
    required int rating,
    String? comment,
  });

  /// Get product categories
  Future<List<ProductCategoryModel>> getCategories({
    int? parentId,
    bool? includeChildren,
  });

  /// Get product tags
  Future<List<ProductTagModel>> getTags();

  /// Get product variations
  Future<List<ProductVariationModel>> getProductVariations({
    required int productId,
  });

  /// Check product stock availability
  Future<bool> checkProductStock({required int productId, int quantity = 1});

  /// Get products by explicit list of IDs using /api/product?ids=1,2,3
  Future<List<ProductModel>> getProductsByIds({required List<int> ids});

  /// Get products by explicit list of SKUs using /api/product?skus=sku1,sku2
  Future<List<ProductModel>> getProductsBySkus({required List<String> skus});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ProductModel>> getProducts({
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
      final queryParams = <String, dynamic>{
        'status': 1, // Only active products
      };

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['paginate'] = limit;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
      if (minPrice != null) queryParams['price'] = minPrice;
      if (maxPrice != null) queryParams['price'] = maxPrice;
      if (isFeatured != null) queryParams['is_featured'] = isFeatured ? 1 : 0;
      if (isTrending != null) queryParams['is_trending'] = isTrending ? 1 : 0;
      if (isOnSale != null) queryParams['is_on_sale'] = isOnSale ? 1 : 0;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getProducts');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getProducts: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getProducts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get('/api/product/$id');

    if (response is Map<String, dynamic>) {
      return ProductModel.fromJson(response);
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _apiClient.get('/api/product/slug/$slug');

    if (response is Map<String, dynamic>) {
      try {
        return ProductModel.fromJson(response);
      } catch (e) {
        print('Error parsing product by slug "$slug": $e');
        throw Exception('Failed to parse product data: $e');
      }
    }

    throw Exception('Invalid response format for slug: $slug');
  }

  @override
  Future<List<ProductModel>> getProductsByCategory({
    required int categoryId,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'category_id': categoryId,
        'status': 1, // Only active products
      };

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['paginate'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getProductsByCategory');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getProductsByCategory: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getProductsByCategory: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      'category': categorySlug,
      'status': 1, // Only active products
      'paginate': limit ?? 20,
    };

    if (page != null) queryParams['page'] = page;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

    print('Fetching products by category slug: $categorySlug');
    print('Query params: $queryParams');

    final response = await _apiClient.get(
      '/api/product',
      queryParameters: queryParams,
    );

    print('API Response: $response');

    if (response is Map<String, dynamic>) {
      final data = response;

      // Handle different possible response structures
      if (data.containsKey('data') && data['data'] is List) {
        final products =
            (data['data'] as List)
                .map(
                  (json) => ProductModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        print('Found ${products.length} products');
        return products;
      }

      // Handle direct array response
      if (data is List) {
        final products =
            (data as List)
                .map(
                  (json) => ProductModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        print('Found ${products.length} products (direct array)');
        return products;
      }

      // Handle response with products key
      if (data.containsKey('products') && data['products'] is List) {
        final products =
            (data['products'] as List)
                .map(
                  (json) => ProductModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        print('Found ${products.length} products (products key)');
        return products;
      }
    }

    // If response is a list directly
    if (response is List) {
      final products =
          response
              .map(
                (json) => ProductModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
      print('Found ${products.length} products (direct list)');
      return products;
    }

    print('Invalid response format: ${response.runtimeType}');
    return []; // Return empty list instead of throwing exception
  }

  @override
  Future<PaginatedProductsModel> getPaginatedProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
    String? field,
  }) async {
    final queryParams = <String, dynamic>{
      'category': categorySlug,
      'status': 1, // Only active products
      'paginate': limit ?? 20,
    };

    if (page != null) queryParams['page'] = page;
    if (field != null && field.isNotEmpty) queryParams['field'] = field;
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty)
      queryParams['sortOrder'] = sortOrder;

    print('Fetching paginated products by category slug: $categorySlug');
    print('Query params: $queryParams');

    try {
      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      print('API Response: $response');

      if (response is Map<String, dynamic>) {
        return PaginatedProductsModel.fromJson(response);
      }

      print('Invalid response format: ${response.runtimeType}');
      // Return empty paginated response
      return PaginatedProductsModel.fromJson({
        'data': [],
        'current_page': 1,
        'last_page': 1,
        'per_page': limit ?? 20,
        'total': 0,
      });
    } catch (e, stackTrace) {
      print('Error in getPaginatedProductsByCategorySlug: $e');
      print('Stack trace: $stackTrace');
      // Return empty paginated response
      return PaginatedProductsModel.fromJson({
        'data': [],
        'current_page': 1,
        'last_page': 1,
        'per_page': limit ?? 20,
        'total': 0,
      });
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{
        'is_featured': 1,
        'status': 1, // Only active products
      };

      if (limit != null) queryParams['paginate'] = limit;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getFeaturedProducts');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getFeaturedProducts: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getFeaturedProducts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getTrendingProducts({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{
        'is_trending': 1,
        'status': 1, // Only active products
      };

      if (limit != null) queryParams['paginate'] = limit;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getTrendingProducts');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getTrendingProducts: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getTrendingProducts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getTrendingProductsByCategoryIds({
    required List<int> categoryIds,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'trending': 1,
        'status': 1, // Only active products
        'category_ids': categoryIds.join(','), // Join category IDs with commas
      };

      if (limit != null) queryParams['paginate'] = limit;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getTrendingProductsByCategoryIds');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getTrendingProductsByCategoryIds: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getTrendingProductsByCategoryIds: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getProductsOnSale({int? page, int? limit}) async {
    try {
      final queryParams = <String, dynamic>{
        'is_on_sale': 1,
        'status': 1, // Only active products
      };

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['paginate'] = limit;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getProductsOnSale');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getProductsOnSale: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getProductsOnSale: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> searchProducts({
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
    try {
      final queryParams = <String, dynamic>{
        'search': query,
        'status': 1, // Only active products
      };

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['paginate'] = limit;
      if (field != null && field.isNotEmpty) queryParams['field'] = field;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty)
        queryParams['sortOrder'] = sortOrder;
      if (sku != null && sku.isNotEmpty) queryParams['sku'] = sku;

      // Elasticsearch filters
      if (price != null && price.isNotEmpty) queryParams['price'] = price;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;
      if (rating != null && rating > 0) queryParams['rating'] = rating;
      if (attribute != null && attribute.isNotEmpty)
        queryParams['attribute'] = attribute;
      if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;

      print('Search API query params: $queryParams');

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      // Debug: Log raw search response before parsing
      print('Search API raw response: ' + response.toString());

      if (response == null) {
        print('Null response received in searchProducts');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in searchProducts: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in searchProducts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Search products with pagination info (returns total count from server)
  Future<PaginatedProductsModel> searchProductsPaginated({
    required String query,
    int? page,
    int? limit,
    String? sku,
    String? price,
    int? rating,
    String? field,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{'search': query, 'status': 1};

      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['paginate'] = limit;
      if (field != null && field.isNotEmpty) queryParams['field'] = field;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (sku != null && sku.isNotEmpty) queryParams['sku'] = sku;
      if (price != null && price.isNotEmpty) queryParams['price'] = price;
      if (rating != null && rating > 0) queryParams['rating'] = rating;

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response is Map<String, dynamic>) {
        return PaginatedProductsModel.fromJson(response);
      }

      return PaginatedProductsModel.fromJson({
        'data': [],
        'current_page': 1,
        'last_page': 1,
        'per_page': limit ?? 20,
        'total': 0,
      });
    } catch (e, stackTrace) {
      print('Error in searchProductsPaginated: $e');
      print('Stack trace: $stackTrace');
      return PaginatedProductsModel.fromJson({
        'data': [],
        'current_page': 1,
        'last_page': 1,
        'per_page': limit ?? 20,
        'total': 0,
      });
    }
  }

  @override
  Future<List<ProductModel>> getRelatedProducts({
    required int productId,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'is_featured': 1,
        'status': 1, // Only active products
        'paginate':
            (limit ?? 10) + 5, // Get a few extra to account for filtering
      };

      final response = await _apiClient.get(
        '/api/product',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getRelatedProducts');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        final products =
            (response['data'] as List)
                .map(
                  (item) => ProductModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();

        // Filter out the current product and limit results
        final relatedProducts =
            products
                .where((product) => product.id != productId)
                .take(limit ?? 10)
                .toList();

        return relatedProducts;
      }

      print(
        'Response format not recognized in getRelatedProducts: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getRelatedProducts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getCrossSellProducts({
    required int productId,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['paginate'] = limit;

      final response = await _apiClient.get(
        '/api/product/$productId/cross-sell',
        queryParameters: queryParams,
      );

      if (response == null) {
        print('Null response received in getCrossSellProducts');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      print(
        'Response format not recognized in getCrossSellProducts: ${response.runtimeType}',
      );
      return [];
    } catch (e, stackTrace) {
      print('Error in getCrossSellProducts: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductReviewModel>> getProductReviews({
    required int productId,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['paginate'] = limit;

    final response = await _apiClient.get(
      '/api/product/$productId/reviews',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      final data = response;
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (json) =>
                  ProductReviewModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<ProductReviewModel> addProductReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{'rating': rating};

    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    final response = await _apiClient.post(
      '/api/product/$productId/reviews',
      data: body,
    );

    if (response is Map<String, dynamic>) {
      return ProductReviewModel.fromJson(response);
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<List<ProductCategoryModel>> getCategories({
    int? parentId,
    bool? includeChildren,
  }) async {
    final queryParams = <String, dynamic>{};
    if (parentId != null) queryParams['parent_id'] = parentId;
    if (includeChildren != null)
      queryParams['include_children'] = includeChildren;

    final response = await _apiClient.get(
      '/api/categories',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic>) {
      final data = response;
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (json) =>
                  ProductCategoryModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<List<ProductTagModel>> getTags() async {
    final response = await _apiClient.get('/api/tags');

    if (response is Map<String, dynamic>) {
      final data = response;
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (json) => ProductTagModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<List<ProductVariationModel>> getProductVariations({
    required int productId,
  }) async {
    final response = await _apiClient.get('/api/product/$productId/variations');

    if (response is Map<String, dynamic>) {
      final data = response;
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (json) =>
                  ProductVariationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<bool> checkProductStock({
    required int productId,
    int quantity = 1,
  }) async {
    final response = await _apiClient.get(
      '/api/product/$productId/stock',
      queryParameters: {'quantity': quantity},
    );

    if (response is Map<String, dynamic>) {
      final data = response;
      return data['available'] == true;
    }

    throw Exception('Invalid response format');
  }

  @override
  Future<List<ProductModel>> getProductsByIds({required List<int> ids}) async {
    final sanitized = ids.where((e) => e > 0).toList();
    if (sanitized.isEmpty) return [];

    try {
      final response = await _apiClient.get(
        '/api/product',
        queryParameters: {'ids': sanitized.join(',')},
      );

      print('API Response for getProductsByIds: $response'); // Debug log

      if (response == null) {
        print('Null response received');
        return [];
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      print('Error in getProductsByIds: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getProductsBySkus({
    required List<String> skus,
  }) async {
    final sanitized = skus.where((e) => e.trim().isNotEmpty).toList();
    if (sanitized.isEmpty) return [];

    try {
      final response = await _apiClient.get(
        '/api/product',
        queryParameters: {'paginate': '200', 'skus': sanitized.join(',')},
      );

      if (response == null) return [];

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      print('Error in getProductsBySkus: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
