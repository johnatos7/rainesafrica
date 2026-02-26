import 'package:flutter/widgets.dart';

/// Lightweight responsive utility for adaptive layouts.
///
/// Centralises screen-dimension logic so every widget uses consistent
/// breakpoints and proportions — matching the Takealot-style grid.
class ResponsiveUtils {
  ResponsiveUtils._();

  // ─── Breakpoints ─────────────────────────────────────────────
  static const double _smallScreenWidth = 360;
  static const double _tabletWidth = 600;

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width <= _smallScreenWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletWidth;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // ─── Product Card (horizontal scroll) ────────────────────────
  /// Card width used in home-screen horizontal product lists.
  /// ~44 % of screen → roughly 2 cards visible at a time (like Takealot).
  static double productCardWidth(BuildContext context) {
    final sw = screenWidth(context);
    if (sw <= _smallScreenWidth) return sw * 0.42;
    if (sw >= _tabletWidth) return sw * 0.30;
    return sw * 0.44;
  }

  /// Image height inside a horizontal-scroll product card.
  static double productCardImageHeight(BuildContext context) =>
      productCardWidth(context) * 0.85;

  /// Total height of the horizontal product section (image + info).
  static double productSectionHeight(BuildContext context) =>
      productCardImageHeight(context) + 155;

  // ─── Product Grid (category / search) ────────────────────────
  /// Number of columns for the product grid.
  static int gridCrossAxisCount(double availableWidth) {
    if (availableWidth >= _tabletWidth) return 3;
    return 2;
  }

  /// Aspect ratio for grid items so the image + info never squashes.
  static double gridChildAspectRatio(double availableWidth) {
    final columns = gridCrossAxisCount(availableWidth);
    const spacing = 4.0; // crossAxisSpacing
    final itemWidth =
        (availableWidth - (columns - 1) * spacing - 24) /
        columns; // 24 = padding
    final imageHeight = itemWidth * 0.85;
    const infoHeight = 155.0;
    return itemWidth / (imageHeight + infoHeight);
  }

  // ─── Categories ──────────────────────────────────────────────
  static double categoryCardWidth(BuildContext context) {
    final sw = screenWidth(context);
    if (sw <= _smallScreenWidth) return sw * 0.20;
    return sw * 0.21;
  }

  static double categoryCirlceSize(BuildContext context) =>
      categoryCardWidth(context) * 0.9;

  static double categorySectionHeight(BuildContext context) =>
      categoryCirlceSize(context) + 44;

  // ─── Banners ─────────────────────────────────────────────────
  static double bannerHeight(BuildContext context) {
    final sw = screenWidth(context);
    return (sw * 0.50).clamp(140.0, 280.0);
  }

  static double interspersedBannerHeight(BuildContext context) {
    final sw = screenWidth(context);
    return (sw * 0.48).clamp(130.0, 260.0);
  }

  // ─── Product Detail ──────────────────────────────────────────
  static double productDetailImageHeight(BuildContext context) {
    final sw = screenWidth(context);
    return (sw * 0.75).clamp(220.0, 420.0);
  }

  // ─── Cart / Wishlist ─────────────────────────────────────────
  static double cartItemImageSize(BuildContext context) {
    final sw = screenWidth(context);
    return (sw * 0.2).clamp(60.0, 100.0);
  }
}
