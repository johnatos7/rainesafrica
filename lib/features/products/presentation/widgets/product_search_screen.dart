import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/providers/product_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_from_search_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/custom_barcode_scanner.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_badge_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  String _query = '';
  List<String> _recentSearches = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  static const String _recentSearchesKey = 'recent_searches';
  bool _isSearching = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _itemsPerPage = 20;
  bool _hasMorePages = false;
  bool _isGridView = true; // Default to grid view

  // EasyRefresh controllers
  final ScrollController _scrollController = ScrollController();
  late EasyRefreshController _refreshController;

  // Search results and filtering
  List<ProductModel> _searchResults = [];
  List<ProductModel> _filteredResults = [];

  // Filter and Sort options
  String _sortBy = 'name';
  bool _sortAscending = true;
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

  // Elasticsearch server-side sort params
  String? _esField;
  String? _esSortBy;

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_recentSearchesKey) ?? [];
    setState(() {
      _recentSearches = searches;

      // Add some sample searches if none exist (for demo purposes)
      if (_recentSearches.isEmpty) {
        _recentSearches = [
          'smartphone',
          'laptop',
          'headphones',
          'fitness tracker',
          'wireless charger',
        ];
        _saveRecentSearches();
      }
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
  }

  void _onSearchSubmitted(String value) {
    final searchText = value.trim();
    print('Search Screen: Submit search for query: "$searchText"');
    setState(() {
      _query = searchText;
    });
    if (searchText.isNotEmpty) {
      _performSearch(searchText);
    } else {
      _searchResults.clear();
      _filteredResults.clear();
      _isSearching = false;
    }
  }

  /// Build ES price param from min/max price state
  String? _buildEsPriceParam() {
    if (_minPrice > 0 || _maxPrice < double.infinity) {
      final min = _minPrice > 0 ? _minPrice.toInt() : 0;
      final max = _maxPrice < double.infinity ? _maxPrice.toInt() : 1000000;
      return '$min-$max';
    }
    return null;
  }

  Future<void> _performSearch(
    String query, {
    String? sku,
    bool isRefresh = false,
  }) async {
    try {
      setState(() {
        _isSearching = true;
      });
      print('Performing search for query: "$query" (isRefresh: $isRefresh)');

      // Only clear results if it's a new search, not a refresh
      if (!isRefresh) {
        setState(() {
          _searchResults = [];
          _filteredResults = [];
          _currentPage = 1;
          _hasMorePages = false;
          _isLoadingMore = false;
        });
      }

      // Save to recent searches only for new searches
      if (!isRefresh) {
        _addToRecentSearches(query);
      }

      // Call the repository with all ES filters
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.searchProducts(
        query: query,
        sku: sku,
        page: 1,
        limit: _itemsPerPage,
        price: _buildEsPriceParam(),
        rating: _minRating > 0 ? _minRating : null,
        field: _esField,
        sortBy: _esSortBy,
      );

      result.fold(
        (failure) {
          print('Search failed: ${failure.message}');
          setState(() {
            _searchResults = [];
            _filteredResults = [];
            _hasMorePages = false;
          });
        },
        (products) {
          print(
            'Search Screen: Received ${products.length} products from repository',
          );

          setState(() {
            _searchResults =
                products
                    .map((entity) => ProductModel.fromEntity(entity))
                    .toList();
            _currentPage = 2;
            _hasMorePages = products.length >= _itemsPerPage;
            _applyFiltersAndSort();
          });
        },
      );
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _filteredResults = [];
        _hasMorePages = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadMoreSearch() async {
    if (_isLoadingMore || !_hasMorePages || _query.trim().isEmpty) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.searchProducts(
        query: _query,
        page: _currentPage,
        limit: _itemsPerPage,
        price: _buildEsPriceParam(),
        rating: _minRating > 0 ? _minRating : null,
        field: _esField,
        sortBy: _esSortBy,
      );
      result.fold(
        (failure) {
          print('Load more failed: ${failure.message}');
        },
        (products) {
          setState(() {
            final next =
                products
                    .map((entity) => ProductModel.fromEntity(entity))
                    .toList();
            _searchResults = [..._searchResults, ...next];
            _currentPage++;
            _hasMorePages = next.length >= _itemsPerPage;
            _applyFiltersAndSort();
          });
        },
      );
    } catch (e) {
      print('Error loading more search results: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  /// Navigate to barcode scanner and handle the result
  Future<void> _navigateToBarcodeScanner() async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => CustomBarcodeScanner(
                onDispose: () {
                  print(
                    'Search Screen: Barcode scanner disposed - camera resources released',
                  );
                },
              ),
        ),
      );

      // Handle the scanned barcode result
      if (result != null && result is String) {
        print('Search Screen: Received barcode result: $result');
        setState(() {
          _searchController.text = result;
          _query = result;
        });
        _performSearch(result, sku: result);
      }
    } catch (e) {
      print('Barcode scanner error: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Camera access denied or unavailable'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;

    // Remove if already exists to avoid duplicates
    _recentSearches.remove(query);

    // Add to beginning of list
    _recentSearches.insert(0, query);

    // Keep only last 10 searches
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.take(10).toList();
    }

    // Save to preferences
    _saveRecentSearches();
  }

  void _navigateToProductDetails(BuildContext context, ProductEntity product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsFromSearchScreen(product: product),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Apply client-side-only filters (stock, sale, featured, shipping, COD).
  /// Price and rating are now handled server-side by Elasticsearch.
  void _applyFiltersAndSort() {
    print(
      'Search Screen: Applying client-side filters to ${_searchResults.length} results',
    );
    List<ProductModel> filtered = List.from(_searchResults);

    // Client-side filters (not available as ES query params)
    filtered =
        filtered.where((product) {
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

          return true;
        }).toList();

    // Sorting is now handled server-side via field + sortBy params.
    // No client-side sort needed when server sort is active.

    print('Search Screen: Filtered results: ${filtered.length} products');
    setState(() {
      _filteredResults = filtered;
    });
  }

  void _handleSortSelection(String value) {
    setState(() {
      switch (value) {
        case 'name_asc':
          _sortBy = 'name';
          _sortAscending = true;
          _esField = 'name';
          _esSortBy = 'asc';
          break;
        case 'name_desc':
          _sortBy = 'name';
          _sortAscending = false;
          _esField = 'name';
          _esSortBy = 'desc';
          break;
        case 'price_asc':
          _sortBy = 'price';
          _sortAscending = true;
          _esField = 'price';
          _esSortBy = 'asc';
          break;
        case 'price_desc':
          _sortBy = 'price';
          _sortAscending = false;
          _esField = 'price';
          _esSortBy = 'desc';
          break;
        case 'discount_desc':
          _sortBy = 'discount';
          _sortAscending = false;
          _esField = 'discount';
          _esSortBy = 'desc';
          break;
        case 'rating_desc':
          _sortBy = 'rating';
          _sortAscending = false;
          _esField = 'rating_count';
          _esSortBy = 'desc';
          break;
        case 'newest':
          _sortBy = 'createdAt';
          _sortAscending = false;
          _esField = 'created_at';
          _esSortBy = 'desc';
          break;
        case 'oldest':
          _sortBy = 'createdAt';
          _sortAscending = true;
          _esField = 'created_at';
          _esSortBy = 'asc';
          break;
        case 'featured':
          _sortBy = 'featured';
          _sortAscending = false;
          _esField = 'is_featured';
          _esSortBy = 'desc';
          break;
        case 'trending':
          _sortBy = 'trending';
          _sortAscending = false;
          _esField = 'is_trending';
          _esSortBy = 'desc';
          break;
      }
    });
    // Re-trigger server search with new sort params
    if (_query.trim().isNotEmpty) {
      _performSearch(_query, isRefresh: true);
    }
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

  void _resetFilters() {
    setState(() {
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
      _esField = null;
      _esSortBy = null;
    });
    // Re-fetch from server without filters
    if (_query.trim().isNotEmpty) {
      _performSearch(_query, isRefresh: true);
    }
  }

  Widget _buildSearchSuggestion(String text, {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colors.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _loadRecentSearches();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    setState(() {
      // This will trigger a rebuild to show/hide the clear button
    });
  }

  // Enhanced image widget with better error handling and URL validation
  Widget _buildProductImage(String imageUrl, {double? width, double? height}) {
    // Validate image URL before attempting to load
    if (imageUrl.isEmpty || !AppUtils.isValidUrl(imageUrl)) {
      print('Invalid or empty image URL: "$imageUrl"');
      return _buildPlaceholderImage(width: width, height: height);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder:
          (context, url) =>
              _buildLoadingPlaceholder(width: width, height: height),
      errorWidget: (context, url, error) {
        print('Image load error: $error for URL: $url');
        return _buildErrorPlaceholder(width: width, height: height);
      },
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeIn,
      // Add cache configuration for better performance
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      maxWidthDiskCache: width?.toInt(),
      maxHeightDiskCache: height?.toInt(),
    );
  }

  // Helper method to build loading placeholder
  Widget _buildLoadingPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  // Helper method to build error placeholder
  Widget _buildErrorPlaceholder({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: width != null ? width * 0.2 : 32,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 4),
            Text(
              'Image unavailable',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build placeholder for invalid URLs
  Widget _buildPlaceholderImage({double? width, double? height}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: width != null ? width * 0.2 : 32,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              'No image',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced method to build product image with fallback to gallery images
  Widget _buildProductImageWithFallback(
    ProductEntity product, {
    double? width,
    double? height,
  }) {
    // Try thumbnail first
    if ((product.productThumbnail?.imageUrl.isNotEmpty ?? false) &&
        (product.productThumbnail != null
            ? AppUtils.isValidUrl(product.productThumbnail!.imageUrl)
            : false)) {
      return _buildProductImage(
        product.productThumbnail!.imageUrl,
        width: width,
        height: height,
      );
    }

    // Try gallery images as fallback
    for (final galleryImage in product.productGalleries) {
      if (galleryImage.imageUrl.isNotEmpty &&
          AppUtils.isValidUrl(galleryImage.imageUrl)) {
        print('Using gallery image as fallback for product: ${product.name}');
        return _buildProductImage(
          galleryImage.imageUrl,
          width: width,
          height: height,
        );
      }
    }

    // If no valid images found, show placeholder
    print('No valid images found for product: ${product.name}');
    return _buildPlaceholderImage(width: width, height: height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final showResults = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Search products, brands...',
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: colors.onSurface.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              prefixIcon: Icon(
                Icons.search,
                color: colors.onSurface.withOpacity(0.6),
                size: 20,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward,
                              color: colors.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                            onPressed: () {
                              _onSearchSubmitted(_searchController.text);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: colors.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _query = '';
                                _searchResults.clear();
                                _filteredResults.clear();
                                _isSearching = false;
                              });
                            },
                          ),
                        ],
                      )
                      : null,
            ),
            style: TextStyle(
              fontSize: 16,
              color: colors.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (showResults) ...[
            _buildActionButtons(colors),
            _buildFilterIndicator(colors),
          ],
          Expanded(
            child:
                showResults
                    ? _buildSearchResults(colors)
                    : _buildSearchSuggestions(colors),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBarcodeScanner,
        tooltip: 'Scan Barcode',
        child: Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Filter Button
          Expanded(
            child: TextButton.icon(
              onPressed: _showFilterModal,
              icon: Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: colors.primary,
              ),
              label: Text(
                'Filter',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: colors.primary.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // View Toggle Button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              size: 18,
              color: colors.primary,
            ),
            label: Text(
              _isGridView ? 'List' : 'Grid',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: colors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort Button
          Expanded(
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleSortSelection(value),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sort_rounded, size: 18, color: colors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Sort',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'name_asc',
                      child: Text('Name A-Z'),
                    ),
                    const PopupMenuItem(
                      value: 'name_desc',
                      child: Text('Name Z-A'),
                    ),
                    const PopupMenuItem(
                      value: 'price_asc',
                      child: Text('Price Low to High'),
                    ),
                    const PopupMenuItem(
                      value: 'price_desc',
                      child: Text('Price High to Low'),
                    ),
                    const PopupMenuItem(
                      value: 'discount_desc',
                      child: Text('Best Discount'),
                    ),
                    const PopupMenuItem(
                      value: 'rating_desc',
                      child: Text('Highest Rated'),
                    ),
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Newest First'),
                    ),
                    const PopupMenuItem(
                      value: 'oldest',
                      child: Text('Oldest First'),
                    ),
                    const PopupMenuItem(
                      value: 'featured',
                      child: Text('Featured'),
                    ),
                    const PopupMenuItem(
                      value: 'trending',
                      child: Text('Trending'),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIndicator(ColorScheme colors) {
    final hasActiveFilters = _hasActiveFilters();

    if (!hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: colors.primary.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filters applied',
              style: TextStyle(
                fontSize: 12,
                color: colors.primary,
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
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor, width: .5),
        borderRadius: BorderRadius.zero,
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
                    // Use the enhanced image widget with fallback
                    _buildProductImageWithFallback(product),
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
                            (ratings != null && ratings.isNotEmpty)
                                ? ratings.fold(0, (sum, count) => sum + count)
                                : 0;
                        final avgRating =
                            totalReviews > 0
                                ? ratings!.asMap().entries.fold(
                                      0,
                                      (sum, entry) =>
                                          sum + (entry.value * (entry.key + 1)),
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
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
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
                    // Layby badge
                    LaybyBadgeWidget(
                      productPrice: product.effectivePrice,
                      threshold: AppConstants.laybyEligibilityThreshold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductListItem(ProductEntity product) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Theme.of(context).dividerColor, width: .5),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToProductDetails(context, product),
        borderRadius: BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Use the enhanced image widget with fallback
                      _buildProductImageWithFallback(
                        product,
                        width: 100,
                        height: 100,
                      ),
                      // SALE + Discount badges
                      if (product.isOnSale)
                        Positioned(
                          left: 4,
                          top: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SALE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (product.discountPercentage > 0) ...[
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
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
                        right: 4,
                        top: 4,
                        child: WishlistButton(
                          product: product,
                          iconColor: theme.colorScheme.onSurface.withOpacity(
                            0.7,
                          ),
                          activeColor: theme.colorScheme.primary,
                          iconSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Rating
                    Builder(
                      builder: (context) {
                        final ratings = product.reviewRatings;
                        final totalReviews =
                            (ratings != null && ratings.isNotEmpty)
                                ? ratings.fold(0, (sum, count) => sum + count)
                                : 0;
                        final avgRating =
                            totalReviews > 0
                                ? ratings!.asMap().entries.fold(
                                      0,
                                      (sum, entry) =>
                                          sum + (entry.value * (entry.key + 1)),
                                    ) /
                                    totalReviews
                                : 0.0;
                        if (totalReviews == 0) return const SizedBox.shrink();
                        return Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Color(0xFFFFB800),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              avgRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '($totalReviews)',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            product.effectivePrice,
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product.isOnSale)
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              product.price,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    // Layby badge
                    LaybyBadgeWidget(
                      productPrice: product.effectivePrice,
                      threshold: AppConstants.laybyEligibilityThreshold,
                    ),
                    const SizedBox(height: 8),
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showQuickAddToCart(context, product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  void _showQuickAddToCart(BuildContext context, dynamic product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(product.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add "${product.name}" to cart?'),
                const SizedBox(height: 16),
                AddToCartButton(
                  product: product,
                  quantity: 1,
                  onAdded: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Widget _buildSearchResults(ColorScheme colors) {
    // Show loading indicator only while actively searching
    if (_isSearching) {
      print('Search Screen: Showing loading indicator');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Searching for "${_query}"...',
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredResults.isEmpty) {
      print('Search Screen: Showing no results message');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colors.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: colors.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    print(
      'Search Screen: Showing list view with ${_filteredResults.length} items',
    );
    return EasyRefresh(
      controller: _refreshController,
      footer: const ClassicFooter(),
      onLoad: () async {
        if (_hasMorePages && !_isLoadingMore) {
          await _loadMoreSearch();
          if (mounted) {
            _refreshController.finishLoad(
              _hasMorePages ? IndicatorResult.success : IndicatorResult.noMore,
            );
          }
        } else {
          if (mounted) {
            _refreshController.finishLoad(IndicatorResult.noMore);
          }
        }
      },
      child:
          _isGridView
              ? GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _filteredResults.length,
                itemBuilder: (context, index) {
                  final product = _filteredResults[index];
                  return _buildProductCard(product.toEntity());
                },
              )
              : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                itemCount: _filteredResults.length,
                itemBuilder: (context, index) {
                  final product = _filteredResults[index];
                  return _buildProductListItem(product.toEntity());
                },
              ),
    );
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
                      Navigator.pop(context);
                      // Re-fetch from server with updated filters
                      if (_query.trim().isNotEmpty) {
                        _performSearch(_query, isRefresh: true);
                      } else {
                        _applyFiltersAndSort();
                      }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _minPrice == 0 ? '' : _minPrice.toString(),
                decoration: InputDecoration(
                  labelText: 'Min Price',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  labelStyle: TextStyle(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setModalState(() {
                    _minPrice = double.tryParse(value) ?? 0;
                  });
                },
                style: TextStyle(color: colors.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue:
                    _maxPrice == double.infinity ? '' : _maxPrice.toString(),
                decoration: InputDecoration(
                  labelText: 'Max Price',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  labelStyle: TextStyle(
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setModalState(() {
                    _maxPrice = double.tryParse(value) ?? double.infinity;
                  });
                },
                style: TextStyle(color: colors.onSurface),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockFilter(ColorScheme colors, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Availability',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text(
            'In Stock Only',
            style: TextStyle(color: colors.onSurface),
          ),
          value: _showOnlyInStock,
          onChanged: (value) {
            setModalState(() {
              _showOnlyInStock = value ?? false;
            });
          },
          activeColor: colors.primary,
        ),
        DropdownButtonFormField<String>(
          value: _selectedStockStatus,
          decoration: InputDecoration(
            labelText: 'Stock Status',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
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
            setModalState(() {
              _selectedStockStatus = value ?? 'all';
            });
          },
        ),
      ],
    );
  }

  Widget _buildFeatureFilters(ColorScheme colors, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text('On Sale', style: TextStyle(color: colors.onSurface)),
          value: _showOnlyOnSale,
          onChanged: (value) {
            setModalState(() {
              _showOnlyOnSale = value ?? false;
            });
          },
          activeColor: colors.primary,
        ),
        CheckboxListTile(
          title: Text(
            'Featured Products',
            style: TextStyle(color: colors.onSurface),
          ),
          value: _showOnlyFeatured,
          onChanged: (value) {
            setModalState(() {
              _showOnlyFeatured = value ?? false;
            });
          },
          activeColor: colors.primary,
        ),
        CheckboxListTile(
          title: Text(
            'Free Shipping',
            style: TextStyle(color: colors.onSurface),
          ),
          value: _showOnlyFreeShipping,
          onChanged: (value) {
            setModalState(() {
              _showOnlyFreeShipping = value ?? false;
            });
          },
          activeColor: colors.primary,
        ),
        CheckboxListTile(
          title: Text(
            'Office Payment',
            style: TextStyle(color: colors.onSurface),
          ),
          value: _showOnlyCOD,
          onChanged: (value) {
            setModalState(() {
              _showOnlyCOD = value ?? false;
            });
          },
          activeColor: colors.primary,
        ),
      ],
    );
  }

  Widget _buildShippingFilter(ColorScheme colors, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _maxShippingDays.toString(),
          decoration: InputDecoration(
            labelText: 'Max Shipping Days',
            suffixText: 'days',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setModalState(() {
              _maxShippingDays = int.tryParse(value) ?? 30;
            });
          },
          style: TextStyle(color: colors.onSurface),
        ),
      ],
    );
  }

  Widget _buildRatingFilter(ColorScheme colors, StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _minRating.toString(),
          decoration: InputDecoration(
            labelText: 'Minimum Rating',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            labelStyle: TextStyle(color: colors.onSurface.withOpacity(0.7)),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setModalState(() {
              _minRating = int.tryParse(value) ?? 0;
            });
          },
          style: TextStyle(color: colors.onSurface),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions(ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.history,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                    _saveRecentSearches();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: colors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _recentSearches.map((search) {
                      return GestureDetector(
                        onTap: () {
                          _searchController.text = search;
                          setState(() {
                            _query = search;
                          });
                          _performSearch(search);
                        },
                        child: Chip(
                          label: Text(
                            search,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.onSurface,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                          onDeleted: () {
                            setState(() {
                              _recentSearches.remove(search);
                            });
                            _saveRecentSearches();
                          },
                          backgroundColor: colors.surfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colors.outline.withOpacity(0.3),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colors.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No recent searches yet. Start searching to see your history here.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Smart Search Suggestions Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Smart Search Suggestions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSearchSuggestion(
                  'I need gym equipment for home workouts',
                  onTap: () {
                    setState(() {
                      _query = 'gym equipment home workout';
                    });
                    _performSearch('gym equipment home workout');
                  },
                ),
                SizedBox(height: 12),
                _buildSearchSuggestion(
                  'I\'m looking for electronics and gadgets',
                  onTap: () {
                    setState(() {
                      _query = 'electronics gadgets';
                    });
                    _performSearch('electronics gadgets');
                  },
                ),
                SizedBox(height: 12),
                _buildSearchSuggestion(
                  'Show me trending fashion items',
                  onTap: () {
                    setState(() {
                      _query = 'trending fashion';
                    });
                    _performSearch('trending fashion');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
