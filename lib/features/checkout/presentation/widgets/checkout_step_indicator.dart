import 'package:flutter/material.dart';

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final List<IconData> stepIcons;

  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.stepIcons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    _buildStepCircle(
                      index: index,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      stepIcons: stepIcons,
                      colorScheme: colorScheme,
                    ),
                    if (index < totalSteps - 1)
                      Expanded(
                        child: _buildStepLine(
                          isCompleted: isCompleted,
                          isActive: isActive,
                          colorScheme: colorScheme,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          // Step titles
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              return Expanded(
                child: Text(
                  stepTitles[index],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight:
                        isActive || isCompleted
                            ? FontWeight.w600
                            : FontWeight.w400,
                    color:
                        isActive || isCompleted
                            ? colorScheme.primary
                            : colorScheme.outline,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle({
    required int index,
    required bool isActive,
    required bool isCompleted,
    required List<IconData> stepIcons,
    required ColorScheme colorScheme,
  }) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    if (isCompleted) {
      backgroundColor = colorScheme.secondary;
      iconColor = colorScheme.onSecondary;
      icon = Icons.check;
    } else if (isActive) {
      backgroundColor = colorScheme.primary;
      iconColor = colorScheme.onPrimary;
      icon = stepIcons[index];
    } else {
      backgroundColor = colorScheme.surfaceVariant;
      iconColor = colorScheme.onSurfaceVariant;
      icon = stepIcons[index];
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow:
            (isActive || isCompleted)
                ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  Widget _buildStepLine({
    required bool isCompleted,
    required bool isActive,
    required ColorScheme colorScheme,
  }) {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:
            isCompleted
                ? colorScheme.secondary
                : isActive
                ? colorScheme.primary
                : colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class CompactStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const CompactStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;

              return Container(
                margin: const EdgeInsets.only(left: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
