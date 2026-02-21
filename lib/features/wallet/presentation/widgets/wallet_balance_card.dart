import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';

class WalletBalanceCard extends StatelessWidget {
  final WalletEntity wallet;

  const WalletBalanceCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Available Funds',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '\$${wallet.balance.toStringAsFixed(2)}',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: colorScheme.onPrimary.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${wallet.transactions.total} transactions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
