import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/home_config_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/home_config_model.dart'
    show BannerItem;

abstract class HomeConfigRepository {
  Future<Either<Failure, HomeConfigModel>> getHomeConfig({
    required String slug,
  });

  /// Convenience: section products fetchers using IDs from home config
  Future<Either<Failure, List<ProductEntity>>> getSection1Products();
  Future<Either<Failure, List<ProductEntity>>> getSection4Products();
  Future<Either<Failure, List<ProductEntity>>> getSection7Products();
  Future<Either<Failure, List<ProductEntity>>> getHomeAppliancesProducts();

  /// Featured banners for home slider/hero
  Either<Failure, List<BannerItem>> getFeaturedBannersSync();

  /// Get products by IDs
  Future<Either<Failure, List<ProductEntity>>> getProductsByIds(List<int> ids);
}
