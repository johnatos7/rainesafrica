import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/responsive_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/home_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/home_config_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/recently_viewed_provider.dart';

import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/providers/category_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/widgets/section_title.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_search_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/cart_icon_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/category_products_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/section_products_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/widgets/home_skeleton_widgets.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_icon_widget.dart';

import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final sectionInfoAsync = ref.watch(sectionInfoProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context, colors),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(homeConfigProvider);
                  ref.invalidate(sectionInfoProvider);
                  ref.invalidate(featuredBannersProvider);
                  ref.invalidate(section1ProductsProvider);
                  ref.invalidate(section4ProductsProvider);
                  ref.invalidate(section7ProductsProvider);
                  ref.invalidate(homeAppliancesProductsProvider);
                  ref.invalidate(topPicksProductsProvider);
                  ref.invalidate(featuredCategoriesProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 88),
                  child: sectionInfoAsync.when(
                    data: (info) => _buildContent(context, colors, info),
                    loading: () => _buildLoadingContent(colors),
                    error: (e, _) => _buildContent(context, colors, {}),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ColorScheme colors,
    Map<String, SectionInfo> info,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // 1. Categories
        if (info['categories']?.status ?? true)
          _buildFeaturedCategoriesSection(
            context,
            ref,
            colors,
            info['categories']?.title ?? 'Browse By Categories',
          ),

        // 2. Pick Up Where You Left Off
        _buildRecentlyViewedSection(context, ref, colors),

        const SizedBox(height: 8),

        // 2. Featured banners carousel
        _buildBannerCarouselSection(context, colors),

        _buildSectionGap(),

        // 3. Section 1 products
        if (info['section1']?.status ?? true)
          _buildSectionFromProvider(
            context: context,
            ref: ref,
            title: info['section1']?.title ?? 'Trending Products',
            provider: section1ProductsProvider,
            colors: colors,
            onViewAll:
                (products) => _navigateToSection(
                  context,
                  info['section1']?.title ?? 'Trending Products',
                  products,
                ),
          ),

        // Interspersed banner (index 0) — replaces dead section3 two-column banners
        _buildInterspersedBanner(0, colors),

        _buildSectionGap(),

        // 5. Section 4 products
        if (info['section4']?.status ?? true)
          _buildSectionFromProvider(
            context: context,
            ref: ref,
            title: info['section4']?.title ?? 'Featured Products',
            provider: section4ProductsProvider,
            colors: colors,
            onViewAll:
                (products) => _navigateToSection(
                  context,
                  info['section4']?.title ?? 'Featured Products',
                  products,
                ),
          ),

        // Interspersed banner (index 1)
        _buildInterspersedBanner(1, colors),

        _buildSectionGap(),

        // 7. Home Appliances
        if (info['home_appliances']?.status ?? true)
          _buildSectionFromProvider(
            context: context,
            ref: ref,
            title: info['home_appliances']?.title ?? 'Home Appliances',
            provider: homeAppliancesProductsProvider,
            colors: colors,
            onViewAll:
                (products) => _navigateToSection(
                  context,
                  info['home_appliances']?.title ?? 'Home Appliances',
                  products,
                ),
          ),

        // Interspersed banner (index 2)
        _buildInterspersedBanner(2, colors),

        _buildSectionGap(),

        // 9. Section 7 products
        if (info['section7']?.status ?? true)
          _buildSectionFromProvider(
            context: context,
            ref: ref,
            title: info['section7']?.title ?? 'Best Sellers',
            provider: section7ProductsProvider,
            colors: colors,
            onViewAll:
                (products) => _navigateToSection(
                  context,
                  info['section7']?.title ?? 'Best Sellers',
                  products,
                ),
          ),

        // Interspersed banner (index 3)
        _buildInterspersedBanner(3, colors),

        _buildSectionGap(),

        // 11. Top Picks
        _buildSectionFromProvider(
          context: context,
          ref: ref,
          title: 'Top Picks For You',
          provider: topPicksProductsProvider,
          colors: colors,
          onViewAll:
              (products) =>
                  _navigateToSection(context, 'Top Picks For You', products),
        ),
      ],
    );
  }

  Widget _buildLoadingContent(ColorScheme colors) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const CategorySkeleton(),
        const SizedBox(height: 8),
        const BannerSkeleton(),
        const SizedBox(height: 8),
        ProductSectionSkeleton(title: 'Loading...'),
        const SizedBox(height: 8),
        ProductSectionSkeleton(title: 'Loading...'),
      ],
    );
  }

  Widget _buildSectionGap() {
    return const SizedBox(height: 8);
  }

  // --- Pick Up Where You Left Off (Takealot-style) ---

  Widget _buildRecentlyViewedSection(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
  ) {
    final recentItems = ref.watch(recentlyViewedProvider);
    if (recentItems.isEmpty) return const SizedBox.shrink();

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and Clear All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pick Up Where You Left Off',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(recentlyViewedProvider.notifier).clearAll();
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal product list
          SizedBox(
            height: ResponsiveUtils.productSectionHeight(context),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentItems.length,
              itemBuilder: (context, index) {
                final item = recentItems[index];
                // Convert RecentlyViewedItem to ProductEntity for ProductCard
                final product = ProductEntity(
                  id: item.productId,
                  name: item.name,
                  slug: item.slug,
                  price: item.price,
                  productGalleries: [],
                  salePrice: item.salePrice,
                  discount: item.discount,
                  reviewRatings: item.reviewRatings,
                  estimatedDeliveryText: item.estimatedDeliveryText,
                  isSaleEnable: item.isSaleEnable,
                  productThumbnail: ProductImageEntity(
                    id: 0,
                    imageUrl: item.imageUrl,
                  ),
                );
                return ProductCard(
                  product: product,
                  overrideColourSlugs: item.colourSlugs,
                  overrideHasMoreOptions: item.hasMoreOptions,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Banner Carousel ---

  Widget _buildBannerCarouselSection(BuildContext context, ColorScheme colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Consumer(
        builder: (context, ref, _) {
          final bannersAsync = ref.watch(featuredBannersProvider);
          return bannersAsync.when(
            data: (banners) {
              final images = banners.map((b) => b.imageUrl).toList();
              if (images.isEmpty) return const SizedBox.shrink();
              return _BannerCarouselWithIndicator(
                images: images,
                colors: colors,
              );
            },
            loading: () => const BannerSkeleton(),
            error: (e, _) => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  /// Shows a single home banner at [bannerIndex] from home_banner API data
  Widget _buildInterspersedBanner(int bannerIndex, ColorScheme colors) {
    return Consumer(
      builder: (context, ref, _) {
        final bannersAsync = ref.watch(homeBannerImagesProvider);
        return bannersAsync.when(
          data: (imageUrls) {
            if (bannerIndex >= imageUrls.length) return const SizedBox.shrink();
            final imageUrl = imageUrls[bannerIndex];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: ResponsiveUtils.interspersedBannerHeight(context),
                fit: BoxFit.cover,
                placeholder:
                    (_, __) => Container(
                      height: ResponsiveUtils.interspersedBannerHeight(context),
                      color: colors.surfaceContainerHighest,
                    ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  // --- Two-Column Banners ---

  Widget _buildTwoColumnBanners(
    FutureProvider<TwoColumnBanners?> provider,
    ColorScheme colors,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final async = ref.watch(provider);
        return async.when(
          data: (banners) {
            if (banners == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildBannerImage(
                      banners.banner1.imageUrl,
                      colors,
                      height: 120,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBannerImage(
                      banners.banner2.imageUrl,
                      colors,
                      height: 120,
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  // --- Full-Width Banner ---

  Widget _buildFullWidthBanner(
    FutureProvider<SectionBanner?> provider,
    ColorScheme colors,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final async = ref.watch(provider);
        return async.when(
          data: (banner) {
            if (banner == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildBannerImage(banner.imageUrl, colors, height: 180),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildBannerImage(
    String imageUrl,
    ColorScheme colors, {
    double height = 120,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder:
            (_, __) => Container(
              height: height,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        errorWidget: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  // --- Sticky Header ---

  Widget _buildStickyHeader(BuildContext context, ColorScheme colors) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                theme.brightness == Brightness.dark
                    ? 'assets/images/logo_dark.png'
                    : 'assets/images/logo_light.png',
                width: 120,
                height: 36,
                fit: BoxFit.contain,
              ),
              Row(
                children: [
                  const ThemeToggleButton(),
                  CartIconWidget(
                    iconColor: colors.onSurface,
                    badgeColor: colors.primary,
                    iconSize: 28,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  NotificationIconWidget(
                    iconColor: colors.onSurface.withValues(alpha: 0.6),
                    badgeColor: colors.primary,
                    iconSize: 28,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductSearchScreen()),
              );
            },
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.search,
                    color: colors.onSurface.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search products, brands...',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Featured Categories ---

  Widget _buildFeaturedCategoriesSection(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
    String title,
  ) {
    final featuredCategoriesAsync = ref.watch(featuredCategoriesProvider);

    return Container(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, showViewAll: false),
          const SizedBox(height: 12),
          SizedBox(
            height: ResponsiveUtils.categorySectionHeight(context),
            child: featuredCategoriesAsync.when(
              data:
                  (categories) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCardFromEntity(category, colors);
                    },
                  ),
              loading: () => const CategorySkeleton(),
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Failed to load categories',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCardFromEntity(
    CategoryEntity category,
    ColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CategoryProductsScreen(
                  categorySlug: category.slug ?? '',
                  categoryName: category.name ?? '',
                  categoryId: category.id,
                ),
          ),
        );
      },
      child: Container(
        width: ResponsiveUtils.categoryCardWidth(context),
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: ResponsiveUtils.categoryCirlceSize(context),
              height: ResponsiveUtils.categoryCirlceSize(context),
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child:
                  category.categoryImage != null
                      ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: category.categoryImage!.imageUrl,
                          width: ResponsiveUtils.categoryCirlceSize(context),
                          height: ResponsiveUtils.categoryCirlceSize(context),
                          fit: BoxFit.cover,
                          placeholder:
                              (_, __) =>
                                  Container(color: colors.surfaceContainerLow),
                          errorWidget:
                              (_, __, ___) => Icon(
                                Icons.category,
                                size: 40,
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      )
                      : Center(
                        child: Icon(
                          Icons.category,
                          size: 40,
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name ?? '',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // --- Product Sections ---

  void _navigateToSection(
    BuildContext context,
    String title,
    List<ProductEntity> products,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SectionProductsScreen(title: title, products: products),
      ),
    );
  }

  Widget _buildSectionFromProvider({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required FutureProvider<List<dynamic>> provider,
    required ColorScheme colors,
    void Function(List<ProductEntity>)? onViewAll,
  }) {
    final async = ref.watch(provider);
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: title,
            showViewAll: onViewAll != null,
            onViewAll:
                onViewAll != null
                    ? () {
                      final products = async.valueOrNull;
                      if (products != null && products.isNotEmpty) {
                        onViewAll(products.cast<ProductEntity>());
                      }
                    }
                    : null,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: ResponsiveUtils.productSectionHeight(context),
            child: async.when(
              data: (products) {
                if (products.isEmpty) return const SizedBox.shrink();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                );
              },
              loading: () => ProductSectionSkeleton(title: title),
              error:
                  (error, stack) => Center(
                    child: Text(
                      'Failed to load $title',
                      style: TextStyle(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Banner Carousel Widget ---

class _BannerCarouselWithIndicator extends StatefulWidget {
  final List<String> images;
  final ColorScheme colors;

  const _BannerCarouselWithIndicator({
    required this.images,
    required this.colors,
  });

  @override
  State<_BannerCarouselWithIndicator> createState() =>
      _BannerCarouselWithIndicatorState();
}

class _BannerCarouselWithIndicatorState
    extends State<_BannerCarouselWithIndicator> {
  int currentIndex = 0;
  late CarouselSliderController carouselController;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselSliderController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final bHeight = ResponsiveUtils.bannerHeight(context);
            return SizedBox(
              height: bHeight,
              width: double.infinity,
              child: CarouselSlider(
                carouselController: carouselController,
                options: CarouselOptions(
                  height: bHeight,
                  viewportFraction: 0.92,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.15,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                items:
                    widget.images.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => Container(
                                    color: widget.colors.surfaceContainerLow,
                                  ),
                              errorWidget:
                                  (_, __, ___) => Container(
                                    color: widget.colors.surfaceContainerLow,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: widget.colors.onSurface.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                            ),
                          );
                        },
                      );
                    }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              widget.images.asMap().entries.map((entry) {
                final isActive = currentIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        isActive
                            ? widget.colors.primary
                            : widget.colors.outline.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
