import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/order_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_details_header.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_details_info.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_details_timeline.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_details_loading.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_products_list.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load order details when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load from API
      ref.read(orderDetailsProvider.notifier).loadOrderDetails(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final orderState = ref.watch(orderDetailsProvider);

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      body: _buildBody(orderState, colors),
    );
  }

  Widget _buildBody(OrderDetailsState state, ColorScheme colors) {
    if (state.isLoading) {
      return const OrderDetailsLoading();
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!, colors);
    }

    if (state.order == null) {
      return _buildEmptyState(colors);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(orderDetailsProvider.notifier)
            .refreshOrderDetails(widget.orderId);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                OrderDetailsHeader(order: state.order!),
                const SizedBox(height: 16),
                OrderDetailsInfo(order: state.order!),
                const SizedBox(height: 16),
                OrderProductsList(
                  products: state.order!.products,
                  currencySymbol: state.order!.currencySymbol,
                  orderExchangeRate: state.order?.exchangeRate ?? 1.0,
                  orderId: state.order!.id,
                  consumerId: state.order!.consumerId,
                  showActionButtons: [
                    'completed',
                    'collected',
                  ].contains(state.order!.orderStatus.slug.toLowerCase()),
                ),
                const SizedBox(height: 16),
                OrderDetailsTimeline(order: state.order!),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, ColorScheme colors) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(orderDetailsProvider.notifier)
            .loadOrderDetails(widget.orderId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Failed to load order details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(orderDetailsProvider.notifier)
                          .loadOrderDetails(widget.orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Order not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This order may have been removed or does not exist',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
