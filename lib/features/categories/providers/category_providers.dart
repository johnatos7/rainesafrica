import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/models/paginated_categories_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/repositories/category_repository.dart';

// API Client Provider for Categories
final categoryApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Network Info Provider
final categoryNetworkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity: connectivity);
});

// Remote Data Source Provider
final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(categoryApiClientProvider);
  return CategoryRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  final networkInfo = ref.watch(categoryNetworkInfoProvider);
  return CategoryRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
});

// Categories Provider
final categoriesProvider =
    FutureProvider.family<List<CategoryEntity>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(categoryRepositoryProvider);
      final result = await repository.getCategories(
        page: params['page'] ?? 1,
        paginate: params['paginate'] ?? 20,
        status: params['status'] ?? 1,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (categories) => categories,
      );
    });

// Featured Categories Provider
final featuredCategoriesProvider = FutureProvider<List<CategoryEntity>>((
  ref,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getFeaturedCategories();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

// Category by ID Provider
final categoryByIdProvider = FutureProvider.family<CategoryEntity, int>((
  ref,
  id,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getCategoryById(id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (category) => category,
  );
});

// Category by Slug Provider
final categoryBySlugProvider = FutureProvider.family<CategoryEntity, String>((
  ref,
  slug,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getCategoryBySlug(slug);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (category) => category,
  );
});

// Subcategories Provider
final subcategoriesProvider = FutureProvider.family<List<CategoryEntity>, int>((
  ref,
  parentId,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  final result = await repository.getSubcategories(parentId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (categories) => categories,
  );
});

// Paginated Categories Provider
final paginatedCategoriesProvider =
    FutureProvider.family<PaginatedCategoriesModel, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(categoryRepositoryProvider);
      final result = await repository.getPaginatedCategories(
        page: params['page'] ?? 1,
        paginate: params['paginate'] ?? 20,
        status: params['status'] ?? 1,
      );
      return result.fold(
        (failure) => throw Exception(failure.message),
        (paginatedCategories) => paginatedCategories,
      );
    });
