import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/widgets/loading_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/widgets/error_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/widgets/wallet_balance_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/widgets/transaction_list.dart';

class MyWalletScreen extends ConsumerStatefulWidget {
  const MyWalletScreen({super.key});

  @override
  ConsumerState<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends ConsumerState<MyWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadWallet();
      ref.read(walletProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('My Wallet'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(walletProvider.notifier).refreshWallet();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(walletProvider.notifier).refreshWallet();
        },
        child: CustomScrollView(
          slivers: [
            // Wallet Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildWalletBalance(theme, colorScheme, walletState),
              ),
            ),

            // Transactions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction History',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (walletState.transactions.isNotEmpty)
                      Text(
                        '${walletState.transactions.length} transactions',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Transactions List
            _buildTransactionsList(theme, colorScheme, walletState),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletBalance(
    ThemeData theme,
    ColorScheme colorScheme,
    WalletState walletState,
  ) {
    if (walletState.isLoading) {
      return const LoadingWidget();
    }

    if (walletState.error != null) {
      return CustomErrorWidget(
        message: walletState.error!,
        onRetry: () {
          ref.read(walletProvider.notifier).loadWallet();
        },
      );
    }

    if (walletState.wallet == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WalletBalanceCard(wallet: walletState.wallet!),
        const SizedBox(height: 12),
        if ((walletState.wallet?.balance ?? 0) > 0)
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed:
                  walletState.isRequestingRefund
                      ? null
                      : () async {
                        final error =
                            await ref
                                .read(walletProvider.notifier)
                                .requestRefundAll();
                        if (mounted) {
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request refund success'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          }
                        }
                      },
              icon:
                  walletState.isRequestingRefund
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.reply_all),
              label: Text(
                walletState.isRequestingRefund
                    ? 'Requesting...'
                    : 'Request Refund',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionsList(
    ThemeData theme,
    ColorScheme colorScheme,
    WalletState walletState,
  ) {
    if (walletState.isLoadingTransactions) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(16.0), child: LoadingWidget()),
      );
    }

    if (walletState.transactionError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomErrorWidget(
            message: walletState.transactionError!,
            onRetry: () {
              ref.read(walletProvider.notifier).loadTransactions();
            },
          ),
        ),
      );
    }

    if (walletState.transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Transactions Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your transaction history will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return TransactionList(
      transactions: walletState.transactions,
      hasNextPage: walletState.hasNextPage,
      isLoadingMore: walletState.isLoadingMoreTransactions,
      onLoadMore: () {
        if (walletState.hasNextPage && !walletState.isLoadingMoreTransactions) {
          ref
              .read(walletProvider.notifier)
              .loadTransactions(page: walletState.currentPage + 1);
        }
      },
    );
  }
}
