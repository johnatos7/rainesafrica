import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/providers/wishlist_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_item_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/create_wishlist_bottom_sheet.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_loading.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_error.dart'
    as app_error;
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';
import 'package:go_router/go_router.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wishlistsAsync = ref.watch(wishlistsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back,
        //     color: Theme.of(context).colorScheme.onSurface,
        //   ),
        //   onPressed: () {
        //     // Use pop() to go back to previous screen, fallback to home if no previous screen
        //     if (Navigator.of(context).canPop()) {
        //       context.pop();
        //     } else {
        //       context.go('/');
        //     }
        //   },
        // ),
        title: Text(
          'My Lists',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => _showCreateWishlistBottomSheet(context),
          ),
        ],
        bottom: wishlistsAsync.when(
          data: (wishlists) {
            if (wishlists.isEmpty) return null;

            // Update tab controller length if needed
            if (_tabController.length != wishlists.length) {
              _tabController.dispose();
              _tabController = TabController(
                length: wishlists.length,
                vsync: this,
              );
            }

            return TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.6),
              tabs:
                  wishlists
                      .map(
                        (wishlist) => Tab(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              wishlist.name,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            );
          },
          loading: () => null,
          error: (_, __) => null,
        ),
      ),
      body: wishlistsAsync.when(
        data: (wishlists) {
          if (wishlists.isEmpty) {
            return const _EmptyWishlistsWidget();
          }

          return TabBarView(
            controller: _tabController,
            children:
                wishlists
                    .map((wishlist) => _WishlistTabContent(wishlist: wishlist))
                    .toList(),
          );
        },
        loading: () => const LoadingWidget(),
        error:
            (error, stackTrace) => app_error.ErrorWidget(
              message: 'Failed to load wishlists: $error',
              onRetry: () => ref.refresh(wishlistsProvider),
            ),
      ),
    );
  }

  void _showCreateWishlistBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateWishlistBottomSheet(),
    );
  }
}

class _WishlistTabContent extends ConsumerWidget {
  final dynamic wishlist;

  const _WishlistTabContent({required this.wishlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (wishlist.items.isEmpty) {
      return _EmptyWishlistWidget(wishlist: wishlist);
    }

    return Column(
      children: [
        // Wishlist header with item count and actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${wishlist.itemCount} items',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => _showRenameBottomSheet(context, ref),
                  ),
                  if (!wishlist.isDefault)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => _showDeleteBottomSheet(context, ref),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Wishlist items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: wishlist.items.length,
            itemBuilder: (context, index) {
              final item = wishlist.items[index];
              return WishlistItemWidget(
                item: item,
                onRemove: () => _removeItem(ref, item.product.id.toString()),
                onMoveToCart: () => _moveToCart(context, ref, item.product),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showRenameBottomSheet(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: wishlist.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Rename List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Text field
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'List name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (controller.text.trim().isNotEmpty) {
                            try {
                              await ref.read(
                                renameWishlistProvider((
                                  id: wishlist.id,
                                  newName: controller.text.trim(),
                                )).future,
                              );
                              ref.invalidate(wishlistsProvider);
                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to rename list: $e'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Rename'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showDeleteBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Delete List',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                Text(
                  'Are you sure you want to delete "${wishlist.name}"? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await ref.read(
                              deleteWishlistProvider(wishlist.id).future,
                            );
                            ref.invalidate(wishlistsProvider);
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete list: $e'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _removeItem(WidgetRef ref, String productId) async {
    try {
      await ref.read(
        removeFromWishlistProvider((
          wishlistId: wishlist.id,
          productId: productId,
        )).future,
      );
      ref.invalidate(wishlistsProvider);
    } catch (e) {
      // Error handling could be improved with a snackbar
    }
  }

  void _moveToCart(BuildContext context, WidgetRef ref, dynamic product) async {
    try {
      // 1) Add to cart with quantity 1 and no variation by default
      await ref.read(
        addToCartProvider({
          'productId': product.id as int,
          'quantity': 1,
          'selectedVariationId': null,
          'selectedVariation': null,
          'selectedAttributes': null,
        }).future,
      );

      // 2) Remove from this wishlist
      await ref.read(
        removeFromWishlistProvider((
          wishlistId: wishlist.id,
          productId: (product.id).toString(),
        )).future,
      );

      // 3) Invalidate relevant providers to refresh UI
      ref.invalidate(wishlistsProvider);
      ref.invalidate(cartProvider);
      ref.invalidate(cartItemCountProvider);
      ref.invalidate(cartSummaryProvider);

      // 4) Notify user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moved to cart')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to move to cart: $e')));
    }
  }
}

class _EmptyWishlistsWidget extends StatelessWidget {
  const _EmptyWishlistsWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No wishlists yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first wishlist to save items you love',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateWishlistBottomSheet(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Create Wishlist'),
          ),
        ],
      ),
    );
  }

  void _showCreateWishlistBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateWishlistBottomSheet(),
    );
  }
}

class _EmptyWishlistWidget extends StatelessWidget {
  final dynamic wishlist;

  const _EmptyWishlistWidget({required this.wishlist});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '${wishlist.name} is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items you love to this list',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
