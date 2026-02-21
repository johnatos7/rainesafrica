import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/providers/layby_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

/// "Buy Now, Pay Later" gradient card for the product detail screen.
/// Matches the website design with purple/blue gradient.
class LaybyEligibilityWidget extends ConsumerWidget {
  final int productId;
  final int? variationId;
  final double productPrice;
  final bool hasVariants;
  final bool isVariantSelected;

  const LaybyEligibilityWidget({
    super.key,
    required this.productId,
    this.variationId,
    required this.productPrice,
    this.hasVariants = false,
    this.isVariantSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eligibilityAsync = ref.watch(
      laybyEligibilityProvider(
        EligibilityParams(productId: productId, variationId: variationId),
      ),
    );

    return eligibilityAsync.when(
      data: (eligibility) {
        if (!eligibility.eligible) return const SizedBox.shrink();
        return _buildEligibilityCard(context, ref, eligibility);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildEligibilityCard(
    BuildContext context,
    WidgetRef ref,
    LaybyEligibility eligibility,
  ) {
    final formatCurrency = ref.watch(currencyFormattingProvider);
    final maxDuration =
        eligibility.availableDurations.isNotEmpty
            ? eligibility.availableDurations.reduce((a, b) => a > b ? a : b)
            : 6;
    final depositAmount =
        eligibility.price * eligibility.depositPercentage / 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF4FACFE)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy Now, Pay Later',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Split your purchase into easy payments',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interest & Duration card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '0% Interest',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Payment Period',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  Text(
                    '$maxDuration months',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bullet points
            _buildBulletPoint(
              '${eligibility.depositPercentage}% deposit',
              'then pay monthly - that\'s only ${formatCurrency(depositAmount)} upfront!',
              isBold: true,
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
              'No interest',
              '- you only pay the product price',
              isBold: true,
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
              'Quick approval',
              '- decision within 1-2 business days',
              isBold: true,
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
              'Secure',
              '- ID verification required for your protection',
              isBold: true,
            ),
            const SizedBox(height: 20),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (hasVariants && !isVariantSelected)
                        ? null
                        : () {
                          context.push(
                            '/layby/apply',
                            extra: {
                              'productId': productId,
                              'variationId': variationId,
                              'eligibility': eligibility,
                            },
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Apply for Layby Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Footer notes
            const Center(
              child: Text(
                '✓ No credit check required  •  ✓ Instant application',
                style: TextStyle(color: Colors.white60, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),

            // Eligibility & How it works
            Text(
              'Eligibility: Available for products over ${formatCurrency(eligibility.threshold)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'How it works: Apply → Approve → Pay deposit → Make monthly payments → Get product',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String bold, String rest, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.white70,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: bold,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $rest',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
