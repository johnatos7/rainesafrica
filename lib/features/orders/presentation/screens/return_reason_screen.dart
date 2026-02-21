import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_product_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_reason_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/return_api_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnReasonScreen extends ConsumerStatefulWidget {
  final int orderId;
  final OrderProductEntity product;

  const ReturnReasonScreen({
    super.key,
    required this.orderId,
    required this.product,
  });

  @override
  ConsumerState<ReturnReasonScreen> createState() => _ReturnReasonScreenState();
}

class _ReturnReasonScreenState extends ConsumerState<ReturnReasonScreen> {
  ReturnReasonEntity? _selectedReason;
  SubReasonEntity? _selectedSubReason;
  PreferredOutcomeEntity? _selectedPreferredOutcome;
  final _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSubmitting = false;
  bool _productNotUsed = false;
  bool _inOriginalPackaging = false;
  bool _includeAllAccessories = false;

  // Static data matching the provided JSON structure
  final List<ReturnReasonEntity> _returnReasons = [
    ReturnReasonEntity(
      reasonId: "11",
      title: "Product no longer wanted",
      preferredOutcomes: [
        PreferredOutcomeEntity(
          outcomeId: "refund",
          title: "Refund to original payment method",
        ),
        PreferredOutcomeEntity(
          outcomeId: "credit",
          title: "Credit my Raines Africa account",
        ),
      ],
      subReasons: [
        SubReasonEntity(subReasonId: 39, title: "Product arrived too late"),
        SubReasonEntity(subReasonId: 40, title: "Found a better price"),
        SubReasonEntity(subReasonId: 41, title: "Unwanted gift"),
        SubReasonEntity(
          subReasonId: 42,
          title: "I purchased the wrong product or quantity",
        ),
        SubReasonEntity(subReasonId: 44, title: "Changed my mind"),
      ],
    ),
    ReturnReasonEntity(
      reasonId: "14",
      title: "Wrong product delivered",
      preferredOutcomes: [
        PreferredOutcomeEntity(
          outcomeId: "refund",
          title: "Refund to original payment method",
        ),
        PreferredOutcomeEntity(outcomeId: "replacement", title: "Replace item"),
        PreferredOutcomeEntity(
          outcomeId: "credit",
          title: "Credit my Raines Africa account",
        ),
      ],
      subReasons: [
        SubReasonEntity(subReasonId: 45, title: "Wrong size or colour"),
        SubReasonEntity(subReasonId: 46, title: "Completely wrong product"),
        SubReasonEntity(
          subReasonId: 47,
          title: "Incorrect brand of product received",
        ),
      ],
    ),
    ReturnReasonEntity(
      reasonId: "13",
      title: "Missing parts or accessories",
      preferredOutcomes: [
        PreferredOutcomeEntity(
          outcomeId: "refund",
          title: "Refund to original payment method",
        ),
        PreferredOutcomeEntity(outcomeId: "replacement", title: "Replace item"),
        PreferredOutcomeEntity(
          outcomeId: "credit",
          title: "Credit my Raines Africa account",
        ),
      ],
    ),
    ReturnReasonEntity(
      reasonId: "12",
      title: "Description on website not accurate",
      preferredOutcomes: [
        PreferredOutcomeEntity(
          outcomeId: "refund",
          title: "Refund to original payment method",
        ),
        PreferredOutcomeEntity(outcomeId: "replacement", title: "Replace item"),
        PreferredOutcomeEntity(
          outcomeId: "credit",
          title: "Credit my Raines Africa account",
        ),
      ],
    ),
    ReturnReasonEntity(
      reasonId: "16",
      title: "Product delivered in a poor or damaged condition",
      preferredOutcomes: [
        PreferredOutcomeEntity(
          outcomeId: "refund",
          title: "Refund to original payment method",
        ),
        PreferredOutcomeEntity(outcomeId: "replacement", title: "Replace item"),
        PreferredOutcomeEntity(
          outcomeId: "credit",
          title: "Credit my Raines Africa account",
        ),
      ],
      subReasons: [
        SubReasonEntity(subReasonId: 48, title: "Product is dirty/dusty"),
        SubReasonEntity(
          subReasonId: 49,
          title: "Product and delivery box damaged",
        ),
        SubReasonEntity(
          subReasonId: 50,
          title: "Product damaged but delivery box undamaged",
        ),
        SubReasonEntity(subReasonId: 51, title: "Product appears used"),
        SubReasonEntity(subReasonId: 52, title: "Product expired"),
      ],
    ),
    ReturnReasonEntity(
      reasonId: "15",
      title: "Product is defective or does not work",
      preferredOutcomes: [
        PreferredOutcomeEntity(
          outcomeId: "refund",
          title: "Refund to original payment method",
        ),
        PreferredOutcomeEntity(outcomeId: "replacement", title: "Replace item"),
        PreferredOutcomeEntity(
          outcomeId: "credit",
          title: "Credit my Raines Africa account",
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {
        // This will trigger a rebuild when description text changes
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNextSection() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        double scrollPosition;

        if (_selectedReason != null &&
            _selectedSubReason == null &&
            _selectedPreferredOutcome == null) {
          // If reason is selected but no sub-reason, scroll to sub-reason section
          scrollPosition = _scrollController.position.maxScrollExtent * 0.3;
        } else if (_selectedReason != null &&
            _selectedSubReason != null &&
            _selectedPreferredOutcome == null) {
          // If sub-reason is selected, scroll to preferred outcome section
          scrollPosition = _scrollController.position.maxScrollExtent * 0.5;
        } else if (_selectedPreferredOutcome != null) {
          // If preferred outcome is selected, scroll to description section
          scrollPosition = _scrollController.position.maxScrollExtent * 0.7;
        } else {
          // Default scroll position
          scrollPosition = _scrollController.position.maxScrollExtent * 0.4;
        }

        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Return Request',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            _buildProductInfoCard(theme, colors),
            const SizedBox(height: 20),

            // Return Reason Selection
            _buildReturnReasonSection(theme, colors),
            const SizedBox(height: 20),

            // Sub Reason Selection (if available)
            if (_selectedReason?.subReasons != null &&
                _selectedReason!.subReasons!.isNotEmpty)
              _buildSubReasonSection(theme, colors),
            if (_selectedReason?.subReasons != null &&
                _selectedReason!.subReasons!.isNotEmpty)
              const SizedBox(height: 20),

            // Preferred Outcome Selection
            _buildPreferredOutcomeSection(theme, colors),
            const SizedBox(height: 20),

            // Description
            _buildDescriptionSection(theme, colors),
            const SizedBox(height: 20),

            // Product Condition Options
            _buildProductConditionSection(theme, colors),
            const SizedBox(height: 20),

            // Return Policy Notice
            _buildReturnPolicyNotice(theme, colors),
            const SizedBox(height: 20),

            // Submit Button
            _buildSubmitButton(theme, colors),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnPolicyNotice(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Important Notice',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please note: When we receive your product, we will inspect it. Only unused products in their original packaging will be accepted, else the product may be returned to you.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap:
                () => _openUrl('https://raines.africa/en/pages/return-policy'),
            child: Text(
              'View our Returns Policy',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    );
  }

  Widget _buildProductInfoCard(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      widget.product.productThumbnail != null
                          ? Image.network(
                            widget.product.productThumbnail!.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.image_outlined,
                                color: colors.onSurface.withOpacity(0.4),
                                size: 24,
                              );
                            },
                          )
                          : Icon(
                            Icons.image_outlined,
                            color: colors.onSurface.withOpacity(0.4),
                            size: 24,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${widget.product.pivot.quantity}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
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

  Widget _buildReturnReasonSection(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Return Reason',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...(_returnReasons.map(
            (reason) => _buildReasonTile(reason, theme, colors),
          )),
        ],
      ),
    );
  }

  Widget _buildReasonTile(
    ReturnReasonEntity reason,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final isSelected = _selectedReason?.reasonId == reason.reasonId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedReason = reason;
            _selectedSubReason = null;
            _selectedPreferredOutcome = null;
          });
          _scrollToNextSection();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colors.primary.withOpacity(0.1)
                    : colors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
                      ? colors.primary.withOpacity(0.3)
                      : colors.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    isSelected
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reason.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubReasonSection(ThemeData theme, ColorScheme colors) {
    if (_selectedReason?.subReasons == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Specific Issue',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...(_selectedReason!.subReasons!.map(
            (subReason) => _buildSubReasonTile(subReason, theme, colors),
          )),
        ],
      ),
    );
  }

  Widget _buildSubReasonTile(
    SubReasonEntity subReason,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final isSelected = _selectedSubReason?.subReasonId == subReason.subReasonId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSubReason = subReason;
          });
          _scrollToNextSection();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colors.primary.withOpacity(0.1)
                    : colors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
                      ? colors.primary.withOpacity(0.3)
                      : colors.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    isSelected
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subReason.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferredOutcomeSection(ThemeData theme, ColorScheme colors) {
    if (_selectedReason == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferred Outcome',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...(_selectedReason!.preferredOutcomes.map(
            (outcome) => _buildOutcomeTile(outcome, theme, colors),
          )),
        ],
      ),
    );
  }

  Widget _buildOutcomeTile(
    PreferredOutcomeEntity outcome,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final isSelected =
        _selectedPreferredOutcome?.outcomeId == outcome.outcomeId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPreferredOutcome = outcome;
          });
          _scrollToNextSection();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? colors.primary.withOpacity(0.1)
                    : colors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected
                      ? colors.primary.withOpacity(0.3)
                      : colors.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    isSelected
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.6),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  outcome.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Please provide more details about the issue...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductConditionSection(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Condition',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please confirm the condition of the product you are returning:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            'Product has not been used',
            _productNotUsed,
            (value) => setState(() => _productNotUsed = value ?? false),
            theme,
            colors,
          ),
          _buildCheckboxTile(
            'Product is in original packaging',
            _inOriginalPackaging,
            (value) => setState(() => _inOriginalPackaging = value ?? false),
            theme,
            colors,
          ),
          _buildCheckboxTile(
            'All accessories are included',
            _includeAllAccessories,
            (value) => setState(() => _includeAllAccessories = value ?? false),
            theme,
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    Function(bool?) onChanged,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, ColorScheme colors) {
    final canSubmit =
        _selectedReason != null &&
        _selectedPreferredOutcome != null &&
        _descriptionController.text.trim().isNotEmpty &&
        (_productNotUsed || _inOriginalPackaging || _includeAllAccessories);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (canSubmit && !_isSubmitting) ? _submitReturn : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child:
            _isSubmitting
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.onSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Submitting...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Submit Return Request',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }

  Future<void> _submitReturn() async {
    if (_selectedReason == null || _selectedPreferredOutcome == null) return;

    // Validate description
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide a description for your return request'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate product condition
    if (!_productNotUsed && !_inOriginalPackaging && !_includeAllAccessories) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one product condition option'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare the payload
      final payload = {
        "order_id": widget.orderId,
        "product_id": widget.product.id,
        "return_reason": _selectedReason!.title,
        "sub_reason": _selectedSubReason?.title ?? "",
        "description": _descriptionController.text.trim(),
        "preferred_outcome": _selectedPreferredOutcome!.outcomeId,
        "product_not_used": _productNotUsed,
        "in_original_packaging": _inOriginalPackaging,
        "include_all_accessories": _includeAllAccessories,
      };

      // Make API call
      final secureStorage = ref.read(secureStorageProvider);
      final apiService = ReturnApiService(secureStorage: secureStorage);
      final response = await apiService.submitReturnRequest(payload);

      if (response['success'] == true) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Return request submitted successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        // Handle API error
        _handleApiError(response);
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit return request. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleApiError(Map<String, dynamic> response) {
    String errorMessage = 'Failed to submit return request';

    if (response.containsKey('message')) {
      errorMessage = response['message'];
    } else if (response.containsKey('error')) {
      errorMessage = response['error'];
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
