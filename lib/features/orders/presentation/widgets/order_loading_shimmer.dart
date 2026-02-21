import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/shimmer_placeholder.dart';

class OrderLoadingShimmer extends StatelessWidget {
  const OrderLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildShimmerCard(colors),
        );
      },
    );
  }

  Widget _buildShimmerCard(ColorScheme colors) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer - Order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerPlaceholder(
                  width: 120,
                  height: 20,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
                ShimmerPlaceholder(
                  width: 80,
                  height: 24,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Order info shimmer - Date, payment method, delivery info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date row with icon
                Row(
                  children: [
                    ShimmerPlaceholder(
                      width: 16,
                      height: 16,
                      shape: BoxShape.circle,
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    ShimmerPlaceholder(
                      width: 100,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Payment method row with icon
                Row(
                  children: [
                    ShimmerPlaceholder(
                      width: 16,
                      height: 16,
                      shape: BoxShape.circle,
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    ShimmerPlaceholder(
                      width: 150,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Delivery info row with icon (sometimes present)
                Row(
                  children: [
                    ShimmerPlaceholder(
                      width: 16,
                      height: 16,
                      shape: BoxShape.circle,
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                    const SizedBox(width: 8),
                    ShimmerPlaceholder(
                      width: 200,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Status and amount shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerPlaceholder(
                        width: 80,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                        baseColor: colors.surfaceVariant,
                        highlightColor: colors.onSurface.withOpacity(0.1),
                      ),
                      const SizedBox(height: 4),
                      ShimmerPlaceholder(
                        width: 100,
                        height: 18,
                        borderRadius: BorderRadius.circular(4),
                        baseColor: colors.surfaceVariant,
                        highlightColor: colors.onSurface.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
                // View Details button shimmer
                ShimmerPlaceholder(
                  width: 100,
                  height: 32,
                  borderRadius: BorderRadius.circular(6),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
