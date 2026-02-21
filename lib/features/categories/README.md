# Categories Feature

This feature handles category management in the Raines Africa mobile application, following Clean Architecture principles with Riverpod for state management.

## Overview

The Categories feature provides functionality to:
- Fetch all categories with pagination
- Get featured categories (first 20 categories)
- Get category details by ID or slug
- Retrieve subcategories of a parent category
- Handle hierarchical category structures with nested relationships

## API Endpoints

### Base URL
```
https://api.raines.africa/api/category
```

### Available Endpoints

#### 1. Get All Categories
```
GET /api/category?page=1&paginate=20&status=1
```

**Parameters:**
- `page` (optional): Page number for pagination (default: 1)
- `paginate` (optional): Number of items per page (default: 20)
- `status` (optional): Filter by status (default: 1 for active)

**Response Format:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Home & Kitchen",
      "slug": "home-kitchen",
      "description": "Home and kitchen products",
      "category_image": "https://example.com/image.jpg",
      "category_icon": "https://example.com/icon.jpg",
      "parent_id": null,
      "parent": null,
      "subcategories": [
        {
          "id": 2,
          "name": "Kitchen Appliances",
          "slug": "kitchen-appliances",
          "description": "Kitchen appliances and tools",
          "category_image": "https://example.com/kitchen.jpg",
          "category_icon": "https://example.com/kitchen-icon.jpg",
          "parent_id": 1,
          "parent": {
            "id": 1,
            "name": "Home & Kitchen",
            "slug": "home-kitchen"
          },
          "subcategories": [],
          "status": 1,
          "created_at": "2023-01-01T00:00:00.000000Z",
          "updated_at": "2023-01-01T00:00:00.000000Z"
        }
      ],
      "status": 1,
      "created_at": "2023-01-01T00:00:00.000000Z",
      "updated_at": "2023-01-01T00:00:00.000000Z"
    }
  ]
}
```

#### 2. Get Category by ID
```
GET /api/category/{id}
```

#### 3. Get Category by Slug
```
GET /api/category/slug/{slug}
```

#### 4. Get Featured Categories
```
GET /api/category?page=1&paginate=20&status=1
```

#### 5. Get Subcategories
```
GET /api/category?parent_id={parentId}&status=1
```

## Architecture

### Domain Layer
- **`CategoryEntity`**: Core business entity representing a category
- **`CategoryRepository`**: Abstract interface for category operations

### Data Layer
- **`CategoryModel`**: Data model with JSON serialization
- **`CategoryRemoteDataSource`**: Interface and implementation for API calls
- **`CategoryRepositoryImpl`**: Repository implementation with error handling

### Presentation Layer
- **`CategoryProviders`**: Riverpod providers for state management
- **`CategoryUsageExample`**: Example usage and service class

## Usage Examples

### 1. Get All Categories
```dart
// Using Riverpod provider
final categoriesAsync = ref.watch(categoriesProvider({
  'page': 1,
  'paginate': 20,
  'status': 1,
}));

categoriesAsync.when(
  data: (categories) => print('Found ${categories.length} categories'),
  loading: () => print('Loading...'),
  error: (error, stack) => print('Error: $error'),
);
```

### 2. Get Category by Slug
```dart
// Using Riverpod provider
final categoryAsync = ref.watch(categoryBySlugProvider('home-kitchen'));

categoryAsync.when(
  data: (category) => print('Category: ${category.name}'),
  loading: () => print('Loading...'),
  error: (error, stack) => print('Error: $error'),
);
```

### 3. Get Featured Categories
```dart
// Using Riverpod provider
final featuredCategoriesAsync = ref.watch(featuredCategoriesProvider);

featuredCategoriesAsync.when(
  data: (categories) => print('Found ${categories.length} featured categories'),
  loading: () => print('Loading...'),
  error: (error, stack) => print('Error: $error'),
);
```

### 4. Get Subcategories
```dart
// Using Riverpod provider
final subcategoriesAsync = ref.watch(subcategoriesProvider(1));

subcategoriesAsync.when(
  data: (subcategories) => print('Found ${subcategories.length} subcategories'),
  loading: () => print('Loading...'),
  error: (error, stack) => print('Error: $error'),
);
```

### 5. Using CategoryService
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryService = CategoryService(ref);
    
    return ElevatedButton(
      onPressed: () async {
        try {
          // Get all categories
          final categories = await categoryService.getAllCategories();
          print('Categories: $categories');
          
          // Get featured categories
          final featuredCategories = await categoryService.getFeaturedCategories();
          print('Featured Categories: $featuredCategories');
          
          // Get category by slug
          final category = await categoryService.getCategoryBySlug('home-kitchen');
          print('Category: $category');
          
          // Get subcategories
          final subcategories = await categoryService.getSubcategories(1);
          print('Subcategories: $subcategories');
        } catch (e) {
          print('Error: $e');
        }
      },
      child: Text('Load Categories'),
    );
  }
}
```

## Key Features

### Hierarchical Structure
- Categories can have parent-child relationships
- Subcategories are nested within parent categories
- Support for unlimited nesting levels

### Image Support
- `category_image`: Main category image
- `category_icon`: Category icon for UI display

### Status Management
- Categories have a status field for active/inactive states
- Default filtering shows only active categories (status = 1)

### Error Handling
- Comprehensive error handling with `Either<Failure, T>` pattern
- Network connectivity checks
- Graceful fallbacks for API failures

## Dependencies

- `equatable`: For value equality comparison
- `dartz`: For functional error handling
- `flutter_riverpod`: For state management
- `dio`: For HTTP requests (via API client)

## File Structure

```
lib/features/categories/
├── domain/
│   ├── entities/
│   │   └── category_entity.dart
│   └── repositories/
│       └── category_repository.dart
├── data/
│   ├── datasources/
│   │   └── category_remote_data_source.dart
│   ├── models/
│   │   └── category_model.dart
│   └── repositories/
│       └── category_repository_impl.dart
├── providers/
│   └── category_providers.dart
├── examples/
│   └── category_usage_example.dart
└── README.md
```

## Integration Notes

1. **API Client**: The `categoryApiClientProvider` needs to be implemented with your actual API client
2. **Network Info**: Uses the shared `NetworkInfo` service for connectivity checks
3. **Error Handling**: Follows the same error handling patterns as other features
4. **State Management**: Uses Riverpod providers for reactive state management

## Testing

The feature includes comprehensive error handling and can be tested with:
- Network connectivity scenarios
- API response variations
- Error conditions and edge cases
- Hierarchical category structures
