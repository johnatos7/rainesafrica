import 'package:flutter/material.dart';

class NotificationLoadingShimmer extends StatelessWidget {
  const NotificationLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerCard(theme),
    );
  }

  Widget _buildShimmerCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerCircle(40, 40, theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerRectangle(120, 16, theme),
                    const SizedBox(height: 8),
                    _buildShimmerRectangle(200, 14, theme),
                    const SizedBox(height: 4),
                    _buildShimmerRectangle(150, 14, theme),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildShimmerRectangle(60, 20, theme),
                        const Spacer(),
                        _buildShimmerRectangle(50, 12, theme),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCircle(double width, double height, ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }

  Widget _buildShimmerRectangle(double width, double height, ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
