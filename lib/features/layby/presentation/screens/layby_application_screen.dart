import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/providers/layby_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/document_upload_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';

/// Multi-step layby application screen
class LaybyApplicationScreen extends ConsumerStatefulWidget {
  final int productId;
  final int? variationId;
  final LaybyEligibility eligibility;

  const LaybyApplicationScreen({
    super.key,
    required this.productId,
    this.variationId,
    required this.eligibility,
  });

  @override
  ConsumerState<LaybyApplicationScreen> createState() =>
      _LaybyApplicationScreenState();
}

class _LaybyApplicationScreenState
    extends ConsumerState<LaybyApplicationScreen> {
  int _currentStep = 0;
  int? _selectedDuration;
  String _documentType = 'id_card';
  final _documentNumberController = TextEditingController();
  LaybyAttachment? _uploadedAttachment;
  LaybyDocument? _selectedExistingDoc;
  bool _isSubmitting = false;

  final List<String> _documentTypes = [
    'id_card',
    'passport',
    'drivers_license',
  ];

  static const _documentTypeLabels = {
    'id_card': 'ID Card',
    'passport': 'Passport',
    'drivers_license': "Driver's License",
  };

  @override
  void initState() {
    super.initState();
    if (widget.eligibility.availableDurations.isNotEmpty) {
      _selectedDuration = widget.eligibility.availableDurations.first;
    }
  }

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(
          'Apply for Layby',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(colors),
          const Divider(height: 1),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildCurrentStep(colors),
              ),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(colors),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(ColorScheme colors) {
    final steps = ['Plan', 'ID Verification', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        index < _currentStep
                            ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                            : Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isActive
                                        ? Colors.white
                                        : colors.onSurface.withOpacity(0.5),
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    steps[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isCurrent
                              ? colors.onSurface
                              : colors.onSurface.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (index < steps.length - 1) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                          index < _currentStep
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(ColorScheme colors) {
    switch (_currentStep) {
      case 0:
        return _buildPlanStep(colors);
      case 1:
        return _buildDocumentStep(colors);
      case 2:
        return _buildReviewStep(colors);
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────── Step 1: Plan Selection ───────────────────────

  Widget _buildPlanStep(ColorScheme colors) {
    final price = widget.eligibility.price;
    final formatCurrency = ref.watch(currencyFormattingProvider);

    return Column(
      key: const ValueKey('step-plan'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Plan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select a payment duration that works for you',
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),

        // Duration options
        ...widget.eligibility.availableDurations.map((months) {
          final depositPct = widget.eligibility.depositPercentage;
          final deposit = price * depositPct / 100;
          final remaining = price - deposit;
          final monthly = remaining / months;
          final isSelected = _selectedDuration == months;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => setState(() => _selectedDuration = months),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colors.primary.withOpacity(0.08)
                          : colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: isSelected ? colors.primary : colors.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$months months',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.eligibility.depositPercentage}% deposit (${formatCurrency(deposit)})',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${formatCurrency(monthly)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          '/month',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _summaryRow(colors, 'Product Price', '${formatCurrency(price)}'),
              _summaryRow(colors, 'Interest', '0%'),
              _summaryRow(
                colors,
                'Total',
                '${formatCurrency(price)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────── Step 2: Document Verification ───────────────────────

  Widget _buildDocumentStep(ColorScheme colors) {
    final docsAsync = ref.watch(laybyUploadedDocumentsProvider);

    return Column(
      key: const ValueKey('step-document'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ID Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload your ID document for verification',
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),

        // Document type dropdown
        DropdownButtonFormField<String>(
          value: _documentType,
          decoration: InputDecoration(
            labelText: 'Document Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items:
              _documentTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_documentTypeLabels[t] ?? t),
                    ),
                  )
                  .toList(),
          onChanged: (v) => setState(() => _documentType = v!),
        ),
        const SizedBox(height: 12),

        // Document number
        TextFormField(
          controller: _documentNumberController,
          decoration: InputDecoration(
            labelText: 'Document Number',
            hintText: 'Enter your document number',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),

        // Document upload
        docsAsync.when(
          data:
              (existingDocs) => DocumentUploadWidget(
                existingDocuments: existingDocs,
                onAttachmentReady: (attachment) {
                  setState(() {
                    _uploadedAttachment = attachment;
                    _selectedExistingDoc = null;
                  });
                },
                onExistingDocumentSelected: (doc) {
                  setState(() {
                    _selectedExistingDoc = doc;
                    _uploadedAttachment = null;
                  });
                },
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (_, __) => DocumentUploadWidget(
                existingDocuments: const [],
                onAttachmentReady: (attachment) {
                  setState(() {
                    _uploadedAttachment = attachment;
                    _selectedExistingDoc = null;
                  });
                },
                onExistingDocumentSelected: (_) {},
              ),
        ),
      ],
    );
  }

  // ─────────────────────── Step 3: Review ───────────────────────

  Widget _buildReviewStep(ColorScheme colors) {
    final price = widget.eligibility.price;
    final deposit = price * widget.eligibility.depositPercentage / 100;
    final remaining = price - deposit;
    final monthly =
        _selectedDuration != null && _selectedDuration! > 0
            ? remaining / _selectedDuration!
            : 0.0;
    final formatCurrency = ref.watch(currencyFormattingProvider);

    return Column(
      key: const ValueKey('step-review'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Application',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Please review your layby application details',
          style: TextStyle(
            fontSize: 13,
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),

        _reviewSection(colors, 'Plan Details', [
          _summaryRow(colors, 'Duration', '$_selectedDuration months'),
          _summaryRow(colors, 'Product Price', '${formatCurrency(price)}'),
          _summaryRow(
            colors,
            'Deposit (${widget.eligibility.depositPercentage}%)',
            '${formatCurrency(deposit)}',
          ),
          _summaryRow(colors, 'Monthly Payment', '${formatCurrency(monthly)}'),
          _summaryRow(
            colors,
            'Total Amount',
            '${formatCurrency(price)}',
            isBold: true,
          ),
        ]),
        const SizedBox(height: 12),

        _reviewSection(colors, 'ID Document', [
          _summaryRow(
            colors,
            'Type',
            _documentTypeLabels[_documentType] ?? _documentType,
          ),
          _summaryRow(colors, 'Number', _documentNumberController.text),
          _summaryRow(
            colors,
            'Source',
            _selectedExistingDoc != null
                ? 'Previously uploaded'
                : _uploadedAttachment != null
                ? 'Newly uploaded'
                : 'Not provided',
          ),
        ]),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your application will be reviewed within 1-2 business days. You will be notified once approved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reviewSection(
    ColorScheme colors,
    String title,
    List<Widget> children,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryRow(
    ColorScheme colors,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────── Bottom Buttons ───────────────────────

  Widget _buildBottomButtons(ColorScheme colors) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        _currentStep == 2 ? 'Submit Application' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_selectedDuration == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment duration')),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_documentNumberController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your document number')),
        );
        return;
      }
      if (_uploadedAttachment == null && _selectedExistingDoc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload or select an ID document'),
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      _submitApplication();
    }
  }

  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);

    final attachmentId =
        _selectedExistingDoc != null
            ? _selectedExistingDoc!.attachmentId.toString()
            : _uploadedAttachment?.id ?? '';

    final request = LaybyApplyRequest(
      productId: widget.productId,
      variationId: widget.variationId,
      durationMonths: _selectedDuration!,
      idDocumentAttachmentId: attachmentId,
      idDocumentType: _documentType,
      idDocumentNumber: _documentNumberController.text.trim(),
    );

    final application = await ref
        .read(laybyNotifierProvider.notifier)
        .applyForLayby(request);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (application != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layby application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/layby/${application.id}');
    } else {
      final error = ref.read(laybyNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to submit application'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
