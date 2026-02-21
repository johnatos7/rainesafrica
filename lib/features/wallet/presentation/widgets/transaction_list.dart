import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_theme.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/widgets/transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<WalletTransactionEntity> transactions;
  final bool hasNextPage;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const TransactionList({
    super.key,
    required this.transactions,
    this.hasNextPage = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < transactions.length) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: index == transactions.length - 1 ? 16 : 8,
              ),
              child: TransactionItem(transaction: transactions[index]),
            );
          } else if (index == transactions.length && hasNextPage) {
            return _buildLoadMoreButton(context, colors);
          } else if (index == transactions.length && isLoadingMore) {
            return _buildLoadingMore(context, colors);
          }
          return null;
        },
        childCount:
            transactions.length + (hasNextPage || isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onLoadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Load More Transactions'),
        ),
      ),
    );
  }

  Widget _buildLoadingMore(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more transactions...',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
