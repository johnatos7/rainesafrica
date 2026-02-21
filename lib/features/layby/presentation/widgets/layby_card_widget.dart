import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_status_badge.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

/// Card widget for displaying a layby application in lists
class LaybyCardWidget extends ConsumerWidget {
  final LaybyApplication application;
  final VoidCallback? onTap;

  const LaybyCardWidget({super.key, required this.application, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final totalAmount = double.tryParse(application.totalAmount) ?? 0;
    final totalPaid = double.tryParse(application.totalPaid) ?? 0;
    final formatCurrency = ref.watch(currencyFormattingProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Product + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child:
                        application.thumbnailUrl != null
                            ? Image.network(
                              application.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: colors.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image,
                                      color: colors.onSurface.withOpacity(0.3),
                                    ),
                                  ),
                            )
                            : Container(
                              color: colors.surfaceContainerHighest,
                              child: Icon(
                                Icons.image,
                                color: colors.onSurface.withOpacity(0.3),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${application.applicationNumber}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                LaybyStatusBadge(status: application.status),
              ],
            ),
            const SizedBox(height: 12),

            // Payment progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: application.paymentProgress,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  application.paymentProgress >= 1.0
                      ? Colors.teal
                      : colors.primary,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatCurrency(totalPaid)} paid',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
                Text(
                  'of ${formatCurrency(totalAmount)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            // Duration & monthly
            const SizedBox(height: 4),
            Text(
              '${application.durationMonths} months • ${formatCurrency(double.tryParse(application.monthlyAmount) ?? 0)}/mo',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
