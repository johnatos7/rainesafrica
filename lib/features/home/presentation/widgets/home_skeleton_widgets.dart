import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/core/images/shimmer_placeholder.dart';

/// Skeleton loading widget for featured categories
class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: 124,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6, // Show 6 skeleton categories
        itemBuilder: (context, index) {
          return Container(
            width: 84,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                // Category image skeleton
                ShimmerPlaceholder(
                  width: 76,
                  height: 76,
                  shape: BoxShape.circle,
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                // Category name skeleton
                ShimmerPlaceholder(
                  width: 60,
                  height: 12,
                  borderRadius: BorderRadius.circular(6),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton loading widget for banner carousel
class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Banner image skeleton
          ShimmerPlaceholder(
            width: double.infinity,
            height: 140,
            borderRadius: BorderRadius.zero,
            baseColor: colors.surfaceVariant,
            highlightColor: colors.onSurface.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          // Banner indicators skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      index == 0
                          ? colors.primary
                          : colors.outline.withOpacity(0.3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading widget for product cards
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outline.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image skeleton
          ShimmerPlaceholder(
            width: double.infinity,
            height: 160,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            baseColor: colors.surfaceVariant,
            highlightColor: colors.onSurface.withOpacity(0.1),
          ),
          // Product details skeleton
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name skeleton
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
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                // Rating skeleton
                Row(
                  children: List.generate(5, (index) {
                    return Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Price skeleton
                ShimmerPlaceholder(
                  width: 80,
                  height: 20,
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
  }
}

/// Skeleton loading widget for product sections
class ProductSectionSkeleton extends StatelessWidget {
  final String title;

  const ProductSectionSkeleton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerPlaceholder(
                  width: 150,
                  height: 20,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
                ShimmerPlaceholder(
                  width: 60,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                  baseColor: colors.surfaceVariant,
                  highlightColor: colors.onSurface.withOpacity(0.1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Product cards skeleton
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4, // Show 4 skeleton product cards
              itemBuilder: (context, index) {
                return const ProductCardSkeleton();
              },
            ),
          ),
        ],
      ),
    );
  }
}
