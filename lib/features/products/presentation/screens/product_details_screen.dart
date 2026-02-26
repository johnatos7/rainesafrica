import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/responsive_utils.dart';
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
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_eligibility_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/providers/recently_viewed_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/data/models/product_model.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _HtmlContent extends StatelessWidget {
  final String html;

  const _HtmlContent({required this.html});

  @override
  Widget build(BuildContext context) {
    final parsed = _parseHtml(html, context);

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

  List<Widget> _parseHtml(String htmlString, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textColor = colors.onSurface;
    final document = html_parser.parse(htmlString);
    final widgets = <Widget>[];

    void processNode(html_dom.Node node) {
      if (node is html_dom.Element) {
        switch (node.localName) {
          case 'p':
            widgets.add(
              Text(
                node.text,
                style: TextStyle(fontSize: 14, height: 1.6, color: textColor),
              ),
            );
            break;
          case 'strong':
          case 'b':
            widgets.add(
              Text(
                node.text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            );
            break;
          case 'em':
          case 'i':
            widgets.add(
              Text(
                node.text,
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: textColor,
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
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: textColor,
                        ),
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
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: textColor,
                        ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                  color: textColor,
                ),
              ),
            );
            break;
          case 'img':
            final src = node.attributes['src'] ?? '';
            if (src.isNotEmpty) {
              widgets.add(
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    src,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              );
            }
            break;
          case 'figure':
            for (final child in node.nodes) {
              processNode(child);
            }
            break;
          case 'table':
            widgets.add(_buildTable(node, context));
            break;
          case 'div':
          case 'span':
          case 'section':
          case 'article':
          case 'header':
          case 'footer':
          case 'main':
          case 'aside':
          case 'nav':
          case 'a':
            for (final child in node.nodes) {
              processNode(child);
            }
            break;
          default:
            // For any unrecognized element, try to extract text
            final text = node.text.trim();
            if (text.isNotEmpty) {
              widgets.add(
                Text(
                  text,
                  style: TextStyle(fontSize: 14, height: 1.6, color: textColor),
                ),
              );
            }
        }
      } else if (node is html_dom.Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) {
          widgets.add(
            Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.6, color: textColor),
            ),
          );
        }
      }
    }

    for (final node in document.body?.nodes ?? []) {
      processNode(node);
    }

    return widgets;
  }

  Widget _buildTable(html_dom.Element tableNode, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rows = <TableRow>[];

    // Collect all rows from thead, tbody, tfoot, or direct tr children
    final allTrs = <html_dom.Element>[];
    for (final section in tableNode.children) {
      if (section.localName == 'thead' ||
          section.localName == 'tbody' ||
          section.localName == 'tfoot') {
        allTrs.addAll(section.children.where((c) => c.localName == 'tr'));
      } else if (section.localName == 'tr') {
        allTrs.add(section);
      }
    }

    if (allTrs.isEmpty) return const SizedBox.shrink();

    // Determine maximum column count across all rows
    int maxCols = 0;
    for (final tr in allTrs) {
      final cellCount =
          tr.children
              .where((c) => c.localName == 'th' || c.localName == 'td')
              .length;
      if (cellCount > maxCols) maxCols = cellCount;
    }

    if (maxCols == 0) return const SizedBox.shrink();

    for (int i = 0; i < allTrs.length; i++) {
      final tr = allTrs[i];
      final cells =
          tr.children
              .where((c) => c.localName == 'th' || c.localName == 'td')
              .toList();

      final isHeader = cells.any((c) => c.localName == 'th');
      final bgColor =
          isHeader
              ? colors.primary
              : (i % 2 == 0 ? colors.surfaceContainerLow : colors.surface);

      // Pad cells to match maxCols if needed
      final paddedCells = <Widget>[];
      for (int j = 0; j < maxCols; j++) {
        if (j < cells.length) {
          final cell = cells[j];
          final isBold = isHeader || cell.querySelector('strong') != null;
          paddedCells.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                cell.text.trim(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: isHeader ? colors.onPrimary : colors.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          );
        } else {
          // Empty cell for padding
          paddedCells.add(const SizedBox.shrink());
        }
      }

      rows.add(
        TableRow(
          decoration: BoxDecoration(color: bgColor),
          children: paddedCells,
        ),
      );
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    // Generate dynamic column widths based on column count
    final columnWidths = <int, TableColumnWidth>{};
    for (int i = 0; i < maxCols; i++) {
      columnWidths[i] = const FlexColumnWidth(1);
    }

    final table = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Table(
        border: TableBorder.all(
          color: colors.outline.withOpacity(0.2),
          width: 0.5,
        ),
        columnWidths: columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows,
      ),
    );

    // Wrap in horizontal scroll for wide tables (3+ columns)
    if (maxCols > 2) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 500),
          child: table,
        ),
      );
    }

    return table;
  }
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _isSpecsExpanded = false;
  List<ProductVariationEntity> _selectedVariations = []; // Changed to array
  ProductEntity? _fullProduct;
  bool _isLoading = true;
  String? _errorMessage;

  // Recommendations
  List<ProductEntity> _relatedProducts = [];
  List<ProductEntity> _topRatedProducts = [];
  List<ProductEntity> _latestProducts = [];

  // Track selected attribute values for each attribute
  Map<int, AttributeValueEntity> _selectedAttributeValues = {};

  @override
  void initState() {
    super.initState();
    _fetchFullProduct();
    _fetchRecommendations();
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

  Future<void> _fetchRecommendations() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        '/api/product/recommendations/${widget.product.id}',
      );
      print('Recommendations API response: $response');
      if (response != null &&
          response is Map<String, dynamic> &&
          response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;

        List<ProductEntity> parseProducts(String key) {
          final list = data[key] as List<dynamic>? ?? [];
          return list
              .map(
                (json) =>
                    ProductModel.fromJson(
                      json as Map<String, dynamic>,
                    ).toEntity(),
              )
              .toList();
        }

        if (mounted) {
          setState(() {
            _relatedProducts = parseProducts('related_products');
            _topRatedProducts = parseProducts('top_rated');
            _latestProducts = parseProducts('latest');
          });
          print(
            'Recommendations loaded: related=${_relatedProducts.length}, topRated=${_topRatedProducts.length}, latest=${_latestProducts.length}',
          );
        }
      } else {
        print('Recommendations API returned unexpected response: $response');
      }
    } catch (e, stackTrace) {
      print('Failed to fetch recommendations: $e');
      print('Stack trace: $stackTrace');
    }
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
                  _buildProductDescriptionSection(product),
                  if (_latestProducts.isNotEmpty)
                    _buildRecommendationSection(
                      'Latest Products',
                      _latestProducts,
                    ),
                  _buildProductSpecificationsSection(product),
                  if (_topRatedProducts.isNotEmpty)
                    _buildRecommendationSection(
                      'Top Rated Products',
                      _topRatedProducts,
                    ),
                  _buildRelatedProductsSection(),
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
    final imageHeight = ResponsiveUtils.productDetailImageHeight(context);

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: images.length,
          itemBuilder: (context, index, realIndex) {
            return Container(
              width: double.infinity,
              height: imageHeight,
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
            height: imageHeight,
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
            Builder(
              builder: (context) {
                final ratings = product.reviewRatings;
                final totalReviews =
                    (ratings != null && ratings.isNotEmpty)
                        ? ratings.fold(0, (sum, count) => sum + count)
                        : 0;
                final avgRating =
                    totalReviews > 0
                        ? ratings!.asMap().entries.fold(
                              0,
                              (sum, entry) =>
                                  sum + (entry.value * (entry.key + 1)),
                            ) /
                            totalReviews
                        : 0.0;
                if (totalReviews == 0) return const SizedBox.shrink();
                return Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFD700), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalReviews REVIEWS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                );
              },
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
            if (product.isOnSale) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    ref.watch(currencyFormattingProvider)(
                      _getSelectedVariationPrice(product),
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ref.watch(currencyFormattingProvider)(product.price),
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (product.discountPercentage > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage.round()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ] else ...[
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
            ],
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

            // Short Description (rendered as HTML)
            if (product.shortDescription != null &&
                product.shortDescription!.isNotEmpty) ...[
              Text(
                'Short Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              _buildExpandableDescription(product),
              const SizedBox(height: 24),
            ],

            // Additional Product Information
            _buildAdditionalProductInfo(product),

            // Layby Eligibility Section
            LaybyEligibilityWidget(
              productId: product.id,
              variationId: _selectedVariation?.id,
              productPrice: _getSelectedVariationPrice(product),
              hasVariants:
                  _fullProduct?.variations != null &&
                  _fullProduct!.variations!.isNotEmpty,
              isVariantSelected: _selectedVariation != null,
            ),

            const SizedBox(height: 100), // Extra space for bottom bar
          ],
        ),
      ),
    );
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
      for (final attributeValue in variation.attributeValues ?? []) {
        if (attributeValue.attributeId == attribute.id) {
          values.add(attributeValue);
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
    final shortDescription = product.shortDescription;
    if (shortDescription == null || shortDescription.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert plain text \r\n to <br> for HTML rendering
    final htmlContent = shortDescription
        .replaceAll('\r\n', '<br>')
        .replaceAll('\n', '<br>');

    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: ClipRect(
            child: SizedBox(
              height: 120,
              child: _HtmlContent(html: htmlContent),
            ),
          ),
          secondChild: _HtmlContent(html: htmlContent),
          crossFadeState:
              _isDescriptionExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (!_isDescriptionExpanded)
          Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton(
            onPressed:
                () => setState(
                  () => _isDescriptionExpanded = !_isDescriptionExpanded,
                ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colors.outline.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            ),
            child: Text(
              _isDescriptionExpanded ? 'Show Less' : 'Show More',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
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
            ],
          ),
        ),

        // Delivery, Warranty & Return Policy badges (Takealot-style)
        if (product.estimatedDeliveryText != null ||
            product.warranty != null ||
            product.returnPolicyText != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                // Delivery badge
                if (product.estimatedDeliveryText != null) ...[
                  _buildPolicyRow(
                    icon: Icons.local_shipping_outlined,
                    text: product.estimatedDeliveryText!,
                    onInfoTap:
                        product.estimatedDeliveryText!.toLowerCase().contains(
                              'back order',
                            )
                            ? () => _showBackOrderNotice(context)
                            : null,
                  ),
                ],
                // Free shipping badge
                if (product.isFreeShipping == true) ...[
                  if (product.estimatedDeliveryText != null)
                    _buildDashedDivider(),
                  _buildPolicyRow(
                    icon: Icons.local_shipping,
                    text: 'Free Delivery Available.',
                  ),
                ],
                // Returns badge
                if (product.returnPolicyText != null ||
                    product.isReturn == true) ...[
                  if (product.estimatedDeliveryText != null ||
                      product.isFreeShipping == true)
                    _buildDashedDivider(),
                  _buildPolicyRow(
                    icon: Icons.swap_horiz,
                    text:
                        product.returnPolicyText ??
                        'Hassle-Free Exchanges & Returns for 30 Days.',
                    onInfoTap: () => _showReturnPolicy(context),
                  ),
                ],
                // Warranty badge
                if (product.warranty != null) ...[
                  if (product.estimatedDeliveryText != null ||
                      product.isFreeShipping == true ||
                      product.returnPolicyText != null ||
                      product.isReturn == true)
                    _buildDashedDivider(),
                  _buildPolicyRow(
                    icon: Icons.calendar_today,
                    text: product.warranty!,
                    onInfoTap:
                        () => _showWarrantyInfo(context, product.warranty!),
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  // ─── Product Description Section (with Show More/Less) ───
  Widget _buildProductDescriptionSection(ProductEntity product) {
    final detailedDescription = product.description;
    final hasDescription =
        detailedDescription != null && detailedDescription.isNotEmpty;
    if (!hasDescription) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: ClipRect(
              child: SizedBox(
                height: 200,
                child: _HtmlContent(html: detailedDescription!),
              ),
            ),
            secondChild: _HtmlContent(html: detailedDescription!),
            crossFadeState:
                _isDescriptionExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (!_isDescriptionExpanded)
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton(
              onPressed:
                  () => setState(
                    () => _isDescriptionExpanded = !_isDescriptionExpanded,
                  ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.outline.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 10,
                ),
              ),
              child: Text(
                _isDescriptionExpanded ? 'Show Less' : 'Show More',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Specifications Section ───
  Widget _buildProductSpecificationsSection(ProductEntity product) {
    final specifications = product.specifications;
    final hasSpecifications =
        specifications != null && specifications.isNotEmpty;
    if (!hasSpecifications) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: ClipRect(
              child: SizedBox(
                height: 200,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: _HtmlContent(html: specifications!),
                ),
              ),
            ),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: _HtmlContent(html: specifications!),
            ),
            crossFadeState:
                _isSpecsExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (!_isSpecsExpanded)
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton(
              onPressed:
                  () => setState(() => _isSpecsExpanded = !_isSpecsExpanded),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.outline.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 10,
                ),
              ),
              child: Text(
                _isSpecsExpanded ? 'Show Less' : 'Show More Specifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recommendation Product Section ───
  Widget _buildRecommendationSection(
    String title,
    List<ProductEntity> products,
  ) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: ResponsiveUtils.productSectionHeight(context),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            ),
          ),
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

  Widget _buildPolicyRow({
    required IconData icon,
    required String text,
    VoidCallback? onInfoTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurface.withOpacity(0.5), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.onSurface.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          if (onInfoTap != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onInfoTap,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashWidth = 5.0;
          final dashSpace = 4.0;
          final dashCount =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.4),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildRelatedProductsSection() {
    if (_relatedProducts.isEmpty) {
      return const SizedBox(height: 100); // Just bottom spacer
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Related Products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: ResponsiveUtils.productSectionHeight(context),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _relatedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: _relatedProducts[index]);
              },
            ),
          ),
          const SizedBox(height: 100), // Extra space for bottom bar
        ],
      ),
    );
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
  void _showBackOrderNotice(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade700,
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Back Order Notice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'Products on back order may experience prolonged delays because suppliers might need to order from their own suppliers, which may delay delivery up to 3 weeks. Availability cannot be guaranteed as we rely solely on data from suppliers.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showWarrantyInfo(BuildContext context, String warrantyText) {
    final isNonReturnable =
        warrantyText.toLowerCase().contains('non-returnable') ||
        warrantyText.toLowerCase().contains('non returnable');

    final String dialogTitle;
    final String dialogContent;
    final IconData dialogIcon;
    final Color dialogIconColor;

    if (isNonReturnable) {
      dialogTitle = 'Non-Returnable';
      dialogContent =
          'This product is non-returnable. Once purchased, it cannot be returned or exchanged. Please review the product details carefully before purchasing.';
      dialogIcon = Icons.block;
      dialogIconColor = const Color(0xFFD32F2F);
    } else {
      // Extract month count from warranty text (e.g. "6 Months Warranty" -> "6-Months")
      final monthMatch = RegExp(r'(\d+)').firstMatch(warrantyText);
      final months = monthMatch?.group(1) ?? '6';
      dialogTitle = '$months-Months Limited Warranty';
      dialogContent =
          'Limited warranty, with certain exclusions, as defined by the manufacturer. Please consult the manufacturer for further details.';
      dialogIcon = Icons.verified_user;
      dialogIconColor = const Color(0xFF1565C0);
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(dialogIcon, color: dialogIconColor, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dialogTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              dialogContent,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  void _showReturnPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: const Color(0xFF4CAF50),
                  size: 28,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Return Policy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Goods may be returned in terms of the Consumer Protection Act, Act 68 of 2008.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '\u2022 You may cancel any online sale within 5 days after receipt of goods for a full refund.\n\n'
                    '\u2022 Defective goods may be returned within 6 months of delivery for repair, replacement, or refund.\n\n'
                    '\u2022 A handling fee of up to 20% may apply if goods/packaging are not in original condition.\n\n'
                    '\u2022 Non-returnable items include: personalised products, assembled flat-pack furniture, licensed software, pre-paid cards, intimate products, toiletries, and foodstuff.\n\n'
                    '\u2022 Raines Africa reserves the right to inspect goods before approving a return.',
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _openReturnPolicyPage();
                      },
                      child: const Text(
                        'View Full Return Policy \u2192',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _openReturnPolicyPage() async {
    try {
      const url = 'https://raines.africa/en/pages/return-policy';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

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
