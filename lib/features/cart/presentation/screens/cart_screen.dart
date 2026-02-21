import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/cart_item_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_loading.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_error.dart'
    as app_error;
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartSummaryAsync = ref.watch(cartSummaryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            // Use pop() to go back to previous screen, fallback to home if no previous screen
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go(AppConstants.homeRoute);
            }
          },
        ),
        title: Text(
          'Cart',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              // TODO: Implement edit mode
            },
          ),
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              // Navigate to wishlist screen using push to maintain navigation stack
              context.push('/wishlist');
            },
          ),
        ],
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart.isEmpty) {
            return const _EmptyCartWidget();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return CartItemWidget(
                      item: item,
                      onQuantityChanged: (newQuantity) async {
                        try {
                          await ref.read(
                            updateCartItemProvider({
                              'itemId': item.id,
                              'quantity': newQuantity,
                            }).future,
                          );
                          // Refresh cart to update totals
                          ref.refresh(cartProvider);
                          ref.refresh(cartSummaryProvider);
                        } catch (e) {
                          // Error handling is done in the widget
                        }
                      },
                      onShippingMethodChanged: (shippingMethod) async {
                        try {
                          await ref.read(
                            updateCartItemShippingProvider({
                              'itemId': item.id,
                              'shippingMethod': shippingMethod,
                            }).future,
                          );
                          // Refresh cart to update totals
                          ref.refresh(cartProvider);
                          ref.refresh(cartSummaryProvider);
                        } catch (e) {
                          // Error handling is done in the widget
                        }
                      },
                      onRemove: () async {
                        try {
                          await ref.read(
                            removeFromCartProvider(item.id).future,
                          );
                          // Refresh cart to update totals
                          ref.refresh(cartProvider);
                          ref.refresh(cartSummaryProvider);
                        } catch (e) {
                          // Error handling is done in the widget
                        }
                      },
                    );
                  },
                ),
              ),
              _CartSummaryWidget(cartSummaryAsync: cartSummaryAsync),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error:
            (error, stackTrace) => app_error.ErrorWidget(
              message: 'Failed to load cart: $error',
              onRetry: () => ref.refresh(cartProvider),
            ),
      ),
    );
  }
}

class _EmptyCartWidget extends StatelessWidget {
  const _EmptyCartWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home using push to maintain navigation stack
              context.push(AppConstants.homeRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }
}

class _CartSummaryWidget extends ConsumerWidget {
  final AsyncValue cartSummaryAsync;

  const _CartSummaryWidget({required this.cartSummaryAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Disclaimer text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Placing an item in your shopping cart does not reserve that item or price. We only reserve stock for your order once payment is received.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ),

          // Total and checkout button
          cartSummaryAsync.when(
            data:
                (summary) => Column(
                  children: [
                    // Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal: (${summary.totalItems} Items)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            summary.subtotal,
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),

                    // Fast Shipping Fee (only show if > 0)
                    if (summary.expeditedShippingFee > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fast Shipping Fee:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              summary.expeditedShippingFee,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          ref.watch(currencyFormattingProvider)(summary.total),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to checkout screen using push to maintain navigation stack
                          context.pushNamed('checkout_steps');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'PROCEED TO CHECKOUT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            loading: () => const CircularProgressIndicator(),
            error:
                (error, stackTrace) => Text(
                  'Error loading cart summary: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
          ),
        ],
      ),
    );
  }
}
