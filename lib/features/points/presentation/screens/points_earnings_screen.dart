import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/widgets/loading_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/widgets/error_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/providers/points_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/widgets/points_balance_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/widgets/points_transaction_list.dart';

class PointsEarningsScreen extends ConsumerStatefulWidget {
  const PointsEarningsScreen({super.key});

  @override
  ConsumerState<PointsEarningsScreen> createState() =>
      _PointsEarningsScreenState();
}

class _PointsEarningsScreenState extends ConsumerState<PointsEarningsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pointsProvider.notifier).loadPoints();
      ref.read(pointsProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pointsState = ref.watch(pointsProvider);

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Points Earnings'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(pointsProvider.notifier).refreshPoints();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(pointsProvider.notifier).refreshPoints();
        },
        child: CustomScrollView(
          slivers: [
            // Points Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildPointsBalance(theme, colorScheme, pointsState),
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
                    if (pointsState.transactions.isNotEmpty)
                      Text(
                        '${pointsState.transactions.length} transactions',
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
            _buildTransactionsList(theme, colorScheme, pointsState),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsBalance(
    ThemeData theme,
    ColorScheme colorScheme,
    PointsState pointsState,
  ) {
    if (pointsState.isLoading) {
      return const LoadingWidget();
    }

    if (pointsState.error != null) {
      return CustomErrorWidget(
        message: pointsState.error!,
        onRetry: () {
          ref.read(pointsProvider.notifier).loadPoints();
        },
      );
    }

    if (pointsState.points == null) {
      return const SizedBox.shrink();
    }

    return PointsBalanceCard(points: pointsState.points!);
  }

  Widget _buildTransactionsList(
    ThemeData theme,
    ColorScheme colorScheme,
    PointsState pointsState,
  ) {
    if (pointsState.isLoadingTransactions) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.all(16.0), child: LoadingWidget()),
      );
    }

    if (pointsState.transactionError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomErrorWidget(
            message: pointsState.transactionError!,
            onRetry: () {
              ref.read(pointsProvider.notifier).loadTransactions();
            },
          ),
        ),
      );
    }

    if (pointsState.transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.stars_outlined,
                size: 64,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No Points Earned Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your points earnings will appear here',
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

    return PointsTransactionList(
      transactions: pointsState.transactions,
      hasNextPage: pointsState.hasNextPage,
      isLoadingMore: pointsState.isLoadingMoreTransactions,
      onLoadMore: () {
        if (pointsState.hasNextPage && !pointsState.isLoadingMoreTransactions) {
          ref
              .read(pointsProvider.notifier)
              .loadTransactions(page: pointsState.currentPage + 1);
        }
      },
    );
  }
}
