import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/refund_return_list_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/refund_details_screen.dart';
import 'package:intl/intl.dart';

class RefundListScreen extends ConsumerStatefulWidget {
  const RefundListScreen({super.key});

  @override
  ConsumerState<RefundListScreen> createState() => _RefundListScreenState();
}

class _RefundListScreenState extends ConsumerState<RefundListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load refunds when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(refundListProvider.notifier).loadRefunds(refresh: true);
    });

    // Setup pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(refundListProvider.notifier).loadRefunds();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final refundListState = ref.watch(refundListProvider);

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'My Refunds',
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(refundListProvider.notifier)
              .loadRefunds(refresh: true);
        },
        child: _buildBody(refundListState, colors, theme),
      ),
    );
  }

  Widget _buildBody(
    RefundListState state,
    ColorScheme colors,
    ThemeData theme,
  ) {
    if (state.isLoading && state.refunds.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.refunds.isEmpty) {
      return _buildErrorState(state.errorMessage!, colors);
    }

    if (state.refunds.isEmpty) {
      return _buildEmptyState(colors);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.refunds.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.refunds.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final refund = state.refunds[index];
        return _buildRefundCard(refund, colors, theme);
      },
    );
  }

  Widget _buildRefundCard(
    RefundListItemEntity refund,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: colors.surface,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RefundDetailsScreen(refund: refund),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refund #${refund.id}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${refund.orderId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(refund.status, colors, theme),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.money_outlined,
                      'Amount',
                      '\$${refund.amount.toStringAsFixed(2)}',
                      colors,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.payment_outlined,
                      'Payment Type',
                      refund.paymentType.toUpperCase(),
                      colors,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.info_outline,
                      'Reason',
                      refund.reason,
                      colors,
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(refund.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ColorScheme colors, ThemeData theme) {
    Color chipColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        chipColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'rejected':
      case 'failed':
        chipColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        chipColor = colors.surfaceVariant;
        textColor = colors.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.primary.withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.money_off_outlined,
              size: 80,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Refunds',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have not requested any refunds yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, ColorScheme colors) {
    final theme = Theme.of(context);
    return Center(
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
              child: Icon(Icons.error_outline, size: 40, color: colors.error),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load refunds',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(refundListProvider.notifier)
                    .loadRefunds(refresh: true);
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
    );
  }
}
