import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/responsive_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/add_to_wishlist_dialog.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/category_products_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/shipping_selection_widget.dart';

class CartItemWidget extends ConsumerStatefulWidget {
  final CartItemEntity item;
  final Function(int) onQuantityChanged;
  final Function(String?)? onShippingMethodChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    this.onShippingMethodChanged,
    required this.onRemove,
  });

  @override
  ConsumerState<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends ConsumerState<CartItemWidget> {
  int _selectedQuantity = 1;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedQuantity = widget.item.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.item.product;

    // Handle null product (fallback for missing product data)
    if (product == null) {
      return _buildFallbackCartItem();
    }

    final isOnSale = product.isOnSale;
    final effectivePrice = product.effectivePrice;
    final originalPrice = product.price;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: ResponsiveUtils.cartItemImageSize(context),
                height: ResponsiveUtils.cartItemImageSize(context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (product.productThumbnail?.imageUrl.isNotEmpty ?? false)
                          ? CachedNetworkImage(
                            imageUrl: product.productThumbnail!.imageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                ),
                          )
                          : Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Variation Display
                    if (widget.item.variationDisplayName != null ||
                        widget.item.selectedVariation != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              widget.item.variationDisplayName ??
                                  widget.item.selectedVariation ??
                                  '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Wrap(
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(effectivePrice),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (isOnSale && originalPrice != effectivePrice) ...[
                          const SizedBox(width: 8),
                          Text(
                            ref.watch(currencyFormattingProvider)(
                              originalPrice,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Stock Status
                    _buildStockStatus(),

                    // Promotion Badge
                    if (isOnSale) _buildPromotionBadge(),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist Button
                  Column(
                    children: [
                      IconButton(
                        onPressed:
                            _isUpdating ? null : () => _addToWishlist(context),
                        icon: Icon(
                          Icons.favorite_border,
                          color:
                              _isUpdating
                                  ? Colors.grey[400]
                                  : Colors.orange[400],
                          size: 20,
                        ),
                      ),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Delete Button
                  Column(
                    children: [
                      IconButton(
                        onPressed: _isUpdating ? null : widget.onRemove,
                        icon: Icon(
                          Icons.delete_outline,
                          color:
                              _isUpdating ? Colors.grey[400] : Colors.red[400],
                          size: 20,
                        ),
                      ),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity Selector
          Row(
            children: [
              Text(
                'Quantity:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          _selectedQuantity > 1 && !_isUpdating
                              ? () => _updateQuantity(_selectedQuantity - 1)
                              : null,
                      icon: const Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _selectedQuantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          !_isUpdating
                              ? () => _updateQuantity(_selectedQuantity + 1)
                              : null,
                      icon: const Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Shipping Selection (if product has expedited shipping)
          if (product.hasExpedited == true && product.shippingOptions != null)
            ShippingSelectionWidget(
              product: product,
              selectedShippingMethod: widget.item.itemShippingMethod,
              onShippingMethodChanged:
                  widget.onShippingMethodChanged ?? (method) {},
            ),

          // COD Notice
          //if (!product.isCod) _buildCodNotice(),

          // View More Link
          _buildViewMoreLink(),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    final product = widget.item.product;
    if (product == null) return const SizedBox.shrink();

    final stockLocations = <String>[];

    // Mock stock locations based on the screenshot
    if (product.stockStatus == 'in_stock') {
      stockLocations.addAll(['ZW', 'ZM']);
      if (product.name.toLowerCase().contains('instant pot')) {
        stockLocations.add('DBN');
      }
    }

    return Row(
      children: [
        Text(
          'In stock',
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (stockLocations.isNotEmpty) ...[
          const SizedBox(width: 4),
          ...stockLocations.map(
            (location) => Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                location,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPromotionBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 12, color: Colors.green[600]),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                'PROMOTION APPLIED',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCodNotice() {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 12),
  //     padding: const EdgeInsets.all(12),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     child: Text(
  //       'This product is not eligible for Office Payment.',
  //       style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.3),
  //     ),
  //   );
  // }

  Widget _buildViewMoreLink() {
    final product = widget.item.product;
    if (product == null ||
        product.categories == null ||
        product.categories!.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstCategory = product.categories!.first;
    final categoryName = firstCategory.name.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: () => _navigateToCategoryProducts(firstCategory),
        child: Row(
          children: [
            Text(
              'View more from ',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategoryProducts(dynamic category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => CategoryProductsScreen(
              categorySlug:
                  category.slug ??
                  category.name.toLowerCase().replaceAll(' ', '-'),
              categoryName: category.name,
            ),
      ),
    );
  }

  Future<void> _updateQuantity(int newQuantity) async {
    if (newQuantity < 1 || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await widget.onQuantityChanged(newQuantity);
      setState(() {
        _selectedQuantity = newQuantity;
      });
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Widget _buildFallbackCartItem() {
    return Consumer(
      builder: (context, ref, child) {
        // Try to fetch product data if we have a productId
        if (widget.item.productId != null) {
          final productAsync = ref.watch(
            getProductProvider(widget.item.productId!),
          );

          return productAsync.when(
            data: (product) {
              if (product != null) {
                // We found the product, rebuild with proper product data
                return _buildCartItemWithProduct(product);
              } else {
                return _buildFallbackCartItemContent();
              }
            },
            loading: () => _buildFallbackCartItemContent(showLoading: true),
            error: (error, stackTrace) => _buildFallbackCartItemContent(),
          );
        } else {
          return _buildFallbackCartItemContent();
        }
      },
    );
  }

  Widget _buildCartItemWithProduct(dynamic product) {
    // This is a simplified version of the main cart item for fallback cases
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: ResponsiveUtils.cartItemImageSize(context),
                height: ResponsiveUtils.cartItemImageSize(context),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      product.productThumbnail?.imageUrl?.isNotEmpty == true
                          ? CachedNetworkImage(
                            imageUrl: product.productThumbnail.imageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 40,
                                  ),
                                ),
                          )
                          : Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.shopping_bag,
                              color: Colors.grey[400],
                              size: 40,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Product ${widget.item.productId}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price
                    Row(
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            product.effectivePrice ?? widget.item.unitPrice,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (widget.item.variationDisplayName != null ||
                            widget.item.selectedVariation != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              widget.item.variationDisplayName ??
                                  widget.item.selectedVariation ??
                                  '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist Button
                  Column(
                    children: [
                      IconButton(
                        onPressed:
                            _isUpdating ? null : () => _addToWishlist(context),
                        icon: Icon(
                          Icons.favorite_border,
                          color:
                              _isUpdating
                                  ? Colors.grey[400]
                                  : Colors.orange[400],
                          size: 20,
                        ),
                      ),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Delete Button
                  Column(
                    children: [
                      IconButton(
                        onPressed: _isUpdating ? null : widget.onRemove,
                        icon: Icon(
                          Icons.delete_outline,
                          color:
                              _isUpdating ? Colors.grey[400] : Colors.red[400],
                          size: 20,
                        ),
                      ),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity Selector
          Row(
            children: [
              Text(
                'Quantity:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          _selectedQuantity > 1 && !_isUpdating
                              ? () => _updateQuantity(_selectedQuantity - 1)
                              : null,
                      icon: const Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _selectedQuantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          !_isUpdating
                              ? () => _updateQuantity(_selectedQuantity + 1)
                              : null,
                      icon: const Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
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

  Widget _buildFallbackCartItemContent({bool showLoading = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (widget
                                  .item
                                  .product
                                  ?.productThumbnail
                                  ?.imageUrl
                                  .isNotEmpty ==
                              true)
                          ? CachedNetworkImage(
                            imageUrl:
                                widget
                                    .item
                                    .product!
                                    .productThumbnail
                                    ?.imageUrl ??
                                '',
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                  child: Icon(
                                    showLoading
                                        ? Icons.hourglass_empty
                                        : Icons.shopping_bag,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              showLoading
                                  ? Icons.hourglass_empty
                                  : Icons.shopping_bag,
                              color: Colors.grey,
                              size: 40,
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.product?.name ??
                          (widget.item.productId != null
                              ? 'Loading Product ${widget.item.productId}...'
                              : 'Cart Item ${widget.item.id}'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showLoading
                          ? 'Loading product details...'
                          : 'Product details unavailable',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle:
                            showLoading ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        Text(
                          ref.watch(currencyFormattingProvider)(
                            widget.item.product?.effectivePrice ??
                                widget.item.unitPrice,
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (widget.item.variationDisplayName != null ||
                            widget.item.selectedVariation != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              widget.item.variationDisplayName ??
                                  widget.item.selectedVariation ??
                                  '',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wishlist Button
                  Column(
                    children: [
                      IconButton(
                        onPressed:
                            _isUpdating ? null : () => _addToWishlist(context),
                        icon: Icon(
                          Icons.favorite_border,
                          color:
                              _isUpdating
                                  ? Colors.grey[400]
                                  : Colors.orange[400],
                          size: 20,
                        ),
                      ),
                      Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Delete Button
                  Column(
                    children: [
                      IconButton(
                        onPressed: _isUpdating ? null : widget.onRemove,
                        icon: Icon(
                          Icons.delete_outline,
                          color:
                              _isUpdating ? Colors.grey[400] : Colors.red[400],
                          size: 20,
                        ),
                      ),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity Selector
          Row(
            children: [
              Text(
                'Quantity:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed:
                          _selectedQuantity > 1 && !_isUpdating
                              ? () => _updateQuantity(_selectedQuantity - 1)
                              : null,
                      icon: const Icon(Icons.remove, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Container(
                      width: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _selectedQuantity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed:
                          !_isUpdating
                              ? () => _updateQuantity(_selectedQuantity + 1)
                              : null,
                      icon: const Icon(Icons.add, size: 16),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
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

  void _addToWishlist(BuildContext context) {
    if (widget.item.product == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => AddToWishlistDialog(product: widget.item.product!),
    );
  }
}
