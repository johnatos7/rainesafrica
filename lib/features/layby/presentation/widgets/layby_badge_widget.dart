import 'package:flutter/material.dart';

/// A compact badge shown on product listing cards for layby-eligible products.
///
/// Now accepts an `isEligible` flag directly from the product's
/// `layby_eligibility.eligible` field instead of using a hardcoded threshold.
class LaybyBadgeWidget extends StatelessWidget {
  /// Whether the product is eligible for layby.
  /// Defaults to false when the product API doesn't include eligibility data.
  final bool isEligible;

  const LaybyBadgeWidget({super.key, required this.isEligible});

  @override
  Widget build(BuildContext context) {
    if (!isEligible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4FACFE)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'Layby Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
