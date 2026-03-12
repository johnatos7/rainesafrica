import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/providers/product_providers.dart';

/// Screen that fetches and displays products by a list of SKUs.
///
/// Used for deep links like `/en/collections?skus=sku1,sku2,...`
class SkuCollectionScreen extends ConsumerStatefulWidget {
  final List<String> skus;
  final String title;

  const SkuCollectionScreen({
    super.key,
    required this.skus,
    this.title = 'Collection',
  });

  @override
  ConsumerState<SkuCollectionScreen> createState() =>
      _SkuCollectionScreenState();
}

class _SkuCollectionScreenState extends ConsumerState<SkuCollectionScreen> {
  List<ProductEntity>? _products;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.getProductsBySkus(skus: widget.skus);

      result.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (products) {
          setState(() {
            _products = products;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.surface,
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products == null || _products!.isEmpty) {
      return Center(
        child: Text(
          'No products found',
          style: TextStyle(
            color: colors.onSurface.withOpacity(0.5),
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _products!.length,
        itemBuilder: (context, index) {
          return ProductCard(product: _products![index], isGridItem: true);
        },
      ),
    );
  }
}
