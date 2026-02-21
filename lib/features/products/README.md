# Product Feature

This feature provides comprehensive product management functionality for the Raines Africa mobile app, including fetching products by ID, slug, category, and various filtering options.

## Features

- ✅ Get products with pagination and filters
- ✅ Get product by ID
- ✅ **Get product by slug** (NEW)
- ✅ Get products by category ID
- ✅ **Get products by category slug** (NEW)
- ✅ Get featured, trending, and sale products
- ✅ Search products
- ✅ Get related and cross-sell products
- ✅ Product reviews and ratings
- ✅ Categories and tags
- ✅ Local storage for wishlist and recently viewed
- ✅ Network connectivity checks
- ✅ Comprehensive error handling

## API Endpoints

The product feature integrates with the following API endpoints:

- `GET /api/product` - Get all products with filters
- `GET /api/product/{id}` - Get product by ID
- `GET /api/product/slug/{slug}` - **Get product by slug** (NEW)
- `GET /api/product?category={slug}` - **Get products by category slug** (NEW)
- `GET /api/product/{id}/related` - Get related products
- `GET /api/product/{id}/cross-sell` - Get cross-sell products
- `GET /api/product/{id}/reviews` - Get product reviews
- `POST /api/product/{id}/reviews` - Add product review
- `GET /api/categories` - Get categories
- `GET /api/tags` - Get tags

## Usage Examples

### Get Product by Slug

```dart
// Using Riverpod provider
final productAsync = ref.watch(
  productBySlugProvider('samsung-fridge-freezer-white-bespoke-704l-fridges-with-water-dispenser80')
);

productAsync.when(
  data: (product) => Text(product.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);

// Using repository directly
final repository = ref.read(productRepositoryProvider);
final result = await repository.getProductBySlug('product-slug-here');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (product) => print('Product: ${product.name}'),
);
```

### Get Product by ID

```dart
final productAsync = ref.watch(productByIdProvider(785878));
```

### Get Featured Products

```dart
final featuredProductsAsync = ref.watch(featuredProductsProvider(10));
```

### Search Products

```dart
final searchResultsAsync = ref.watch(
  searchProductsProvider({
    'query': 'Iphone',
    'page': 1,
    'limit': 20,
    'sortBy': 'price',
    'sortOrder': 'asc',
  })
);
```

### Get Products by Category ID

```dart
final categoryProductsAsync = ref.watch(
  productsByCategoryProvider({
    'categoryId': 12, // Home & Kitchen
    'page': 1,
    'limit': 20,
  })
);
```

### Get Products by Category Slug (NEW)

```dart
final categoryProductsAsync = ref.watch(
  productsByCategorySlugProvider({
    'categorySlug': 'home-kitchen', // Category slug from API
    'page': 1,
    'limit': 20,
    'sortBy': 'price',
    'sortOrder': 'asc',
  })
);
```

### Wishlist Operations

```dart
// Add to wishlist
await ref.read(addToWishlistProvider(productId).future);

// Remove from wishlist
await ref.read(removeFromWishlistProvider(productId).future);

// Check if in wishlist
final isInWishlistAsync = ref.watch(isInWishlistProvider(productId));

// Get wishlist products
final wishlistAsync = ref.watch(wishlistProductsProvider);
```

### Recently Viewed Products

```dart
// Add to recently viewed
await ref.read(addToRecentlyViewedProvider(productId).future);

// Get recently viewed
final recentlyViewedAsync = ref.watch(recentlyViewedProductsProvider(10));
```

## Product Entity Properties

The `ProductEntity` includes all the fields from your API response:

- Basic info: `id`, `name`, `slug`, `shortDescription`, `type`
- Pricing: `price`, `salePrice`, `discount`, `effectivePrice`
- Inventory: `quantity`, `stockStatus`, `isInStock`
- Features: `isFeatured`, `isTrending`, `isOnSale`
- Media: `productThumbnail`, `productMetaImage`, `productGalleries`
- Categories and tags
- Reviews and ratings
- Helper methods: `isOnSale`, `effectivePrice`, `isInStock`, `averageRating`

## Error Handling

All repository methods return `Either<Failure, T>` for consistent error handling:

- `ServerFailure` - API server errors
- `NetworkFailure` - Network connectivity issues
- `CacheFailure` - Local storage errors
- `ValidationFailure` - Input validation errors
- `AuthFailure` - Authentication errors

## Local Storage

The feature includes local storage for:
- **Wishlist products** - User's saved products
- **Recently viewed products** - Last 20 viewed products

## Network Awareness

All API calls check network connectivity before making requests and return appropriate errors when offline.

## API Response Format

All list endpoints return the consistent format `{"data": [objects]}` with pagination metadata.

### Products by Category Response

Based on the API response from [https://api.raines.africa/api/product?page=1&status=1&paginate=20&search=&field=&sortBy=&price=&category=home-kitchen&rating=&attribute=](https://api.raines.africa/api/product?page=1&status=1&paginate=20&search=&field=&sortBy=&price=&category=home-kitchen&rating=&attribute=):

```json
{
  "data": [
    {
      "id": 174416,
      "name": "Sorry 20 Oz Tumbler with Lid Straw Trendy Comic Sayings Graphic Present 212",
      "slug": "sorry-20-oz-tumbler-with-lid-straw-trendy-comic-sayings-graphic-",
      "short_description": "20 oz Slim Skinny Tumbler Stainless Steel...",
      "price": 39.69,
      "stock_status": "in_stock",
      "categories": [
        {
          "id": 12,
          "name": "Home & Kitchen",
          "slug": "home-kitchen"
        }
      ],
      "product_thumbnail": {
        "id": 1094469,
        "image_url": "https://media.takealot.com/covers_images/..."
      }
    }
  ],
  "current_page": 1,
  "last_page": 11306,
  "per_page": 20,
  "total": 226102
}
```

### Search Products Response

Based on the iPhone search example from [https://api.raines.africa/api/product?page=1&status=1&paginate=20&search=Iphone&field=&sortBy=&price=&category=&rating=&attribute=](https://api.raines.africa/api/product?page=1&status=1&paginate=20&search=Iphone&field=&sortBy=&price=&category=&rating=&attribute=):

```json
{
  "data": [
    {
      "id": 924268,
      "name": "Apple iPhone 16 Pro Max 1TB",
      "slug": "apple-iphone-16-pro-max-1tb",
      "short_description": "Display\nSuper Retina XDR display...",
      "price": 45999.00,
      "stock_status": "in_stock",
      "categories": [
        {
          "id": 16,
          "name": "Cellphones & Wearables",
          "slug": "cellphones-wearables"
        }
      ],
      "tags": [
        {
          "id": 904,
          "name": "Apple",
          "slug": "apple"
        }
      ],
      "reviews": [
        {
          "id": 328474,
          "rating": 4,
          "created_at": "2025-07-17T04:56:45.000000Z"
        }
      ]
    }
  ],
  "current_page": 1,
  "last_page": 603,
  "per_page": 20,
  "total": 12046
}
```

### Single Product Response

Based on the Samsung fridge example from [https://api.raines.africa/api/product/slug/samsung-fridge-freezer-white-bespoke-704l-fridges-with-water-dispenser80](https://api.raines.africa/api/product/slug/samsung-fridge-freezer-white-bespoke-704l-fridges-with-water-dispenser80):

```json
{
  "id": 785878,
  "name": "Samsung Fridge Freezer - White Bespoke 704L Fridges with Water Dispenser80",
  "slug": "samsung-fridge-freezer-white-bespoke-704l-fridges-with-water-dispenser80",
  "short_description": "The Samsung Bespoke 704L French Door Refrigerator...",
  "price": 25999.00,
  "stock_status": "in_stock",
  "categories": [
    {
      "id": 12,
      "name": "Home & Kitchen",
      "slug": "home-kitchen"
    }
  ],
  "product_thumbnail": {
    "id": 2982735,
    "image_url": "https://media.takealot.com/covers_images/..."
  }
}
```

This response is automatically parsed into the `ProductEntity` with all nested objects properly mapped.
