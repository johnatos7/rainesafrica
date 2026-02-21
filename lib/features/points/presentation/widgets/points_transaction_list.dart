import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';

class PointsTransactionList extends StatelessWidget {
  final List<PointsTransactionEntity> transactions;
  final bool hasNextPage;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const PointsTransactionList({
    super.key,
    required this.transactions,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == transactions.length) {
          return _buildLoadMoreButton(context, colors);
        }

        final transaction = transactions[index];
        return _buildTransactionItem(context, theme, colors, transaction);
      }, childCount: transactions.length + (hasNextPage ? 1 : 0)),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colors,
    PointsTransactionEntity transaction,
  ) {
    final isCredit = transaction.type == 'credit';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color:
                isCredit
                    ? colors.primary.withOpacity(0.1)
                    : colors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            isCredit ? Icons.add : Icons.remove,
            color: isCredit ? colors.primary : colors.error,
            size: 24,
          ),
        ),
        title: Text(
          transaction.detail,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        subtitle: Text(
          _formatDate(transaction.createdAt),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} pts',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCredit ? colors.primary : colors.error,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color:
                    isCredit
                        ? colors.primary.withOpacity(0.1)
                        : colors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.type.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCredit ? colors.primary : colors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child:
            isLoadingMore
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: onLoadMore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Load More'),
                ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
