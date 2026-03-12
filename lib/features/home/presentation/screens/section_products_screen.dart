import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_card.dart';

/// Simple grid screen that shows all products from a home-page section.
///
/// Receives a pre-loaded list rather than fetching from an API — keeping it
/// lightweight and consistent with the data already shown on the home screen.
class SectionProductsScreen extends ConsumerWidget {
  final String title;
  final List<ProductEntity> products;

  const SectionProductsScreen({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.surface,
      ),
      body:
          products.isEmpty
              ? Center(
                child: Text(
                  'No products available',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    isGridItem: true,
                  );
                },
              ),
    );
  }
}
