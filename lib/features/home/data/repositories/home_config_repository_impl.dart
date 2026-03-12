import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/datasources/home_config_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/home_config_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/domain/repositories/home_config_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/providers/product_providers.dart';

class HomeConfigRepositoryImpl implements HomeConfigRepository {
  final HomeConfigRemoteDataSource _remote;
  final Ref _ref;
  HomeConfigModel? _cache;

  HomeConfigRepositoryImpl(this._remote, this._ref);

  @override
  Future<Either<Failure, HomeConfigModel>> getHomeConfig({
    required String slug,
  }) async {
    try {
      final data = await _remote.fetchHomeConfig();
      _cache = data;
      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  ProductRepository get _productRepository =>
      _ref.read(productRepositoryProvider);

  List<int> _sanitizeIds(List<int> ids) {
    final seen = <int>{};
    final result = <int>[];
    for (final id in ids) {
      if (id > 0 && !seen.contains(id)) {
        seen.add(id);
        result.add(id);
      }
    }
    return result;
  }

  Future<Either<Failure, List<ProductEntity>>> _getProductsForSection(
    SectionProducts section,
  ) async {
    if (!section.status) {
      return const Right([]);
    }
    // Try IDs first
    final ids = _sanitizeIds(section.productIds);
    if (ids.isNotEmpty) {
      return _productRepository.getProductsByIds(ids: ids);
    }
    // Fall back to SKUs if IDs are empty
    if (section.productSkus.isNotEmpty) {
      return _productRepository.getProductsBySkus(skus: section.productSkus);
    }
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getSection1Products() async {
    final cfg = _cache ?? await _remote.fetchHomeConfig();
    _cache = cfg;
    return _getProductsForSection(cfg.content.mainContent.section1Products);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getSection4Products() async {
    final cfg = _cache ?? await _remote.fetchHomeConfig();
    _cache = cfg;
    return _getProductsForSection(cfg.content.mainContent.section4Products);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getSection7Products() async {
    final cfg = _cache ?? await _remote.fetchHomeConfig();
    _cache = cfg;
    return _getProductsForSection(cfg.content.mainContent.section7Products);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>>
  getHomeAppliancesProducts() async {
    final cfg = _cache ?? await _remote.fetchHomeConfig();
    _cache = cfg;
    return _getProductsForSection(cfg.content.mainContent.homeAppliances);
  }

  @override
  Either<Failure, List<BannerItem>> getFeaturedBannersSync() {
    final cfg = _cache;
    if (cfg == null) {
      return const Left(ServerFailure(message: 'Home config not loaded'));
    }
    final fb = cfg.content.featuredBanners;
    if (!fb.status) return const Right([]);
    return Right(fb.banners);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByIds(
    List<int> ids,
  ) async {
    final sanitizedIds = _sanitizeIds(ids);
    if (sanitizedIds.isEmpty) return const Right([]);
    return _productRepository.getProductsByIds(ids: sanitizedIds);
  }
}

// Providers
final homeConfigApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final homeConfigRemoteDataSourceProvider = Provider<HomeConfigRemoteDataSource>(
  (ref) {
    final client = ref.watch(homeConfigApiClientProvider);
    return HomeConfigRemoteDataSourceImpl(client);
  },
);

final homeConfigRepositoryProvider = Provider<HomeConfigRepository>((ref) {
  return HomeConfigRepositoryImpl(
    ref.watch(homeConfigRemoteDataSourceProvider),
    ref,
  );
});
