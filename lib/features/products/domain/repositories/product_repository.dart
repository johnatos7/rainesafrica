import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/paginated_products_model.dart';

abstract class ProductRepository {
  /// Get all products with optional pagination and filters
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
  });

  /// Get a single product by ID
  Future<Either<Failure, ProductEntity>> getProductById(int id);

  /// Get a single product by slug
  Future<Either<Failure, ProductEntity>> getProductBySlug(String slug);

  /// Get products by category ID
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory({
    required int categoryId,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  });

  /// Get products by category slug
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  });

  /// Get paginated products by category slug
  Future<Either<Failure, PaginatedProductsModel>>
  getPaginatedProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  });

  /// Get featured products
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts({
    int? limit,
  });

  /// Get trending products
  Future<Either<Failure, List<ProductEntity>>> getTrendingProducts({
    int? limit,
  });

  /// Get trending products by category IDs
  Future<Either<Failure, List<ProductEntity>>>
  getTrendingProductsByCategoryIds({
    required List<int> categoryIds,
    int? limit,
  });

  /// Get products on sale
  Future<Either<Failure, List<ProductEntity>>> getProductsOnSale({
    int? page,
    int? limit,
  });

  /// Search products by keyword
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
  });

  /// Get related products for a given product
  Future<Either<Failure, List<ProductEntity>>> getRelatedProducts({
    required int productId,
    int? limit,
  });

  /// Get cross-sell products for a given product
  Future<Either<Failure, List<ProductEntity>>> getCrossSellProducts({
    required int productId,
    int? limit,
  });

  /// Get product reviews
  Future<Either<Failure, List<ProductReviewEntity>>> getProductReviews({
    required int productId,
    int? page,
    int? limit,
  });

  /// Add a product review
  Future<Either<Failure, ProductReviewEntity>> addProductReview({
    required int productId,
    required int rating,
    String? comment,
  });

  /// Get product categories
  Future<Either<Failure, List<ProductCategoryEntity>>> getCategories({
    int? parentId,
    bool? includeChildren,
  });

  /// Get product tags
  Future<Either<Failure, List<ProductTagEntity>>> getTags();

  /// Get product variations
  Future<Either<Failure, List<ProductVariationEntity>>> getProductVariations({
    required int productId,
  });

  /// Check product stock availability
  Future<Either<Failure, bool>> checkProductStock({
    required int productId,
    int quantity = 1,
  });

  /// Get products by explicit list of IDs using /api/product?ids=1,2,3
  Future<Either<Failure, List<ProductEntity>>> getProductsByIds({
    required List<int> ids,
  });

  /// Get products by explicit list of SKUs using /api/product?skus=sku1,sku2
  Future<Either<Failure, List<ProductEntity>>> getProductsBySkus({
    required List<String> skus,
  });

  /// Get recently viewed products (from local storage)
  Future<Either<Failure, List<ProductEntity>>> getRecentlyViewedProducts({
    int? limit,
  });

  /// Add product to recently viewed (save to local storage)
  Future<Either<Failure, void>> addToRecentlyViewed({required int productId});

  /// Get wishlist products (from local storage)
  Future<Either<Failure, List<ProductEntity>>> getWishlistProducts();

  /// Add product to wishlist (save to local storage)
  Future<Either<Failure, void>> addToWishlist({required int productId});

  /// Remove product from wishlist (remove from local storage)
  Future<Either<Failure, void>> removeFromWishlist({required int productId});

  /// Check if product is in wishlist
  Future<Either<Failure, bool>> isInWishlist({required int productId});
}
