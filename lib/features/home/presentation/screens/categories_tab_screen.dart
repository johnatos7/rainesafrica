import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/cart_icon_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/providers/category_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/category_products_screen.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';
import 'package:go_router/go_router.dart';

class CategoriesTabScreen extends ConsumerStatefulWidget {
  const CategoriesTabScreen({super.key});

  @override
  ConsumerState<CategoriesTabScreen> createState() =>
      _CategoriesTabScreenState();
}

class _CategoriesTabScreenState extends ConsumerState<CategoriesTabScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late EasyRefreshController _refreshController;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  int _currentPage = 1;
  static const int _itemsPerPage = 20;
  List<CategoryEntity> _categories = [];

  // Pagination information
  bool _hasMorePages = false;

  @override
  bool get wantKeepAlive => false; // Dispose when not visible

  @override
  void initState() {
    super.initState();
    _refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _loadCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;

    try {
      if (!isRefresh) {
        setState(() => _isLoadingMore = true);
      }

      final paginatedCategories = await ref.read(
        paginatedCategoriesProvider({
          'page': isRefresh ? 1 : _currentPage,
          'paginate': _itemsPerPage,
          'status': 1,
        }).future,
      );

      setState(() {
        if (isRefresh || _currentPage == 1) {
          _categories =
              paginatedCategories.categories
                  .map((model) => model.toEntity())
                  .toList();
          _currentPage = 2; // Next page to load
        } else {
          _categories = [
            ..._categories,
            ...paginatedCategories.categories
                .map((model) => model.toEntity())
                .toList(),
          ];
          _currentPage++;
        }

        // Update pagination info
        _hasMorePages = paginatedCategories.pagination.hasNextPage;

        _isLoading = false;
        _isLoadingMore = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _hasError = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        leadingWidth: 100,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push(AppConstants.searchRoute);
            },
          ),
          const ThemeToggleButton(),
          CartIconWidget(
            iconColor: Theme.of(context).colorScheme.onSurface,
            badgeColor: Theme.of(context).colorScheme.primary,
            iconSize: 28,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16), // Margin from appbar to list
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Background color for the list
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load categories',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          _loadCategories(isRefresh: true);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                : EasyRefresh(
                  controller: _refreshController,
                  onRefresh: () async {
                    await _loadCategories(isRefresh: true);
                    _refreshController.finishRefresh();
                  },
                  onLoad:
                      _hasMorePages
                          ? () async {
                            await _loadCategories();
                            _refreshController.finishLoad();
                          }
                          : null,
                  child: ListView.separated(
                    controller: _scrollController,
                    itemCount: _categories.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          height: 1,
                          color: Theme.of(context).dividerColor,
                        ),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryTile(category);
                    },
                  ),
                ),
      ),
    );
  }

  Widget _buildCategoryTile(CategoryEntity category) {
    return Container(
      color: Theme.of(context).cardColor, // Background color for each list item
      child: ListTile(
        leading: _buildCategoryImage(category),
        title: Text(
          category.name ?? '-',
          style: TextStyle(
            fontSize: 14, // Smaller font size
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
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
      ),
    );
  }

  Widget _buildCategoryImage(CategoryEntity category) {
    final imageUrl =
        category.categoryImage?.imageUrl.isNotEmpty == true
            ? category.categoryImage!.imageUrl
            : (category.categoryIcon?.imageUrl.isNotEmpty == true
                ? category.categoryIcon!.imageUrl
                : null);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      );
    } else {
      return CircleAvatar(
        child: Icon(
          Icons.category,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        radius: 20,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      );
    }
  }
}
