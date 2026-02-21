import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';

final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<ProductModel>>(() {
      return ProductsNotifier();
    });

class ProductsNotifier extends AsyncNotifier<List<ProductModel>> {
  late final ProductRemoteDataSource _productRemoteDataSource;

  @override
  Future<List<ProductModel>> build() async {
    _productRemoteDataSource = ref.read(productRemoteDataSourceProvider);
    return [];
  }

  Future<void> loadProductsByCategorySlug({
    required String categorySlug,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    state = const AsyncLoading();

    try {
      final products = await _productRemoteDataSource.getProductsByCategorySlug(
        categorySlug: categorySlug,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // If it's the first page, replace the state
      // If it's a subsequent page, append to existing products
      state = AsyncData(
        page == 1 ? products : [...state.value ?? [], ...products],
      );
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

// Provider for ProductRemoteDataSource
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final apiClient = ApiClient();
  return ProductRemoteDataSourceImpl(apiClient: apiClient);
});
