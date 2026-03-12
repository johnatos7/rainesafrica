import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/providers/layby_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

/// Multi-step Layby application screen.
///
/// **Redesigned 2-step flow:**
/// - Step 1: Choose plan (duration) and review payment breakdown
/// - Step 2: Review & submit (no document required)
///
/// Document upload is optional and can be done later from the details screen.
class LaybyApplicationScreen extends ConsumerStatefulWidget {
  final int productId;
  final int? variationId;
  final LaybyEligibility eligibility;
  final double productPrice;

  const LaybyApplicationScreen({
    super.key,
    required this.productId,
    this.variationId,
    required this.eligibility,
    required this.productPrice,
  });

  @override
  ConsumerState<LaybyApplicationScreen> createState() =>
      _LaybyApplicationScreenState();
}

class _LaybyApplicationScreenState
    extends ConsumerState<LaybyApplicationScreen> {
  int _currentStep = 0;
  int? _selectedDuration;
  bool _agreedToTerms = false;

  // Computed payment values
  double get _deposit =>
      widget.productPrice * widget.eligibility.depositPercentage / 100;

  double get _monthlyPayment {
    if (_selectedDuration == null || _selectedDuration! <= 0) return 0;
    return (widget.productPrice - _deposit) / _selectedDuration!;
  }

  double get _totalAmount => widget.productPrice;

  @override
  void initState() {
    super.initState();
    final durations = widget.eligibility.availableDurations;
    // Default to first available duration
    if (durations.isNotEmpty) {
      _selectedDuration = durations.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final laybyState = ref.watch(laybyNotifierProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          'Apply for Layby',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(colors),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child:
                  _currentStep == 0
                      ? _buildPlanSelectionStep(colors)
                      : _buildReviewStep(colors),
            ),
          ),

          // Bottom action bar
          _buildBottomBar(colors, laybyState),
        ],
      ),
    );
  }

  // ─── Step Indicator ───

  Widget _buildStepIndicator(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          _buildStepDot(0, 'Choose Plan', colors),
          Expanded(
            child: Container(
              height: 2,
              color:
                  _currentStep >= 1
                      ? colors.primary
                      : colors.onSurface.withOpacity(0.15),
            ),
          ),
          _buildStepDot(1, 'Review & Submit', colors),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label, ColorScheme colors) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colors.primary : colors.surfaceVariant,
            border: Border.all(
              color:
                  isActive ? colors.primary : colors.onSurface.withOpacity(0.2),
              width: 2,
            ),
          ),
          child: Center(
            child:
                isActive && _currentStep > step
                    ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                    : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color:
                            isActive
                                ? colors.onPrimary
                                : colors.onSurface.withOpacity(0.5),
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color:
                isActive ? colors.primary : colors.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // ─── Step 1: Plan Selection ───

  Widget _buildPlanSelectionStep(ColorScheme colors) {
    final formatCurrency = ref.watch(currencyFormattingProvider);
    final durations = widget.eligibility.availableDurations;

    // If sale product, limit to first duration
    final availableDurations =
        widget.eligibility.isSaleProduct ? [durations.first] : durations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product price card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Text(
                'Product Price',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency(widget.productPrice),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Duration selection
        Text(
          'Select Payment Plan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose how many months you\'d like to pay over',
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 12),

        ...availableDurations.map(
          (months) => _buildDurationOption(months, colors, formatCurrency),
        ),

        if (widget.eligibility.isSaleProduct) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a sale product. Only the ${durations.first}-month plan is available.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Payment breakdown
        if (_selectedDuration != null)
          _buildPaymentBreakdown(colors, formatCurrency),
      ],
    );
  }

  Widget _buildDurationOption(
    int months,
    ColorScheme colors,
    String Function(double) formatCurrency,
  ) {
    final isSelected = _selectedDuration == months;
    final monthly = (widget.productPrice - _deposit) / months;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedDuration = months),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                isSelected ? colors.primary.withOpacity(0.08) : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primary : colors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colors.primary : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected
                            ? colors.primary
                            : colors.onSurface.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 14),

              // Duration label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$months months',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      '${formatCurrency(monthly)} / month',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Right-aligned info
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentBreakdown(
    ColorScheme colors,
    String Function(double) formatCurrency,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          _buildBreakdownRow(
            'Deposit (${widget.eligibility.depositPercentage}%)',
            formatCurrency(_deposit),
            colors,
          ),
          _buildBreakdownRow(
            'Monthly Payment',
            formatCurrency(_monthlyPayment),
            colors,
          ),
          _buildBreakdownRow('Duration', '$_selectedDuration months', colors),
          const Divider(height: 20),
          _buildBreakdownRow(
            'Total',
            formatCurrency(_totalAmount),
            colors,
            isBold: true,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  '0% Interest — You only pay the product price',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    ColorScheme colors, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
              color: colors.onSurface.withOpacity(isBold ? 1 : 0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? colors.primary : colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step 2: Review & Submit ───

  Widget _buildReviewStep(ColorScheme colors) {
    final formatCurrency = ref.watch(currencyFormattingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(
                'Plan Duration',
                '$_selectedDuration months',
                colors,
              ),
              _buildSummaryRow('Deposit', formatCurrency(_deposit), colors),
              _buildSummaryRow(
                'Monthly Payment',
                formatCurrency(_monthlyPayment),
                colors,
              ),
              const Divider(height: 20),
              _buildSummaryRow(
                'Total Amount',
                formatCurrency(_totalAmount),
                colors,
                isBold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Info about document upload
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Document',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You\'ll need to upload your ID document to complete the application. You can do this now or later from "My Laybys".',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Terms & conditions
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildTermItem(
                'Your application will be reviewed within 1-2 business days.',
                colors,
              ),
              _buildTermItem(
                'Once approved, you\'ll need to make the deposit payment to activate your layby.',
                colors,
              ),
              _buildTermItem(
                'Monthly payments must be made on time to keep your layby active.',
                colors,
              ),
              _buildTermItem(
                'The product will be delivered/dispatched after full payment.',
                colors,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() => _agreedToTerms = !_agreedToTerms);
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (v) {
                        setState(() => _agreedToTerms = v ?? false);
                      },
                      activeColor: colors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I agree to the layby terms and conditions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    ColorScheme colors, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withOpacity(isBold ? 1 : 0.6),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isBold ? colors.primary : colors.onSurface,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermItem(String text, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle_outline,
              size: 16,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Action Bar ───

  Widget _buildBottomBar(ColorScheme colors, LaybyState laybyState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _canProceed(laybyState) ? _handleAction : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              disabledBackgroundColor: colors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                laybyState.isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      _currentStep == 0
                          ? 'Continue to Review'
                          : 'Submit Application',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  bool _canProceed(LaybyState laybyState) {
    if (laybyState.isLoading) return false;
    if (_currentStep == 0) {
      return _selectedDuration != null;
    } else {
      return _agreedToTerms;
    }
  }

  void _handleAction() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
    } else {
      _submitApplication();
    }
  }

  Future<void> _submitApplication() async {
    final notifier = ref.read(laybyNotifierProvider.notifier);
    final request = LaybyApplyRequest(
      productId: widget.productId,
      variationId: widget.variationId,
      durationMonths: _selectedDuration!,
    );

    final application = await notifier.applyForLayby(request);

    if (!mounted) return;

    if (application != null) {
      // Success — show dialog with options
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Application Submitted!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your layby application has been submitted successfully. We will review and get back to you within 1-2 business days.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Application #: ${application.applicationNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (application.needsDocument) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Don\'t forget to upload your ID document to complete the application.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Go to layby list
                    context.go('/layby');
                  },
                  child: const Text('Go to My Laybys'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    // Go to application details (where they can upload document)
                    context.push('/layby/${application.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
      );
    } else {
      // Error
      final error = ref.read(laybyNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to submit application'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
