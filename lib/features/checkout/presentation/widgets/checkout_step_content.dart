import 'package:flutter/material.dart';

// Theme constants for consistent styling
class CheckoutStepThemes {
  static Duration get defaultAnimationDuration =>
      const Duration(milliseconds: 300);

  static TextStyle titleTextStyle(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Theme.of(context).colorScheme.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle subtitleTextStyle(BuildContext context) => TextStyle(
    fontSize: 10,
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    height: 1.4,
  );

  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class CheckoutStepContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool isActive;
  final Duration animationDuration;
  final VoidCallback? onHeaderTap;
  final bool showHeader;

  const CheckoutStepContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.iconColor,
    this.backgroundColor,
    this.isActive = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onHeaderTap,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            _buildStepHeader(context),
            const SizedBox(height: 24),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedOpacity(
      duration: animationDuration,
      opacity: isActive ? 1.0 : 0.6,
      child: GestureDetector(
        onTap: onHeaderTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor ?? scheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isActive
                      ? (iconColor ?? scheme.primary).withOpacity(0.2)
                      : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? scheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (iconColor ?? scheme.primary).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor ?? scheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CheckoutStepThemes.titleTextStyle(
                        context,
                      ).copyWith(
                        color:
                            isActive
                                ? scheme.onSurface
                                : scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: CheckoutStepThemes.subtitleTextStyle(
                        context,
                      ).copyWith(
                        color:
                            isActive
                                ? scheme.onSurface.withOpacity(0.6)
                                : scheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
              if (onHeaderTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutStepCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showShadow;
  final VoidCallback? onTap;
  final Color? borderColor;

  const CheckoutStepCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.showShadow = true,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        elevation: showShadow ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          child: Container(
            width: double.infinity,
            padding: padding ?? const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: backgroundColor ?? scheme.surface,
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
              border:
                  borderColor != null
                      ? Border.all(color: borderColor!, width: 1)
                      : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class CheckoutStepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;
  final double borderRadius;

  const CheckoutStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.height = 4,
    this.borderRadius = 2,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
            decoration: BoxDecoration(
              color:
                  isActive ? scheme.primary : scheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        );
      }),
    );
  }
}

// Example usage
class CheckoutStepExample extends StatelessWidget {
  const CheckoutStepExample({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
            child: CheckoutStepProgress(currentStep: 1, totalSteps: 4),
          ),
          Expanded(
            child: CheckoutStepContent(
              title: "Shipping Information",
              subtitle: "Enter your shipping address and contact details",
              icon: Icons.local_shipping,
              backgroundColor: scheme.surfaceVariant,
              onHeaderTap: () {},
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  CheckoutStepCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: CheckoutStepThemes.titleTextStyle(
                            context,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CheckoutStepCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Address',
                          style: CheckoutStepThemes.titleTextStyle(
                            context,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            hintText: 'Enter your address',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigation buttons (not shown here for brevity)
        ],
      ),
    );
  }
}
