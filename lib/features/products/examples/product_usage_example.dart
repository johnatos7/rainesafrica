import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/providers/product_providers.dart';

/// Example widget showing how to use the product repository
class ProductUsageExample extends ConsumerWidget {
  const ProductUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example 1: Get all products (commented out as it's not used in this example)
    // final productsAsync = ref.watch(productsProvider({'page': 1, 'limit': 10}));

    // Example 2: Get featured products
    final featuredProductsAsync = ref.watch(featuredProductsProvider(5));

    // Example 3: Get trending products
    final trendingProductsAsync = ref.watch(trendingProductsProvider(5));

    // Example 4: Search products (iPhone example)
    final searchResultsAsync = ref.watch(
      searchProductsProvider({'query': 'Iphone', 'page': 1, 'limit': 10}),
    );

    // Example 5: Get product by slug (Samsung fridge example)
    final samsungFridgeAsync = ref.watch(
      productBySlugProvider(
        'samsung-fridge-freezer-white-bespoke-704l-fridges-with-water-dispenser80',
      ),
    );

    // Example 6: Get products by category slug (Home & Kitchen)
    final homeKitchenProductsAsync = ref.watch(
      productsByCategorySlugProvider({
        'categorySlug': 'home-kitchen',
        'page': 1,
        'limit': 10,
      }),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Product Usage Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Products Section
            const Text(
              'Featured Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: featuredProductsAsync.when(
                data:
                    (products) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R${product.effectivePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.stockStatus ?? 'N/A',
                                  style: TextStyle(
                                    color:
                                        product.isInStock
                                            ? Colors.green
                                            : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // Trending Products Section
            const Text(
              'Trending Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: trendingProductsAsync.when(
                data:
                    (products) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R${product.effectivePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (product.isOnSale)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'SALE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // Product by Slug Section
            const Text(
              'Product by Slug (Samsung Fridge)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            samsungFridgeAsync.when(
              data:
                  (product) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.shortDescription ?? '',
                            style: const TextStyle(fontSize: 14),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'R${product.effectivePrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      product.isInStock
                                          ? Colors.green
                                          : Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (product.stockStatus ?? '').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (product.categories != null && product.categories!.isNotEmpty)
                            Wrap(
                              children:
                                  product.categories!.map((category) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        right: 8,
                                        bottom: 4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
              loading:
                  () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              error:
                  (error, stack) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error loading product: $error'),
                    ),
                  ),
            ),

            const SizedBox(height: 24),

            // Home & Kitchen Products Section
            const Text(
              'Home & Kitchen Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: homeKitchenProductsAsync.when(
                data:
                    (products) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(right: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'R${product.effectivePrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        product.isInStock
                                            ? Colors.green
                                            : Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (product.stockStatus ?? '').toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('Error: $error'),
              ),
            ),

            const SizedBox(height: 24),

            // Search Results Section
            const Text(
              'Search Results for "iPhone"',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            searchResultsAsync.when(
              data:
                  (products) => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.shortDescription ?? ''),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'R${product.effectivePrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.isOnSale) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'R${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                product.stockStatus ?? 'N/A',
                                style: TextStyle(
                                  color:
                                      product.isInStock
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              if (product.averageRating > 0)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      '${product.averageRating.toStringAsFixed(1)}',
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          onTap: () {
                            // Example: Add to recently viewed
                            ref.read(addToRecentlyViewedProvider(product.id));

                            // Example: Navigate to product detail
                            // Navigator.push(context, MaterialPageRoute(
                            //   builder: (context) => ProductDetailScreen(productId: product.id),
                            // ));
                          },
                        ),
                      );
                    },
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to use the repository directly in a service or use case
class ProductService {
  final WidgetRef ref;

  ProductService(this.ref);

  /// Example method to get products with specific filters
  Future<List<ProductEntity>> getFilteredProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? isFeatured,
    bool? isOnSale,
  }) async {
    final productsAsync = ref.read(
      productsProvider({
        'search': search,
        'categoryId': categoryId,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'isFeatured': isFeatured,
        'isOnSale': isOnSale,
        'page': 1,
        'limit': 20,
      }),
    );

    return await productsAsync.when(
      data: (products) => products,
      loading: () => <ProductEntity>[],
      error:
          (error, stack) => throw Exception('Failed to load products: $error'),
    );
  }

  /// Example method to add product to wishlist
  Future<void> toggleWishlist(int productId) async {
    final isInWishlistAsync = ref.read(isInWishlistProvider(productId));

    await isInWishlistAsync.when(
      data: (isInWishlist) async {
        if (isInWishlist) {
          await ref.read(removeFromWishlistProvider(productId).future);
        } else {
          await ref.read(addToWishlistProvider(productId).future);
        }
      },
      loading: () async {},
      error: (error, stack) async {
        throw Exception('Failed to check wishlist status: $error');
      },
    );
  }

  /// Example method to get product details by ID
  Future<ProductEntity?> getProductDetails(int productId) async {
    final productAsync = ref.read(productByIdProvider(productId));

    return await productAsync.when(
      data: (product) => product,
      loading: () => null,
      error:
          (error, stack) => throw Exception('Failed to load product: $error'),
    );
  }

  /// Example method to get product details by slug
  Future<ProductEntity?> getProductDetailsBySlug(String slug) async {
    final productAsync = ref.read(productBySlugProvider(slug));

    return await productAsync.when(
      data: (product) => product,
      loading: () => null,
      error:
          (error, stack) => throw Exception('Failed to load product: $error'),
    );
  }

  /// Example method to get products by category slug
  Future<List<ProductEntity>> getProductsByCategorySlug({
    required String categorySlug,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final productsAsync = ref.read(
      productsByCategorySlugProvider({
        'categorySlug': categorySlug,
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      }),
    );

    return await productsAsync.when(
      data: (products) => products,
      loading: () => <ProductEntity>[],
      error:
          (error, stack) => throw Exception('Failed to load products: $error'),
    );
  }

  /// Example method to search products
  Future<List<ProductEntity>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? sortOrder,
  }) async {
    final productsAsync = ref.read(
      searchProductsProvider({
        'query': query,
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      }),
    );

    return await productsAsync.when(
      data: (products) => products,
      loading: () => <ProductEntity>[],
      error:
          (error, stack) =>
              throw Exception('Failed to search products: $error'),
    );
  }
}
