import 'package:flutter/material.dart';

/// A reusable widget that displays Takealot-style colour dots + "More colours"
/// and/or "+ More options" text beneath product prices on product cards.
///
/// Behaviour:
///   - Has colours only → colour dots + "More colours"
///   - Has colours + options (sizes, etc.) → colour dots + "More colours" (line 1)
///                                           + More options (line 2)
///   - Has options only (no colours) → "+ More options"
///   - Has nothing → empty
class ColorAttributeIndicator extends StatelessWidget {
  final dynamic product;

  /// Maximum number of colour dots to show before truncating with "More colours".
  final int maxDots;

  /// Size of each colour dot.
  final double dotSize;

  /// Optional pre-extracted colour slugs (used when product doesn't have full attributes).
  final List<String>? overrideColourSlugs;

  /// Optional pre-extracted "has more options" flag.
  final bool? overrideHasMoreOptions;

  const ColorAttributeIndicator({
    super.key,
    required this.product,
    this.maxDots = 4,
    this.dotSize = 12,
    this.overrideColourSlugs,
    this.overrideHasMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    final colourSlugs = overrideColourSlugs ?? _extractColourSlugs();
    final hasNonColourOptions =
        overrideHasMoreOptions ?? _hasNonColourVariations();

    if (colourSlugs.isEmpty && !hasNonColourOptions) {
      return const SizedBox.shrink();
    }

    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.55);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Colour dots + "More colours"
          if (colourSlugs.isNotEmpty)
            Row(
              children: [
                ..._buildColourDots(colourSlugs),
                Flexible(
                  child: Text(
                    colourSlugs.length > maxDots
                        ? '+${colourSlugs.length - maxDots} More colours'
                        : 'More colours',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          // Row 2: "+ More options" for non-colour variations
          if (hasNonColourOptions)
            Padding(
              padding: EdgeInsets.only(top: colourSlugs.isNotEmpty ? 2 : 0),
              child: Text(
                '+ More options',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: muted,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the colour dot widgets (up to [maxDots]).
  List<Widget> _buildColourDots(List<String> slugs) {
    final displayCount = slugs.length > maxDots ? maxDots : slugs.length;
    return List.generate(displayCount, (index) {
      final colors = _getColorsForSlug(slugs[index]);
      return Padding(
        padding: const EdgeInsets.only(right: 3),
        child:
            colors.length > 1
                ? _buildMultiColorDot(colors)
                : _buildSingleColorDot(colors.first),
      );
    });
  }

  // ─── Data extraction ─────────────────────────────────────────────

  /// Extract colour slugs from the product (only attribute_name == Colour).
  List<String> _extractColourSlugs() {
    try {
      // ProductEntity path – uses the colourAttributeValues getter
      final values = product.colourAttributeValues;
      if (values != null && values is List && values.isNotEmpty) {
        return values.map<String>((v) => (v.slug ?? '') as String).toList();
      }
    } catch (_) {
      // Fallback: attributes directly (for ProductModel)
      try {
        final attributes = product.attributes;
        if (attributes != null && attributes is List) {
          for (final attr in attributes) {
            if (attr.slug == 'colour' && attr.attributeValues != null) {
              final attrValues = attr.attributeValues as List;
              if (attrValues.isNotEmpty) {
                return attrValues
                    .map<String>((v) => (v.slug ?? '') as String)
                    .toList();
              }
            }
          }
        }
      } catch (_) {}

      // Fallback: variations (list API)
      try {
        final variations = product.variations;
        if (variations != null && variations is List && variations.isNotEmpty) {
          final seen = <String>{};
          final result = <String>[];
          for (final variation in variations) {
            final attrValues = variation.attributeValues;
            if (attrValues != null && attrValues is List) {
              for (final av in attrValues) {
                final attrName = av.attributeName as String?;
                if (attrName == null || attrName.toLowerCase() != 'colour')
                  continue;
                final slug = (av.slug ?? '') as String;
                if (slug.isNotEmpty && seen.add(slug)) {
                  result.add(slug);
                }
              }
            }
          }
          if (result.isNotEmpty) return result;
        }
      } catch (_) {}
    }
    return [];
  }

  /// Returns true if the product has any non-colour variations (sizes, etc.).
  bool _hasNonColourVariations() {
    try {
      final variations = product.variations;
      if (variations == null || variations is! List || variations.isEmpty) {
        return false;
      }
      for (final variation in variations) {
        final attrValues = variation.attributeValues;
        if (attrValues != null && attrValues is List) {
          for (final av in attrValues) {
            final attrName = (av.attributeName as String?)?.toLowerCase();
            if (attrName != null && attrName != 'colour') return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  // ─── Dot rendering ───────────────────────────────────────────────

  Widget _buildSingleColorDot(Color color) {
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color:
              color == Colors.white
                  ? const Color(0xFFCCCCCC)
                  : Colors.transparent,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiColorDot(List<Color> colors) {
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCCCCCC), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
      child: ClipOval(
        child: Row(
          children:
              colors.map((c) => Expanded(child: Container(color: c))).toList(),
        ),
      ),
    );
  }

  // ─── Slug → Color mapping ────────────────────────────────────────

  List<Color> _getColorsForSlug(String slug) {
    final multiColorPatterns = {
      'green-white': [_slugToColor('green'), _slugToColor('white')],
      'orange-white': [_slugToColor('orange'), _slugToColor('white')],
      'pink-white': [_slugToColor('pink'), _slugToColor('white')],
      'green-black': [_slugToColor('green'), _slugToColor('black')],
      'orange-black': [_slugToColor('orange'), _slugToColor('black')],
      'black-grey': [_slugToColor('black'), _slugToColor('grey')],
      'black-orange': [_slugToColor('black'), _slugToColor('orange')],
      'blue-yellow': [_slugToColor('blue'), _slugToColor('yellow')],
    };

    if (multiColorPatterns.containsKey(slug)) {
      return multiColorPatterns[slug]!;
    }

    return [_slugToColor(slug)];
  }

  Color _slugToColor(String slug) {
    const colorMap = <String, Color>{
      'black': Color(0xFF000000),
      'white': Color(0xFFFFFFFF),
      'blue': Color(0xFF2196F3),
      'dark-blue': Color(0xFF1565C0),
      'red': Color(0xFFF44336),
      'green': Color(0xFF4CAF50),
      'yellow': Color(0xFFFFEB3B),
      'orange': Color(0xFFFF9800),
      'pink': Color(0xFFE91E63),
      'dark-pink': Color(0xFFC2185B),
      'purple': Color(0xFF9C27B0),
      'grey': Color(0xFF9E9E9E),
      'space-grey': Color(0xFF757575),
      'silver': Color(0xFFC0C0C0),
      'sliver': Color(0xFFC0C0C0),
      'tan': Color(0xFFD2B48C),
      'jade': Color(0xFF00A86B),
      'metallic-black': Color(0xFF2C2C2C),
      'metallic-jade': Color(0xFF3B7A57),
      'metallic-raspberry': Color(0xFFB5284B),
      'raspberry': Color(0xFFE30B5C),
      'matcha': Color(0xFFA3C585),
      'starlight': Color(0xFFF5E6CC),
      'pink-proteas': Color(0xFFE8A0BF),
      'white-orchid': Color(0xFFF0E8E8),
    };

    return colorMap[slug] ?? const Color(0xFFBDBDBD);
  }
}
