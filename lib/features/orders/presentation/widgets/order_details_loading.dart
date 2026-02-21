import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/shimmer_placeholder.dart';

class OrderDetailsLoading extends StatelessWidget {
  const OrderDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeaderSkeleton(colors),
              const SizedBox(height: 16),
              _buildInfoSkeleton(colors),
              const SizedBox(height: 16),
              _buildProductsSkeleton(colors),
              const SizedBox(height: 16),
              _buildTimelineSkeleton(colors),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton(ColorScheme colors) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerPlaceholder(
                  width: 150,
                  height: 24,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
                ShimmerPlaceholder(
                  width: 100,
                  height: 28,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Total amount
            ShimmerPlaceholder(
              width: 120,
              height: 32,
              borderRadius: BorderRadius.circular(4),
              baseColor: colors.surfaceVariant,
              highlightColor: colors.onSurface.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSkeleton(ColorScheme colors) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ShimmerPlaceholder(
              width: 150,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: colors.surfaceVariant,
              highlightColor: colors.onSurface.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            // Info rows
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerPlaceholder(
                      width: 100,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                    ShimmerPlaceholder(
                      width: 120,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSkeleton(ColorScheme colors) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ShimmerPlaceholder(
              width: 120,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: colors.surfaceVariant,
              highlightColor: colors.onSurface.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            // Product items
            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // Product image
                    ShimmerPlaceholder(
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.circular(8),
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                    const SizedBox(width: 12),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerPlaceholder(
                            width: double.infinity,
                            height: 16,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: colors.surfaceVariant,
                            highlightColor: colors.onSurface.withOpacity(0.1),
                          ),
                          const SizedBox(height: 8),
                          ShimmerPlaceholder(
                            width: 100,
                            height: 14,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: colors.surfaceVariant,
                            highlightColor: colors.onSurface.withOpacity(0.1),
                          ),
                          const SizedBox(height: 8),
                          ShimmerPlaceholder(
                            width: 80,
                            height: 18,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: colors.surfaceVariant,
                            highlightColor: colors.onSurface.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSkeleton(ColorScheme colors) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            ShimmerPlaceholder(
              width: 100,
              height: 20,
              borderRadius: BorderRadius.circular(4),
              baseColor: colors.surfaceVariant,
              highlightColor: colors.onSurface.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            // Timeline items
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    // Timeline dot
                    ShimmerPlaceholder(
                      width: 12,
                      height: 12,
                      shape: BoxShape.circle,
                      baseColor: colors.surfaceVariant,
                      highlightColor: colors.onSurface.withOpacity(0.1),
                    ),
                    const SizedBox(width: 12),
                    // Timeline content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerPlaceholder(
                            width: double.infinity,
                            height: 16,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: colors.surfaceVariant,
                            highlightColor: colors.onSurface.withOpacity(0.1),
                          ),
                          const SizedBox(height: 4),
                          ShimmerPlaceholder(
                            width: 120,
                            height: 14,
                            borderRadius: BorderRadius.circular(4),
                            baseColor: colors.surfaceVariant,
                            highlightColor: colors.onSurface.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
