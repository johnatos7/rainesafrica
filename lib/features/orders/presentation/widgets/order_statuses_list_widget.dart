import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/order_provider.dart';

class OrderStatusesListWidget extends ConsumerStatefulWidget {
  const OrderStatusesListWidget({super.key});

  @override
  ConsumerState<OrderStatusesListWidget> createState() =>
      _OrderStatusesListWidgetState();
}

class _OrderStatusesListWidgetState
    extends ConsumerState<OrderStatusesListWidget> {
  @override
  void initState() {
    super.initState();
    // Load order statuses when widget is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderStatusesProvider.notifier).loadOrderStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final orderStatusesState = ref.watch(orderStatusesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Statuses'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: _buildBody(orderStatusesState, colors),
    );
  }

  Widget _buildBody(OrderStatusesState state, ColorScheme colors) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              'Error loading order statuses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(orderStatusesProvider.notifier).loadOrderStatuses();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Always use the provided static statuses list in this widget
    final staticStatuses = _staticStatuses();

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(orderStatusesProvider.notifier).loadOrderStatuses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staticStatuses.length,
        itemBuilder: (context, index) {
          final status = staticStatuses[index];
          return _buildStatusCard(status, colors);
        },
      ),
    );
  }

  List<OrderStatusEntity> _staticStatuses() {
    return const [
      OrderStatusEntity(id: 1, name: 'pending', slug: 'pending', sequence: 1),
      OrderStatusEntity(
        id: 2,
        name: 'processing',
        slug: 'processing',
        sequence: 2,
      ),
      OrderStatusEntity(
        id: 3,
        name: 'cancelled',
        slug: 'cancelled',
        sequence: 3,
      ),
      OrderStatusEntity(id: 4, name: 'shipped', slug: 'shipped', sequence: 4),
      OrderStatusEntity(
        id: 5,
        name: 'out for delivery',
        slug: 'out-for-delivery',
        sequence: 5,
      ),
      OrderStatusEntity(
        id: 6,
        name: 'delivered',
        slug: 'delivered',
        sequence: 6,
      ),
      OrderStatusEntity(
        id: 7,
        name: 'ready for collection',
        slug: 'ready-for-collection',
        sequence: 7,
      ),
      OrderStatusEntity(
        id: 8,
        name: 'collected',
        slug: 'collected',
        sequence: 8,
      ),
    ];
  }

  Widget _buildStatusCard(OrderStatusEntity status, ColorScheme colors) {
    final statusColor = _getStatusColor(status.name, colors);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sequence: ${status.sequence}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'Slug: ${status.slug}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'ID: ${status.id}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'pending':
        return colors.secondary;
      case 'processing':
        return colors.primary;
      case 'shipped':
        return colors.tertiary;
      case 'out for delivery':
        return colors.tertiary;
      case 'delivered':
        return Color.lerp(colors.primary, Colors.green, 0.7) ??
            const Color(0xFF52C41A);
      case 'ready for collection':
        return colors.tertiary;
      case 'collected':
        return Color.lerp(colors.primary, Colors.green, 0.7) ??
            const Color(0xFF52C41A);
      case 'cancelled':
        return colors.error;
      default:
        return colors.onSurface.withOpacity(0.6);
    }
  }
}
