import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/home_config_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/repositories/home_config_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

// Fetch the home config once (slug kept for API shape; backend ignores it)
final homeConfigProvider = FutureProvider<HomeConfigModel>((ref) async {
  final repo = ref.watch(homeConfigRepositoryProvider);
  final result = await repo.getHomeConfig(slug: 'paris');
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});

// Featured banners images from home config
final featuredBannersProvider = FutureProvider<List<BannerItem>>((ref) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final fb = cfg.content.featuredBanners;
  return fb.status ? fb.banners : <BannerItem>[];
});

// Home banner images (main_banner, sub_banner_1, sub_banner_2)
final homeBannerImagesProvider = FutureProvider<List<String>>((ref) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final hb = cfg.content.homeBanner;
  return [
    hb.mainBanner.imageUrl,
    hb.subBanner1.imageUrl,
    hb.subBanner2.imageUrl,
  ].where((url) => url.isNotEmpty).toList();
});

// --- Section titles & status from API ---

class SectionInfo {
  final String title;
  final bool status;
  const SectionInfo({required this.title, required this.status});
}

final sectionInfoProvider = FutureProvider<Map<String, SectionInfo>>((
  ref,
) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final mc = cfg.content.mainContent;
  return {
    'section1': SectionInfo(
      title: mc.section1Products.title,
      status: mc.section1Products.status,
    ),
    'section4': SectionInfo(
      title: mc.section4Products.title,
      status: mc.section4Products.status,
    ),
    'section7': SectionInfo(
      title: mc.section7Products.title,
      status: mc.section7Products.status,
    ),
    'home_appliances': SectionInfo(
      title: mc.homeAppliances.title,
      status: mc.homeAppliances.status,
    ),
    'categories': SectionInfo(
      title: mc.section2CategoriesList.title,
      status: mc.section2CategoriesList.status,
    ),
    'section3_banners': SectionInfo(
      title: 'Promotions',
      status: mc.section3TwoColumnBanners.status,
    ),
    'section5_coupons': SectionInfo(
      title: 'Deals',
      status: mc.section5Coupons.status,
    ),
    'section6_banners': SectionInfo(
      title: 'Promotions',
      status: mc.section6TwoColumnBanners.status,
    ),
    'section8_banner': SectionInfo(
      title: 'Featured',
      status: mc.section8FullWidthBanner.status,
    ),
  };
});

// --- Banner data providers ---

final section3BannersProvider = FutureProvider<TwoColumnBanners?>((ref) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final b = cfg.content.mainContent.section3TwoColumnBanners;
  return b.status ? b : null;
});

final section5CouponProvider = FutureProvider<SectionBanner?>((ref) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final b = cfg.content.mainContent.section5Coupons;
  return b.status ? b : null;
});

final section6BannersProvider = FutureProvider<TwoColumnBanners?>((ref) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final b = cfg.content.mainContent.section6TwoColumnBanners;
  return b.status ? b : null;
});

final section8BannerProvider = FutureProvider<SectionBanner?>((ref) async {
  final cfg = await ref.watch(homeConfigProvider.future);
  final b = cfg.content.mainContent.section8FullWidthBanner;
  return b.status ? b : null;
});

// --- Product section providers ---

// Section 1 products (e.g. "Trending In Fridges & Freezers")
final section1ProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  ref.watch(currencyProvider);
  await ref.watch(homeConfigProvider.future);
  final repo = ref.watch(homeConfigRepositoryProvider);
  final res = await repo.getSection1Products();
  return res.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

// Section 4 products (e.g. "Back to School")
final section4ProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  ref.watch(currencyProvider);
  await ref.watch(homeConfigProvider.future);
  final repo = ref.watch(homeConfigRepositoryProvider);
  final res = await repo.getSection4Products();
  return res.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

// Section 7 products (e.g. "Trending TVs")
final section7ProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  ref.watch(currencyProvider);
  await ref.watch(homeConfigProvider.future);
  final repo = ref.watch(homeConfigRepositoryProvider);
  final res = await repo.getSection7Products();
  return res.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

// Home Appliances products (e.g. "Trending in Laundry")
final homeAppliancesProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  ref.watch(currencyProvider);
  await ref.watch(homeConfigProvider.future);
  final repo = ref.watch(homeConfigRepositoryProvider);
  final res = await repo.getHomeAppliancesProducts();
  return res.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});

// Top Picks products from home content productsIds
final topPicksProductsProvider = FutureProvider<List<ProductEntity>>((
  ref,
) async {
  ref.watch(currencyProvider);
  final config = await ref.watch(homeConfigProvider.future);
  final repo = ref.watch(homeConfigRepositoryProvider);
  final res = await repo.getProductsByIds(
    config.content.productsIds.whereType<int>().toList(),
  );
  return res.fold(
    (failure) => throw Exception(failure.message),
    (products) => products,
  );
});
