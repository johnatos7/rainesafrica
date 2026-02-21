import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';

class CartIconWidget extends ConsumerWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double? iconSize;
  final bool showBadge;

  const CartIconWidget({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.iconSize,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cartItemCountAsync = ref.watch(cartItemCountProvider);

    return GestureDetector(
      onTap: () => context.push(AppConstants.cartRoute),
      child: Stack(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: iconColor ?? colors.onSurface,
            size: iconSize ?? 24,
          ),
          if (showBadge)
            cartItemCountAsync.when(
              data: (count) {
                if (count > 0) {
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? colors.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.surface, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: TextStyle(
                          color: badgeTextColor ?? colors.onError,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class CartIconButton extends ConsumerWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final double? iconSize;
  final bool showBadge;
  final String? tooltip;

  const CartIconButton({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.badgeTextColor,
    this.iconSize,
    this.showBadge = true,
    this.tooltip = 'Shopping Cart',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final cartItemCountAsync = ref.watch(cartItemCountProvider);

    return IconButton(
      onPressed: () => context.push(AppConstants.cartRoute),
      tooltip: tooltip,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: iconColor ?? colors.onSurface,
            size: iconSize ?? 24,
          ),
          if (showBadge)
            cartItemCountAsync.when(
              data: (count) {
                if (count > 0) {
                  return Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: badgeColor ?? colors.error,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.surface, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: TextStyle(
                          color: badgeTextColor ?? colors.onError,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
