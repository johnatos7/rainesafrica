import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/providers/category_providers.dart';

class CategoryUsageExample extends ConsumerWidget {
  const CategoryUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category Usage Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Usage Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Example 1: Get all categories
            _buildExampleCard(
              title: '1. Get All Categories',
              description: 'Fetch all categories with pagination',
              child: _buildCategoriesExample(ref),
            ),

            const SizedBox(height: 20),

            // Example 2: Get category by slug
            _buildExampleCard(
              title: '2. Get Category by Slug',
              description: 'Fetch a specific category using its slug',
              child: _buildCategoryBySlugExample(ref),
            ),

            const SizedBox(height: 20),

            // Example 3: Get featured categories
            _buildExampleCard(
              title: '3. Get Featured Categories',
              description: 'Fetch first 20 categories (featured)',
              child: _buildFeaturedCategoriesExample(ref),
            ),

            const SizedBox(height: 20),

            // Example 4: Get subcategories
            _buildExampleCard(
              title: '4. Get Subcategories',
              description: 'Fetch subcategories of a parent category',
              child: _buildSubcategoriesExample(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesExample(WidgetRef ref) {
    final categoriesAsync = ref.watch(
      categoriesProvider({'page': 1, 'paginate': 20, 'status': 1}),
    );

    return categoriesAsync.when(
      data:
          (categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Found ${categories.length} categories:'),
              const SizedBox(height: 8),
              ...categories
                  .take(3)
                  .map(
                    (category) => ListTile(
                      title: Text(category.name ?? ''),
                      subtitle: Text('Slug: ${category.slug}'),
                      trailing: Text(
                        '${category.subcategories.length} subcategories',
                      ),
                    ),
                  ),
              if (categories.length > 3)
                Text('... and ${categories.length - 3} more'),
            ],
          ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildCategoryBySlugExample(WidgetRef ref) {
    final categoryAsync = ref.watch(categoryBySlugProvider('home-kitchen'));

    return categoryAsync.when(
      data:
          (category) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${category.name}'),
              Text('Slug: ${category.slug}'),
              if (category.description != null)
                Text('Description: ${category.description}'),
              Text('Subcategories: ${category.subcategories.length}'),
              if (category.categoryImage != null)
                Text('Image: ${category.categoryImage?.imageUrl}'),
            ],
          ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildFeaturedCategoriesExample(WidgetRef ref) {
    final featuredCategoriesAsync = ref.watch(featuredCategoriesProvider);

    return featuredCategoriesAsync.when(
      data:
          (categories) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Found ${categories.length} featured categories:'),
              const SizedBox(height: 8),
              ...categories
                  .take(3)
                  .map(
                    (category) => ListTile(
                      title: Text(category.name ?? ''),
                      subtitle: Text('Slug: ${category.slug}'),
                      trailing: Text(
                        '${category.subcategories.length} subcategories',
                      ),
                    ),
                  ),
              if (categories.length > 3)
                Text('... and ${categories.length - 3} more'),
            ],
          ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildSubcategoriesExample(WidgetRef ref) {
    final subcategoriesAsync = ref.watch(
      subcategoriesProvider(1),
    ); // Assuming category ID 1 has subcategories

    return subcategoriesAsync.when(
      data:
          (subcategories) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Found ${subcategories.length} subcategories:'),
              const SizedBox(height: 8),
              ...subcategories
                  .take(3)
                  .map(
                    (subcategory) => ListTile(
                      title: Text(subcategory.name ?? ''),
                      subtitle: Text('Slug: ${subcategory.slug}'),
                    ),
                  ),
              if (subcategories.length > 3)
                Text('... and ${subcategories.length - 3} more'),
            ],
          ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// Service class for easier category management
class CategoryService {
  final WidgetRef ref;

  CategoryService(this.ref);

  /// Get all categories with optional pagination
  Future<List<dynamic>> getAllCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  }) async {
    try {
      final categoriesAsync = ref.read(
        categoriesProvider({
          'page': page,
          'paginate': paginate,
          'status': status,
        }).future,
      );

      final categories = await categoriesAsync;
      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  /// Get featured categories (first 20 categories)
  Future<List<dynamic>> getFeaturedCategories() async {
    try {
      final featuredCategoriesAsync = ref.read(
        featuredCategoriesProvider.future,
      );
      return await featuredCategoriesAsync;
    } catch (e) {
      throw Exception('Failed to fetch featured categories: $e');
    }
  }

  /// Get category by slug
  Future<dynamic> getCategoryBySlug(String slug) async {
    try {
      final categoryAsync = ref.read(categoryBySlugProvider(slug).future);
      return await categoryAsync;
    } catch (e) {
      throw Exception('Failed to fetch category by slug: $e');
    }
  }

  /// Get subcategories of a parent category
  Future<List<dynamic>> getSubcategories(int parentId) async {
    try {
      final subcategoriesAsync = ref.read(
        subcategoriesProvider(parentId).future,
      );
      return await subcategoriesAsync;
    } catch (e) {
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  /// Get category by ID
  Future<dynamic> getCategoryById(int id) async {
    try {
      final categoryAsync = ref.read(categoryByIdProvider(id).future);
      return await categoryAsync;
    } catch (e) {
      throw Exception('Failed to fetch category by ID: $e');
    }
  }
}
