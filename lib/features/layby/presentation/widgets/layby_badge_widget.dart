import 'package:flutter/material.dart';

/// A compact badge shown on product listing cards for layby-eligible products
class LaybyBadgeWidget extends StatelessWidget {
  /// The product's effective price
  final double productPrice;

  /// The layby eligibility threshold (default $100)
  final double threshold;

  const LaybyBadgeWidget({
    super.key,
    required this.productPrice,
    this.threshold = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    if (productPrice < threshold) return const SizedBox.shrink();

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
