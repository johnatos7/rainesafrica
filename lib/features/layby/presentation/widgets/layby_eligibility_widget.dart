import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

/// Displays a promotional card for the layby feature on product detail pages.
///
/// Receives [LaybyEligibility] data from the product entity directly — no
/// separate API call needed. Shows a gradient card with the layby benefits
/// (0% Interest, flexible plans) and a call-to-action to apply.
class LaybyEligibilityWidget extends ConsumerWidget {
  /// The product's layby eligibility data from the product API response
  final LaybyEligibility? eligibility;

  /// Price to calculate layby breakdown for (effective price)
  final double productPrice;

  /// The product ID
  final int productId;

  /// Optional variation ID
  final int? variationId;

  /// Whether the product has variants
  final bool hasVariants;

  /// Whether a variant has been selected
  final bool isVariantSelected;

  const LaybyEligibilityWidget({
    super.key,
    required this.eligibility,
    required this.productPrice,
    required this.productId,
    this.variationId,
    this.hasVariants = false,
    this.isVariantSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🔍 [LAYBY WIDGET] eligibility: $eligibility');
    print(
      '🔍 [LAYBY WIDGET] eligible: ${eligibility?.eligible}, hasVariants: $hasVariants, isVariantSelected: $isVariantSelected, price: $productPrice, minPrice: ${eligibility?.minPrice}, durations: ${eligibility?.availableDurations}',
    );
    // Don't show if no eligibility data or product is not eligible
    if (eligibility == null || !eligibility!.eligible) {
      print('🔍 [LAYBY WIDGET] HIDDEN: eligibility null or not eligible');
      return const SizedBox.shrink();
    }

    // Don't show if product has variants but none selected
    if (hasVariants && !isVariantSelected) {
      print('🔍 [LAYBY WIDGET] HIDDEN: has variants but none selected');
      return const SizedBox.shrink();
    }

    // Don't show if price is below minimum
    if (productPrice < eligibility!.minPrice) {
      print('🔍 [LAYBY WIDGET] HIDDEN: price below minimum');
      return const SizedBox.shrink();
    }
    print('🔍 [LAYBY WIDGET] SHOWING layby section');

    final colors = Theme.of(context).colorScheme;
    final formatCurrency = ref.watch(currencyFormattingProvider);

    // Calculate min deposit and monthly payment using the shortest duration
    final durations = eligibility!.availableDurations;
    if (durations.isEmpty) return const SizedBox.shrink();

    final depositPercent = eligibility!.depositPercentage;
    final deposit = productPrice * depositPercent / 100;
    final shortestDuration = durations.first;
    final monthlyPayment = (productPrice - deposit) / shortestDuration;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withOpacity(0.08),
            colors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative element
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buy Now, Pay Later',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                            ),
                            Text(
                              '0% Interest • Layby',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Benefits row
                  Row(
                    children: [
                      _buildBenefitChip(
                        context,
                        Icons.percent_rounded,
                        '0% Interest',
                        colors,
                      ),
                      const SizedBox(width: 8),
                      _buildBenefitChip(
                        context,
                        Icons.calendar_today_rounded,
                        '${durations.first}-${durations.last} months',
                        colors,
                      ),
                      const SizedBox(width: 8),
                      _buildBenefitChip(
                        context,
                        Icons.smartphone_rounded,
                        'Easy Payments',
                        colors,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Payment preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Starting from',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurface.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatCurrency(monthlyPayment)}/month',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Deposit',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurface.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${formatCurrency(deposit)} ($depositPercent%)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/layby/apply',
                          extra: {
                            'eligibility': eligibility,
                            'productId': productId,
                            'variationId': variationId,
                            'productPrice': productPrice,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Apply for Layby',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitChip(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme colors,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
