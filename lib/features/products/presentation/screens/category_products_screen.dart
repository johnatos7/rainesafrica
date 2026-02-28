import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/responsive_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/datasources/product_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';

import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/screens/cart_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_search_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_button.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_badge_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/providers/category_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/color_attribute_indicator.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categorySlug;
  final String categoryName;
  final int? categoryId;

  const CategoryProductsScreen({
    super.key,
    required this.categorySlug,
    required this.categoryName,
    this.categoryId,
  });

  @override
  ConsumerState<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState
    extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  late EasyRefreshController _refreshController;
  final ProductRemoteDataSource _productRemoteDataSource =
      ProductRemoteDataSourceImpl(apiClient: ApiClient());

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _error = '';
  int _currentPage = 1;
  static const int _itemsPerPage = 20;
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isGridView = true; // Toggle between grid and list view

  // Pagination information
  int _lastPage = 1;
  int _total = 0;
  bool _hasMorePages = false;

  // Filter and Sort options
  String _selectedSortOption = 'relevance';
  String? _esField;
  String? _esSortBy;
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  bool _showOnlyInStock = false;
  bool _showOnlyOnSale = false;
  bool _showOnlyFeatured = false;
  bool _showOnlyFreeShipping = false;
  bool _showOnlyCOD = false;
  String _selectedStockStatus = 'all';
  int _minRating = 0;
  int _maxShippingDays = 30;

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;

    try {
      if (!isRefresh) {
        setState(() => _isLoadingMore = true);
      }

      final paginatedProducts = await _productRemoteDataSource
          .getPaginatedProductsByCategorySlug(
            categorySlug: widget.categorySlug,
            page: isRefresh ? 1 : _currentPage,
            limit: _itemsPerPage,
            field: _esField,
            sortBy: _esSortBy,
          );

      setState(() {
        if (isRefresh || _currentPage == 1) {
          _products = paginatedProducts.products;
          _currentPage = 2; // Next page to load
        } else {
          _products = [..._products, ...paginatedProducts.products];
          _currentPage++;
        }

        // Update pagination info
        _lastPage = paginatedProducts.pagination.lastPage;
        _total = paginatedProducts.pagination.total;
        _hasMorePages = paginatedProducts.pagination.hasNextPage;

        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
        _error = '';
        _applyFiltersAndSort();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
        _error = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading products: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          // Search Button
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              size: 24,
            ),
            onPressed: _navigateToSearch,
            tooltip: 'Search Products',
          ),
          // Cart Button with Badge
          Consumer(
            builder: (context, ref, child) {
              final cartCountAsync = ref.watch(cartItemCountProvider);
              final cartCount = cartCountAsync.when(
                data: (count) => count,
                loading: () => 0,
                error: (_, __) => 0,
              );

              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.shopping_cart_rounded,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 24,
                    ),
                    onPressed: _navigateToCart,
                    tooltip: 'Shopping Cart',
                  ),
                  // Cart Badge with actual count
                  if (cartCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : cartCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildActionButtons(),
          _buildFilterIndicator(),
          // _buildSubcategoriesSection(),
          Expanded(
            child: EasyRefresh(
              controller: _refreshController,
              header: const ClassicHeader(),
              footer: const ClassicFooter(),
              onRefresh: () async {
                await _loadProducts(isRefresh: true);
                if (mounted) {
                  _refreshController.finishRefresh();
                  _refreshController.resetFooter();
                }
              },
              onLoad: () async {
                if (_hasMorePages && !_isLoadingMore) {
                  await _loadProducts();
                  if (mounted) {
                    _refreshController.finishLoad(
                      _hasMorePages
                          ? IndicatorResult.success
                          : IndicatorResult.noMore,
                    );
                  }
                } else {
                  if (mounted) {
                    _refreshController.finishLoad(IndicatorResult.noMore);
                  }
                }
              },
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesSection() {
    if (widget.categoryId == null) {
      return const SizedBox.shrink();
    }

    return Consumer(
      builder: (context, ref, child) {
        final subcategoriesAsync = ref.watch(
          subcategoriesProvider(widget.categoryId!),
        );

        return subcategoriesAsync.when(
          data: (subcategories) {
            if (subcategories.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Subcategories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: subcategories.length,
                      itemBuilder: (context, index) {
                        return _buildSubcategoryCard(subcategories[index]);
                      },
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

  Widget _buildSubcategoryCard(CategoryEntity subcategory) {
    final theme = Theme.of(context);

    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () => _navigateToSubcategory(subcategory),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Subcategory Image/Icon
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildSubcategoryImage(subcategory),
              ),
            ),
            const SizedBox(height: 6),
            // Subcategory Name
            Text(
              subcategory.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryImage(CategoryEntity subcategory) {
    final imageUrl =
        subcategory.categoryImage?.imageUrl.isNotEmpty == true
            ? subcategory.categoryImage!.imageUrl
            : (subcategory.categoryIcon?.imageUrl.isNotEmpty == true
                ? subcategory.categoryIcon!.imageUrl
                : null);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => _buildSubcategoryIcon(),
      );
    } else {
      return _buildSubcategoryIcon();
    }
  }

  Widget _buildSubcategoryIcon() {
    return Icon(
      Icons.category_outlined,
      size: 24,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  void _navigateToSubcategory(CategoryEntity subcategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryProductsScreen(
              categorySlug: subcategory.slug ?? '',
              categoryName: subcategory.name ?? '',
              categoryId: subcategory.id,
            ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final itemCount = _filteredProducts.length;
    final totalCount = _total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: colors.outline.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Item count
          Text(
            '$itemCount of $totalCount item${totalCount == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          // Grid/List toggle
          InkWell(
            onTap: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                _isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
                size: 20,
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Sort button
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildSortBottomSheet(colors),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(
                'Sort',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Filter button
          InkWell(
            onTap: _showFilterModal,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (_hasActiveFilters()) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBottomSheet(ColorScheme colors) {
    final sortOptions = [
      {'value': 'relevance', 'label': 'Relevance'},
      {'value': 'rating_desc', 'label': 'Top Rated'},
      {'value': 'price_asc', 'label': 'Price: Low to High'},
      {'value': 'price_desc', 'label': 'Price: High to Low'},
      {'value': 'newest', 'label': 'Newest First'},
      {'value': 'discount_desc', 'label': 'Best Discount'},
      {'value': 'trending', 'label': 'Trending'},
      {'value': 'featured', 'label': 'Featured'},
      {'value': 'name_asc', 'label': 'Name: A–Z'},
      {'value': 'name_desc', 'label': 'Name: Z–A'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children:
                  sortOptions.map((option) {
                    final isSelected = _selectedSortOption == option['value'];
                    return ListTile(
                      title: Text(
                        option['label'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color: colors.primary,
                                size: 20,
                              )
                              : null,
                      onTap: () {
                        Navigator.pop(context);
                        _handleSortSelection(option['value'] as String);
                      },
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    if (_isLoading && _currentPage == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Loading products...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError && _products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadProducts();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no products available in this category at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final crossAxisCount = ResponsiveUtils.gridCrossAxisCount(
            availableWidth,
          );
          final childAspectRatio = ResponsiveUtils.gridChildAspectRatio(
            availableWidth,
          );

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: _filteredProducts[index].toEntity(),
                isGridItem: true,
              );
            },
          );
        },
      );
    } else {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          return _buildProductListItem(_filteredProducts[index].toEntity());
        },
      );
    }
  }

  Widget _buildProductCard(dynamic product) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor, width: .5),
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetails(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.zero),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.productThumbnail.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, _, __) => Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                            ),
                          ),
                    ),
                    // SALE + Discount badges
                    if (product.isOnSale)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (product.discountPercentage > 0) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    // Wishlist Button
                    Positioned(
                      right: 8,
                      top: 8,
                      child: WishlistButton(
                        product: product,
                        iconColor: theme.colorScheme.onSurface.withOpacity(0.7),
                        activeColor: theme.colorScheme.primary,
                        iconSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 2,
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Rating
                      Builder(
                        builder: (context) {
                          final ratings = product.reviewRatings;
                          final totalReviews =
                              ratings.isNotEmpty
                                  ? ratings.fold(0, (sum, count) => sum + count)
                                  : 0;
                          final avgRating =
                              totalReviews > 0
                                  ? ratings.asMap().entries.fold(
                                        0,
                                        (sum, entry) =>
                                            sum +
                                            (entry.value * (entry.key + 1)),
                                      ) /
                                      totalReviews
                                  : 0.0;
                          if (totalReviews == 0) return const SizedBox.shrink();
                          return Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Color(0xFFFFB800),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '($totalReviews)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              product.effectivePrice,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (product.isOnSale)
                            Text(
                              ref.watch(currencyFormattingProvider)(
                                product.price,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      // Colour attribute indicator
                      ColorAttributeIndicator(product: product),
                      // Layby badge
                      LaybyBadgeWidget(
                        productPrice: product.effectivePrice,
                        threshold: AppConstants.laybyEligibilityThreshold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(dynamic product) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Compute rating
    final ratings = product.reviewRatings;
    final totalReviews =
        (ratings != null && ratings.isNotEmpty)
            ? ratings.fold(0, (sum, count) => sum + count)
            : 0;
    final avgRating =
        totalReviews > 0
            ? ratings!.asMap().entries.fold(
                  0,
                  (sum, entry) => sum + (entry.value * (entry.key + 1)),
                ) /
                totalReviews
            : 0.0;

    final imageCount =
        (product.productGalleries?.length ?? 0) +
        (product.productThumbnail != null ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: colors.outline.withOpacity(0.12), width: 1),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetails(context, product),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              SizedBox(
                height: 130,
                width: 130,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        product.productThumbnail?.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, _, __) => Container(
                              color: colors.surfaceVariant,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 32,
                                  color: colors.onSurface.withOpacity(0.3),
                                ),
                              ),
                            ),
                      ),
                    ),
                    // Sale badges
                    if (product.isOnSale)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.discountPercentage > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                ),
                                child: Text(
                                  '${product.discountPercentage.toStringAsFixed(0)}%\nOFF',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    // Image count badge
                    if (imageCount > 1)
                      Positioned(
                        left: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.camera_alt_outlined,
                                size: 12,
                                color: Color(0xFF555555),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$imageCount',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name + Wishlist row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.onSurface,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        WishlistButton(
                          product: product,
                          iconColor: colors.onSurface.withOpacity(0.4),
                          activeColor: colors.primary,
                          iconSize: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            product.effectivePrice,
                          ),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        if (product.isOnSale) ...[
                          const SizedBox(width: 8),
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              product.price,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface.withOpacity(0.45),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Colour attribute indicator
                    ColorAttributeIndicator(product: product),
                    // Shipping / Delivery info
                    if (product.estimatedDeliveryText != null &&
                        product.estimatedDeliveryText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          product.estimatedDeliveryText!,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF66BB6A)
                                    : const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    // Rating
                    if (totalReviews > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 15,
                            color: Color(0xFFFFB800),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '($totalReviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetails(BuildContext context, dynamic product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Widget _buildSortFilter(ColorScheme colors, StateSetter setModalState) {
    final sortOptions = [
      {'value': 'relevance', 'label': 'Relevance', 'icon': Icons.auto_awesome},
      {'value': 'rating_desc', 'label': 'Top Rated', 'icon': Icons.star},
      {
        'value': 'price_asc',
        'label': 'Price: Low to High',
        'icon': Icons.arrow_upward,
      },
      {
        'value': 'price_desc',
        'label': 'Price: High to Low',
        'icon': Icons.arrow_downward,
      },
      {'value': 'newest', 'label': 'Newest First', 'icon': Icons.schedule},
      {
        'value': 'discount_desc',
        'label': 'Best Discount',
        'icon': Icons.local_offer,
      },
      {'value': 'trending', 'label': 'Trending', 'icon': Icons.trending_up},
      {
        'value': 'featured',
        'label': 'Featured',
        'icon': Icons.workspace_premium,
      },
      {'value': 'name_asc', 'label': 'Name: A–Z', 'icon': Icons.sort_by_alpha},
      {'value': 'name_desc', 'label': 'Name: Z–A', 'icon': Icons.sort_by_alpha},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              sortOptions.map((option) {
                final isSelected = _selectedSortOption == option['value'];
                return GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _handleSortSelection(option['value'] as String);
                    });
                    setState(() {});
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? colors.primary
                              : colors.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? colors.primary
                                : colors.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          option['icon'] as IconData,
                          size: 16,
                          color:
                              isSelected
                                  ? colors.onPrimary
                                  : colors.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          option['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected
                                    ? colors.onPrimary
                                    : colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterIndicator() {
    final hasActiveFilters = _hasActiveFilters();

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_filteredProducts.length} of ${_total} products (Page ${_currentPage - 1} of $_lastPage)',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Clear All',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _minPrice > 0 ||
        _maxPrice < double.infinity ||
        _showOnlyInStock ||
        _showOnlyOnSale ||
        _showOnlyFeatured ||
        _showOnlyFreeShipping ||
        _showOnlyCOD ||
        _selectedStockStatus != 'all' ||
        _minRating > 0 ||
        _maxShippingDays < 30;
  }

  void _handleSortSelection(String value) {
    setState(() {
      _selectedSortOption = value;
      switch (value) {
        case 'relevance':
          _esField = null;
          _esSortBy = null;
          break;
        case 'name_asc':
          _esField = 'name';
          _esSortBy = 'asc';
          break;
        case 'name_desc':
          _esField = 'name';
          _esSortBy = 'desc';
          break;
        case 'price_asc':
          _esField = 'price';
          _esSortBy = 'asc';
          break;
        case 'price_desc':
          _esField = 'price';
          _esSortBy = 'desc';
          break;
        case 'discount_desc':
          _esField = 'discount';
          _esSortBy = 'desc';
          break;
        case 'rating_desc':
          _esField = 'rating_count';
          _esSortBy = 'desc';
          break;
        case 'newest':
          _esField = 'created_at';
          _esSortBy = 'desc';
          break;
        case 'oldest':
          _esField = 'created_at';
          _esSortBy = 'asc';
          break;
        case 'featured':
          _esField = 'is_featured';
          _esSortBy = 'desc';
          break;
        case 'trending':
          _esField = 'is_trending';
          _esSortBy = 'desc';
          break;
      }
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<ProductModel> filtered = List.from(_products);

    // Apply filters
    filtered =
        filtered.where((product) {
          // Price filter
          final effectivePrice = product.salePrice ?? product.price ?? 0;
          if (effectivePrice < _minPrice || effectivePrice > _maxPrice) {
            return false;
          }

          // Stock status filter
          if (_showOnlyInStock && product.stockStatus != 'in_stock') {
            return false;
          }

          if (_selectedStockStatus != 'all' &&
              product.stockStatus != _selectedStockStatus) {
            return false;
          }

          // Sale filter
          if (_showOnlyOnSale &&
              (product.isSaleEnable != 1 || product.salePrice == null)) {
            return false;
          }

          // Featured filter
          if (_showOnlyFeatured && product.isFeatured != 1) {
            return false;
          }

          // Free shipping filter
          if (_showOnlyFreeShipping && product.isFreeShipping != 1) {
            return false;
          }

          // COD filter
          if (_showOnlyCOD && product.isCod != 1) {
            return false;
          }

          // Shipping days filter
          if (product.shippingDays != null &&
              product.shippingDays! > _maxShippingDays) {
            return false;
          }

          // Rating filter (if available)
          if (_minRating > 0 && (product.ratingCount ?? 0) < _minRating) {
            return false;
          }

          return true;
        }).toList();

    // Apply client-side sorting
    if (_selectedSortOption != 'relevance') {
      filtered.sort((a, b) {
        int comparison = 0;
        switch (_selectedSortOption) {
          case 'name_asc':
            comparison = (a.name ?? '').compareTo(b.name ?? '');
            break;
          case 'name_desc':
            comparison = (b.name ?? '').compareTo(a.name ?? '');
            break;
          case 'price_asc':
            final priceA = a.salePrice ?? a.price ?? 0;
            final priceB = b.salePrice ?? b.price ?? 0;
            comparison = priceA.compareTo(priceB);
            break;
          case 'price_desc':
            final priceA = a.salePrice ?? a.price ?? 0;
            final priceB = b.salePrice ?? b.price ?? 0;
            comparison = priceB.compareTo(priceA);
            break;
          case 'discount_desc':
            final discountA = a.discount ?? 0;
            final discountB = b.discount ?? 0;
            comparison = discountB.compareTo(discountA);
            break;
          case 'rating_desc':
            final ratingA = a.ratingCount ?? 0;
            final ratingB = b.ratingCount ?? 0;
            comparison = ratingB.compareTo(ratingA);
            break;
          case 'newest':
            final dateA = a.createdAt ?? DateTime(1970);
            final dateB = b.createdAt ?? DateTime(1970);
            comparison = dateB.compareTo(dateA);
            break;
          case 'oldest':
            final dateA = a.createdAt ?? DateTime(1970);
            final dateB = b.createdAt ?? DateTime(1970);
            comparison = dateA.compareTo(dateB);
            break;
          case 'featured':
            final featuredA = a.isFeatured ?? 0;
            final featuredB = b.isFeatured ?? 0;
            comparison = featuredB.compareTo(featuredA);
            break;
          case 'trending':
            final trendingA = a.isTrending ?? 0;
            final trendingB = b.isTrending ?? 0;
            comparison = trendingB.compareTo(trendingA);
            break;
        }
        return comparison;
      });
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) =>
                    _buildFilterModal(scrollController),
          ),
    );
  }

  Widget _buildFilterModal(ScrollController scrollController) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _resetFilters();
                        });
                        setState(() {
                          _resetFilters();
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Filter content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSortFilter(colors, setModalState),
                      const SizedBox(height: 24),
                      _buildPriceFilter(colors, setModalState),
                      const SizedBox(height: 24),
                      _buildStockFilter(colors, setModalState),
                      const SizedBox(height: 24),
                      _buildFeatureFilters(colors, setModalState),
                      const SizedBox(height: 24),
                      _buildShippingFilter(colors, setModalState),
                      const SizedBox(height: 24),
                      _buildRatingFilter(colors, setModalState),
                      const SizedBox(height: 100), // Space for apply button
                    ],
                  ),
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFiltersAndSort();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriceFilter(ColorScheme colors, StateSetter setModalState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _minPrice == 0 ? '' : _minPrice.toString(),
                decoration: const InputDecoration(
                  labelText: 'Min Price',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minPrice = double.tryParse(value) ?? 0;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue:
                    _maxPrice == double.infinity ? '' : _maxPrice.toString(),
                decoration: const InputDecoration(
                  labelText: 'Max Price',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxPrice = double.tryParse(value) ?? double.infinity;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockFilter(ColorScheme colors, StateSetter setModalState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('In Stock Only'),
          value: _showOnlyInStock,
          onChanged: (value) {
            setState(() {
              _showOnlyInStock = value ?? false;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        DropdownButtonFormField<String>(
          value: _selectedStockStatus,
          decoration: const InputDecoration(
            labelText: 'Stock Status',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'in_stock', child: Text('In Stock')),
            DropdownMenuItem(
              value: 'out_of_stock',
              child: Text('Out of Stock'),
            ),
            DropdownMenuItem(value: 'pre_order', child: Text('Pre Order')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStockStatus = value ?? 'all';
            });
          },
        ),
      ],
    );
  }

  Widget _buildFeatureFilters(ColorScheme colors, StateSetter setModalState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: const Text('On Sale'),
          value: _showOnlyOnSale,
          onChanged: (value) {
            setState(() {
              _showOnlyOnSale = value ?? false;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        CheckboxListTile(
          title: const Text('Featured Products'),
          value: _showOnlyFeatured,
          onChanged: (value) {
            setState(() {
              _showOnlyFeatured = value ?? false;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        CheckboxListTile(
          title: const Text('Free Shipping'),
          value: _showOnlyFreeShipping,
          onChanged: (value) {
            setState(() {
              _showOnlyFreeShipping = value ?? false;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        CheckboxListTile(
          title: const Text('Office Payment'),
          value: _showOnlyCOD,
          onChanged: (value) {
            setState(() {
              _showOnlyCOD = value ?? false;
            });
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildShippingFilter(ColorScheme colors, StateSetter setModalState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _maxShippingDays.toString(),
          decoration: const InputDecoration(
            labelText: 'Max Shipping Days',
            suffixText: 'days',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _maxShippingDays = int.tryParse(value) ?? 30;
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter(ColorScheme colors, StateSetter setModalState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _minRating.toString(),
          decoration: const InputDecoration(
            labelText: 'Minimum Rating',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _minRating = int.tryParse(value) ?? 0;
          },
        ),
      ],
    );
  }

  void _resetFilters() {
    _minPrice = 0;
    _maxPrice = double.infinity;
    _showOnlyInStock = false;
    _showOnlyOnSale = false;
    _showOnlyFeatured = false;
    _showOnlyFreeShipping = false;
    _showOnlyCOD = false;
    _selectedStockStatus = 'all';
    _minRating = 0;
    _maxShippingDays = 30;
    _applyFiltersAndSort();
  }

  void _navigateToSearch() {
    // Navigate to search screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => ProductSearchScreen()));
  }

  void _navigateToCart() {
    // Navigate to cart screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CartScreen()));
  }
}
