import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/attribute_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/providers/product_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/cart_icon_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/add_to_cart_button.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/widgets/wishlist_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:flutter_riverpod_clean_architecture/features/home/providers/recently_viewed_provider.dart';

class ProductDetailsFromSearchScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailsFromSearchScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsFromSearchScreen> createState() =>
      _ProductDetailsFromSearchScreenState();
}

class _HtmlContent extends StatelessWidget {
  final String html;

  const _HtmlContent({required this.html});

  @override
  Widget build(BuildContext context) {
    final parsed = _parseHtml(html);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          parsed
              .map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: w,
                ),
              )
              .toList(),
    );
  }

  List<Widget> _parseHtml(String htmlString) {
    final document = html_parser.parse(htmlString);
    final widgets = <Widget>[];

    void processNode(html_dom.Node node) {
      if (node is html_dom.Element) {
        switch (node.localName) {
          case 'p':
            widgets.add(
              Text(
                node.text,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            );
            break;
          case 'strong':
          case 'b':
            widgets.add(
              Text(
                node.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
            );
            break;
          case 'em':
          case 'i':
            widgets.add(
              Text(
                node.text,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
            );
            break;
          case 'br':
            widgets.add(const SizedBox(height: 8));
            break;
          case 'ul':
            for (final li in node.children.where((c) => c.localName == 'li')) {
              widgets.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        li.text,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ),
                  ],
                ),
              );
            }
            break;
          case 'ol':
            int index = 1;
            for (final li in node.children.where((c) => c.localName == 'li')) {
              widgets.add(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${index++}. '),
                    Expanded(
                      child: Text(
                        li.text,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ),
                  ],
                ),
              );
            }
            break;
          case 'h1':
          case 'h2':
          case 'h3':
            widgets.add(
              Text(
                node.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                ),
              ),
            );
            break;
          default:
            for (final child in node.nodes) {
              processNode(child);
            }
        }
      } else if (node is html_dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) {
          widgets.add(
            Text(text, style: const TextStyle(fontSize: 14, height: 1.6)),
          );
        }
      }
    }

    for (final node in document.body?.nodes ?? []) {
      processNode(node);
    }

    return widgets;
  }
}

class _ProductDetailsFromSearchScreenState
    extends ConsumerState<ProductDetailsFromSearchScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  List<ProductVariationEntity> _selectedVariations = []; // Changed to array
  ProductEntity? _fullProduct;
  bool _isLoading = true;
  String? _errorMessage;

  // Track selected attribute values for each attribute
  Map<int, AttributeValueEntity> _selectedAttributeValues = {};

  @override
  void initState() {
    super.initState();
    _fetchFullProduct();
    // Track recently viewed
    Future.microtask(() {
      ref.read(recentlyViewedProvider.notifier).trackView(widget.product);
    });
  }

  Future<void> _fetchFullProduct() async {
    try {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.getProductBySlug(widget.product.slug);

      result.fold(
        (failure) {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (product) {
          print("############################");
          print(product.attributes);
          setState(() {
            _fullProduct = product;
            _isLoading = false;
            // Do not auto-select variation by default
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load product details';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchFullProduct,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _fullProduct ?? widget.product;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImageSection(product),
                  _buildProductInfoSection(product),
                  _buildRelatedProductsSection(),
                  _buildFullDescriptionSection(product),
                ],
              ),
            ),
          ),
          _buildBottomActionBar(product),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.product.name.length > 20
            ? '${widget.product.name.substring(0, 20)}...'
            : widget.product.name,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            context.push(AppConstants.searchRoute);
          },
        ),
        CartIconButton(
          iconColor: Theme.of(context).colorScheme.onSurface,
          badgeColor: Theme.of(context).colorScheme.primary,
        ),
        IconButton(
          icon: Icon(
            Icons.share,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => _shareProduct(),
        ),
      ],
    );
  }

  Widget _buildProductImageSection(ProductEntity product) {
    final images = _getProductImages(product);

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            return Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                placeholder:
                    (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
              ),
            );
          },
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enableInfiniteScroll: images.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentImageIndex == entry.key
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor,
                    ),
                  );
                }).toList(),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProductInfoSection(ProductEntity product) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 8),

            // Brand Name
            if (product.categories != null && product.categories!.isNotEmpty)
              Text(
                product.categories!.first.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            const SizedBox(height: 8),

            // Rating and Reviews
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_calculateAverageRating(product.reviewRatings).toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(product.reviewRatings?.fold(0, (sum, count) => sum + count) ?? 0)} REVIEWS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Variants Section - Only show if we have the full product with variations
            if (_fullProduct != null &&
                _fullProduct!.variations != null &&
                _fullProduct!.variations!.isNotEmpty) ...[
              _buildVariantsSection(_fullProduct!),
              const SizedBox(height: 16),
            ],

            // Price
            Text(
              ref.watch(currencyFormattingProvider)(
                _getSelectedVariationPrice(product),
              ),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Promise
            Row(
              children: [
                Text(
                  'We deliver nationwide.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  child: Text(
                    'T&Cs Apply',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onPressed: () {
                    _openTermsAndConditions();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Short Description
            if (product.shortDescription != null &&
                product.shortDescription!.isNotEmpty) ...[
              _buildExpandableDescription(product),
              const SizedBox(height: 24),
            ],

            // Additional Product Information
            _buildAdditionalProductInfo(product),

            // Reviews Section
            if (product.reviews != null && product.reviews!.isNotEmpty) ...[
              Text(
                'Customer Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...product.reviews!
                  .take(3)
                  .map(
                    (review) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                child: Text(
                                  (review.userName != null &&
                                          review.userName!.isNotEmpty)
                                      ? review.userName![0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userName ?? 'Anonymous',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < (review.rating ?? 0)
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: const Color(0xFFFFD700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (review.comment != null &&
                              review.comment!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              review.comment!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 100), // Extra space for bottom bar
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to find variation that matches selected attribute values
  ProductVariationEntity? _findMatchingVariation() {
    if (_fullProduct == null || _fullProduct!.variations == null) {
      return null;
    }

    // If no attributes selected, return null
    if (_selectedAttributeValues.isEmpty) {
      return null;
    }

    // Find variation that contains all selected attribute values
    for (final variation in _fullProduct!.variations!) {
      final variationAttributeValues = variation.attributeValues ?? [];

      // Check if this variation has all selected attribute values
      bool hasAllSelectedAttributes = true;

      for (final selectedEntry in _selectedAttributeValues.entries) {
        final found = variationAttributeValues.any(
          (attrValue) =>
              attrValue.attributeId == selectedEntry.key &&
              attrValue.value == selectedEntry.value.value,
        );

        if (!found) {
          hasAllSelectedAttributes = false;
          break;
        }
      }

      if (hasAllSelectedAttributes &&
          variationAttributeValues.length == _selectedAttributeValues.length) {
        return variation;
      }
    }

    return null;
  }

  // Get currently selected variation based on selected attributes
  ProductVariationEntity? get _selectedVariation {
    return _findMatchingVariation();
  }

  Widget _buildVariantsSection(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Variants',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        // Create a section for each attribute
        ...(product.attributes ?? []).map((attribute) {
          // Get attribute values for this attribute
          final attributeValues = _getAttributeValuesForAttribute(attribute);

          // Only show attribute section if it has values
          if (attributeValues.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attribute.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      attributeValues.map((attributeValue) {
                        final isSelected =
                            _selectedAttributeValues[attribute.id]?.id ==
                            attributeValue.id;
                        final hasColor = attributeValue.hexColor != null;

                        return _buildVariantChip(
                          attribute,
                          attributeValue,
                          isSelected,
                          hasColor,
                        );
                      }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  List<AttributeValueEntity> _getAttributeValuesForAttribute(
    AttributeEntity attribute,
  ) {
    if (_fullProduct == null || _fullProduct!.variations == null) {
      return [];
    }

    final values = <AttributeValueEntity>{};

    for (final variation in _fullProduct!.variations!) {
      final attributeValues = variation.attributeValues;
      if (attributeValues != null) {
        for (final attributeValue in attributeValues) {
          if (attributeValue.attributeId == attribute.id) {
            values.add(attributeValue);
          }
        }
      }
    }

    return values.toList();
  }

  Widget _buildVariantChip(
    AttributeEntity attribute,
    AttributeValueEntity attributeValue,
    bool isSelected,
    bool hasColor,
  ) {
    return GestureDetector(
      onTap: () => _selectAttributeValue(attribute, attributeValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color indicator if available
            if (hasColor) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _parseHexColor(attributeValue.hexColor!),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Attribute value
            Text(
              attributeValue.value ?? 'N/A',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(ProductEntity product) {
    final currentPrice = _getSelectedVariationPrice(product);
    final isInStock =
        ((_selectedVariation?.stockStatus ?? product.stockStatus) ?? '')
            .toLowerCase() ==
        'in_stock';

    // Check if product has variants but not all required attributes are selected
    final hasVariants =
        product.variations != null && product.variations!.isNotEmpty;
    final productAttributes = product.attributes ?? [];
    final hasRequiredAttributes = productAttributes.isNotEmpty;
    final allRequiredAttributesSelected =
        hasRequiredAttributes &&
        _selectedAttributeValues.length == productAttributes.length;

    final shouldDisableAddToCart =
        hasVariants && hasRequiredAttributes && !allRequiredAttributesSelected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Wishlist Button
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: WishlistButton(
                product: product,
                iconColor: Theme.of(context).colorScheme.onSurface,
                activeColor: Theme.of(context).colorScheme.error,
                iconSize: 24,
              ),
            ),
            const SizedBox(width: 10),

            // Price Display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Price:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    ref.watch(currencyFormattingProvider)(currentPrice),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Expanded(
              flex: 2,
              child:
                  isInStock
                      ? AddToCartButton(
                        product: _fullProduct ?? product,
                        selectedVariations: _selectedVariations,
                        selectedAttributes: _buildSelectedAttributesMap(),
                        quantity: 1,
                        isDisabled: shouldDisableAddToCart,
                        onAdded: () {
                          // Show success message or navigate to cart
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_selectedVariation?.name ?? product.name} added to cart',
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              action: SnackBarAction(
                                label: 'View Cart',
                                textColor: Colors.white,
                                onPressed:
                                    () => context.push(AppConstants.cartRoute),
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getProductImages(ProductEntity product) {
    final images = <String>[];

    // If a variant is selected and has an image, show that first
    if (_selectedVariation?.variationImage?.imageUrl != null &&
        _selectedVariation!.variationImage!.imageUrl!.isNotEmpty) {
      images.add(_selectedVariation!.variationImage!.imageUrl!);
    }

    // Add main product image (if not already added from variant)
    if (product.productThumbnail != null &&
        product.productThumbnail!.imageUrl.isNotEmpty) {
      images.add(product.productThumbnail!.imageUrl);
    }

    // Add gallery images
    for (final galleryImage in product.productGalleries) {
      if (galleryImage.imageUrl.isNotEmpty) {
        images.add(galleryImage.imageUrl);
      }
    }

    // Add other variant images (excluding the selected one)
    if (_fullProduct != null && _fullProduct!.variations != null) {
      for (final variation in _fullProduct!.variations!) {
        if (variation.variationImage?.imageUrl != null &&
            variation.variationImage!.imageUrl!.isNotEmpty &&
            variation.id != _selectedVariation?.id) {
          images.add(variation.variationImage!.imageUrl!);
        }
      }
    }

    // If no images, add a placeholder
    if (images.isEmpty) {
      images.add('https://via.placeholder.com/400x300?text=No+Image');
    }

    return images;
  }

  Widget _buildExpandableDescription(ProductEntity product) {
    const int maxLength = 150;
    final shortDescription = product.shortDescription;

    if (shortDescription == null || shortDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    final shouldTruncate = shortDescription.length > maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isDescriptionExpanded || !shouldTruncate
              ? shortDescription
              : '${shortDescription.substring(0, maxLength)}...',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
        if (shouldTruncate) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
            },
            child: Text(
              _isDescriptionExpanded ? 'See Less' : 'See More',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalProductInfo(ProductEntity product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              _buildInfoRow('SKU', product.sku ?? 'N/A'),
              _buildInfoRow(
                'Stock Status',
                (product.stockStatus ?? '').toUpperCase().replaceAll('_', ' '),
              ),
              if (product.weight != null)
                _buildInfoRow('Weight', '${product.weight} kg'),
              if (product.unit != null) _buildInfoRow('Unit', product.unit!),
              if (product.estimatedDeliveryText != null)
                _buildInfoRow('Delivery Info', product.estimatedDeliveryText!),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFullDescriptionSection(ProductEntity product) {
    final detailedDescription = product.description;

    if (detailedDescription == null || detailedDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: _HtmlContent(html: detailedDescription),
          ),
          const SizedBox(height: 100), // Extra space for bottom bar
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cache the provider to prevent unnecessary rebuilds
  late final _trendingProductsProvider = trendingProductsByCategoryIdsProvider({
    'categoryIds':
        _fullProduct != null
            ? (_fullProduct!.categories ?? [])
                .map((category) => category.id)
                .toList()
            : (widget.product.categories ?? [])
                .map((category) => category.id)
                .toList(),
    'limit': 10,
  });

  Widget _buildRelatedProductsSection() {
    // Watch the cached provider
    final trendingProductsAsync = ref.watch(_trendingProductsProvider);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Trending in This Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: trendingProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No trending products found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final relatedProduct = products[index];
                    return ProductCard(product: relatedProduct);
                  },
                );
              },
              loading:
                  () => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading trending products...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
              error:
                  (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load trending products',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Please try again later',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 100), // Extra space for bottom bar
        ],
      ),
    );
  }

  void _selectAttributeValue(
    AttributeEntity attribute,
    AttributeValueEntity attributeValue,
  ) {
    setState(() {
      if (_selectedAttributeValues[attribute.id]?.id == attributeValue.id) {
        // Deselect if already selected
        _selectedAttributeValues.remove(attribute.id);
      } else {
        // Select new value for this attribute
        _selectedAttributeValues[attribute.id] = attributeValue;
      }

      // Find matching variation based on selected attributes
      final matchingVariation = _findMatchingVariation();
      if (matchingVariation != null) {
        // Remove any existing variation and add the new one
        _selectedVariations = [matchingVariation];
        _currentImageIndex = 0; // Reset to first image when variant changes
      } else {
        _selectedVariations.clear();
      }
    });
  }

  // Build a map of selected attributes for cart
  Map<String, String>? _buildSelectedAttributesMap() {
    if (_selectedAttributeValues.isEmpty) return null;

    final Map<String, String> attributes = {};
    for (final entry in _selectedAttributeValues.entries) {
      attributes[entry.key.toString()] = entry.value.value ?? '';
    }
    return attributes;
  }

  /// Get the effective price for the selected variation or fallback to product price
  double _getSelectedVariationPrice(ProductEntity product) {
    if (_selectedVariation != null) {
      // Use salePrice if available and greater than 0, otherwise use regular price
      return _selectedVariation!.salePrice != null &&
              _selectedVariation!.salePrice! > 0
          ? _selectedVariation!.salePrice!
          : (_selectedVariation!.price ?? 0.0);
    }
    return product.effectivePrice;
  }

  Color _parseHexColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  double _calculateAverageRating(List<int>? ratings) {
    if (ratings == null || ratings.isEmpty) return 0.0;
    final totalRatings = ratings.asMap().entries.fold(0, (sum, entry) {
      // entry.key + 1 is the star rating (1-5)
      // entry.value is the count of ratings for that star
      return sum + (entry.value * (entry.key + 1));
    });

    final numberOfRatings = ratings.fold(0, (sum, count) => sum + count);
    return numberOfRatings > 0 ? totalRatings / numberOfRatings : 0.0;
  }

  /// Share product using product slug
  Future<void> _shareProduct() async {
    try {
      final productUrl =
          'https://raines.africa/en/product/${widget.product.slug}';
      final shareText =
          'Check out this amazing product: ${widget.product.name}\n\n$productUrl';

      await Share.share(
        shareText,
        subject: '${widget.product.name} - Raines Africa',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to share product: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open Terms & Conditions in browser
  Future<void> _openTermsAndConditions() async {
    try {
      const termsUrl = 'https://raines.africa/en/pages/terms-and-conditions';
      final uri = Uri.parse(termsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open Terms & Conditions'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Terms & Conditions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
