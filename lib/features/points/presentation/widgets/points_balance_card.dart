import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';

class PointsBalanceCard extends StatelessWidget {
  final PointsEntity points;

  const PointsBalanceCard({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.stars, color: colors.onPrimary, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Points Earnings',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Total Points',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${points.balance.toStringAsFixed(0)} pts',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Earn points with every purchase',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
