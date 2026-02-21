import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';
import 'package:intl/intl.dart';

class TransactionItem extends StatelessWidget {
  final WalletTransactionEntity transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCredit = transaction.type.toLowerCase() == 'credit';
    final amountColor = isCredit ? Colors.green : Colors.red;
    final amountPrefix = isCredit ? '+' : '-';
    final icon = isCredit ? Icons.add_circle : Icons.remove_circle;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: amountColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                if (transaction.orderId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Order #${transaction.orderId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix \$ ${transaction.amount.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  transaction.type.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}
