import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/presentation/providers/repayment_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_payment_section.dart';

class RepaymentScreen extends ConsumerStatefulWidget {
  final OrderEntity order;

  const RepaymentScreen({super.key, required this.order});

  @override
  ConsumerState<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends ConsumerState<RepaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Clear any previous repayment state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(repaymentProvider.notifier).clearResponse();
      ref.read(repaymentProvider.notifier).clearError();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final repaymentState = ref.watch(repaymentProvider);

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'Retry Payment',
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
      ),
      body: _buildBody(repaymentState, colors),
    );
  }

  Widget _buildBody(RepaymentState state, ColorScheme colors) {
    if (state.isProcessing) {
      return _buildProcessingState(colors);
    }

    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildOrderSummary(colors),
                const SizedBox(height: 16),
                _buildPaymentSection(),
                const SizedBox(height: 16),
                _buildActionButtons(colors),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(state.errorMessage!, colors),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${widget.order.orderNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${widget.order.currencySymbol}${(widget.order.summary!.finalTotal * (widget.order.exchangeRate ?? 1)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.order.orderStatus.name,
                      colors,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(
                        widget.order.orderStatus.name,
                        colors,
                      ).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    widget.order.orderStatus.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(
                        widget.order.orderStatus.name,
                        colors,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            CheckoutPaymentSection(
              selectedPaymentMethod:
                  ref.watch(repaymentProvider).selectedPaymentMethod,
              onPaymentMethodSelected: (method) {
                if (method != null) {
                  ref.read(repaymentProvider.notifier).setPaymentMethod(method);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processRepayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Process Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary, strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your payment',
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String error, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: colors.onErrorContainer, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _processRepayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final repaymentState = ref.read(repaymentProvider);
    if (repaymentState.selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref
        .read(repaymentProvider.notifier)
        .processRepayment(
          orderNumber: widget.order.orderNumber.toString(),
          amount: widget.order.total,
          currency: widget.order.currency,
          currencyCode: widget.order.currency,
          currencySymbol: widget.order.currencySymbol,
        )
        .then((_) {
          final state = ref.read(repaymentProvider);
          if (state.repaymentResponse != null) {
            _handleRepaymentResponse(state.repaymentResponse!);
          }
        });
  }

  void _handleRepaymentResponse(repaymentResponse) {
    print('💳 REPAYMENT: Handling response');
    print('💳 REPAYMENT: isRedirect: ${repaymentResponse.isRedirect}');
    print('💳 REPAYMENT: redirectUrl: ${repaymentResponse.redirectUrl}');

    // Handle the response similar to checkout
    if (repaymentResponse.isRedirect && repaymentResponse.redirectUrl != null) {
      print(
        '💳 REPAYMENT: Launching payment URL: ${repaymentResponse.redirectUrl}',
      );
      _openPaymentWebView(repaymentResponse.redirectUrl!);
    } else {
      print('💳 REPAYMENT: No redirect, showing success message');
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment processed successfully: ${repaymentResponse.orderNumber}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _openPaymentWebView(String url) {
    final qp = <String, String>{
      'url': url,
      'successPrefix': '/en/account/order',
    };
    if (!mounted) return;
    context.go(Uri(path: '/payment_webview', queryParameters: qp).toString());
  }

  Color _getStatusColor(String status, ColorScheme colors) {
    switch (status.toLowerCase()) {
      case 'pending':
        return colors.secondary;
      case 'processing':
        return colors.primary;
      case 'shipped':
        return colors.tertiary;
      case 'out for delivery':
        return colors.tertiary;
      case 'delivered':
        return Color.lerp(colors.primary, Colors.green, 0.7) ??
            const Color(0xFF52C41A);
      case 'ready for collection':
        return colors.tertiary;
      case 'collected':
        return Color.lerp(colors.primary, Colors.green, 0.7) ??
            const Color(0xFF52C41A);
      case 'cancelled':
        return colors.error;
      case 'failed':
        return colors.error;
      default:
        return colors.onSurface.withOpacity(0.6);
    }
  }
}
