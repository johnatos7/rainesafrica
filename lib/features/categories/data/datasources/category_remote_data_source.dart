import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/category_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/paginated_categories_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  });

  Future<List<CategoryModel>> getFeaturedCategories();

  Future<CategoryModel> getCategoryById(int id);

  Future<CategoryModel> getCategoryBySlug(String slug);

  Future<List<CategoryModel>> getSubcategories(int parentId);

  Future<PaginatedCategoriesModel> getPaginatedCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  });
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final dynamic apiClient;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<CategoryModel>> getCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  }) async {
    try {
      final response = await apiClient.get(
        '/api/category',
        queryParameters: {'page': page, 'paginate': paginate, 'status': status},
      );

      // Support both wrapped response { data: [...] } or a raw list
      final dynamic payload = response;
      List<dynamic> data;
      if (payload is Map<String, dynamic> && payload['data'] is List) {
        data = payload['data'] as List<dynamic>;
      } else if (payload is List) {
        data = payload;
      } else {
        throw Exception('Invalid response format for categories');
      }

      return data
          .map(
            (category) =>
                CategoryModel.fromJson(category as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getFeaturedCategories() async {
    try {
      final response = await apiClient.get(
        '/api/category',
        queryParameters: {'page': 1, 'paginate': 20, 'status': 1},
      );
      print("******************************");
      print(response);

      final dynamic payload = response;
      List<dynamic> data;
      if (payload is Map<String, dynamic> && payload['data'] is List) {
        data = payload['data'] as List<dynamic>;
      } else if (payload is List) {
        data = payload;
      } else {
        throw Exception('Invalid response format for featured categories');
      }

      return data
          .map(
            (category) =>
                CategoryModel.fromJson(category as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured categories:*****');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(int id) async {
    try {
      final response = await apiClient.get('/api/category/$id');
      if (response is Map<String, dynamic>) {
        return CategoryModel.fromJson(response);
      }
      throw Exception('Invalid response format for category');
    } catch (e) {
      throw Exception('Failed to fetch category by id: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryBySlug(String slug) async {
    try {
      final response = await apiClient.get('/api/category/slug/$slug');
      if (response is Map<String, dynamic>) {
        return CategoryModel.fromJson(response);
      }
      throw Exception('Invalid response format for category');
    } catch (e) {
      throw Exception('Failed to fetch category by slug: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getSubcategories(int parentId) async {
    try {
      final response = await apiClient.get(
        '/api/category',
        queryParameters: {'parent_id': parentId, 'status': 1},
      );

      final dynamic payload = response;
      List<dynamic> data;
      if (payload is Map<String, dynamic> && payload['data'] is List) {
        data = payload['data'] as List<dynamic>;
      } else if (payload is List) {
        data = payload;
      } else {
        throw Exception('Invalid response format for subcategories');
      }

      return data
          .map(
            (category) =>
                CategoryModel.fromJson(category as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  @override
  Future<PaginatedCategoriesModel> getPaginatedCategories({
    int page = 1,
    int paginate = 20,
    int status = 1,
  }) async {
    try {
      final response = await apiClient.get(
        '/api/category',
        queryParameters: {'page': page, 'paginate': paginate, 'status': status},
      );

      print('Paginated Categories API Response: $response');

      if (response is Map<String, dynamic>) {
        return PaginatedCategoriesModel.fromJson(response);
      }

      print('Invalid response format: ${response.runtimeType}');
      throw Exception('Invalid response format for paginated categories');
    } catch (e) {
      throw Exception('Failed to fetch paginated categories: $e');
    }
  }
}
