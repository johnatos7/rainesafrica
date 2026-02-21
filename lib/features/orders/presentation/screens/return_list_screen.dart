import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/refund_return_list_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/return_details_screen.dart';
import 'package:intl/intl.dart';

class ReturnListScreen extends ConsumerStatefulWidget {
  const ReturnListScreen({super.key});

  @override
  ConsumerState<ReturnListScreen> createState() => _ReturnListScreenState();
}

class _ReturnListScreenState extends ConsumerState<ReturnListScreen> {
  @override
  void initState() {
    super.initState();
    // Load returns when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(returnListProvider.notifier).loadReturns(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final returnListState = ref.watch(returnListProvider);

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'My Returns',
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
              .read(returnListProvider.notifier)
              .loadReturns(refresh: true);
        },
        child: _buildBody(returnListState, colors, theme),
      ),
    );
  }

  Widget _buildBody(
    ReturnListState state,
    ColorScheme colors,
    ThemeData theme,
  ) {
    if (state.isLoading && state.returns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.returns.isEmpty) {
      return _buildErrorState(state.errorMessage!, colors);
    }

    if (state.returns.isEmpty) {
      return _buildEmptyState(colors);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.returns.length,
      itemBuilder: (context, index) {
        final returnItem = state.returns[index];
        return _buildReturnCard(returnItem, colors, theme);
      },
    );
  }

  Widget _buildReturnCard(
    ReturnListItemEntity returnItem,
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
              builder: (context) => ReturnDetailsScreen(returnItem: returnItem),
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
                          'Return #${returnItem.id}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${returnItem.orderId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(returnItem.status, colors, theme),
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
                      Icons.info_outline,
                      'Reason',
                      returnItem.returnReason,
                      colors,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.star_outline,
                      'Preferred Outcome',
                      returnItem.preferredOutcome
                          .replaceAll('_', ' ')
                          .toUpperCase(),
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
                    DateFormat('MMM dd, yyyy').format(returnItem.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: colors.secondary,
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
        Icon(icon, size: 16, color: colors.secondary.withOpacity(0.7)),
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
              Icons.keyboard_return_outlined,
              size: 80,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Returns',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have not requested any returns yet',
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
              'Failed to load returns',
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
                    .read(returnListProvider.notifier)
                    .loadReturns(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.onSecondary,
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
