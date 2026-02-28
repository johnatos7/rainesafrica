import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/providers/layby_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/widgets/layby_status_badge.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_payment_section.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

/// Layby application details screen
class LaybyDetailsScreen extends ConsumerWidget {
  final int applicationId;

  const LaybyDetailsScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    // Always fetch fresh data when this screen is shown
    final detailsAsync = ref.watch(
      laybyApplicationDetailsProvider(applicationId),
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(
          'Layby Details',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Invalidate list cache so it refreshes when we go back
            ref.invalidate(laybyApplicationsProvider);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(laybyApplicationDetailsProvider(applicationId));
            },
          ),
        ],
      ),
      body: detailsAsync.when(
        data: (app) => _buildBody(context, ref, app, colors),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load details',
                    style: TextStyle(color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(
                          laybyApplicationDetailsProvider(applicationId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    LaybyApplication app,
    ColorScheme colors,
  ) {
    final totalAmount = double.tryParse(app.totalAmount) ?? 0;
    final totalPaid = double.tryParse(app.totalPaid) ?? 0;
    final balance = double.tryParse(app.balanceRemaining) ?? 0;
    final deposit = double.tryParse(app.depositAmount) ?? 0;
    final monthly = double.tryParse(app.monthlyAmount) ?? 0;
    final formatCurrency = ref.watch(currencyFormattingProvider);
    final canPay =
        app.status.toLowerCase() == 'active' ||
        app.status.toLowerCase() == 'approved';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(laybyApplicationDetailsProvider(applicationId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child:
                          app.thumbnailUrl != null
                              ? Image.network(
                                app.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => _placeholder(colors),
                              )
                              : _placeholder(colors),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        if (app.variationDisplayName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            app.variationDisplayName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        LaybyStatusBadge(status: app.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Application number
            _infoRow(colors, 'Application #', app.applicationNumber),

            if (app.rejectionReason != null &&
                app.status.toLowerCase() == 'rejected') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.error.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rejection Reason',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.rejectionReason!,
                      style: TextStyle(fontSize: 13, color: colors.onSurface),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Payment breakdown
            Text(
              'Payment Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _paymentRow(
              colors,
              'Product Price',
              '${formatCurrency(double.tryParse(app.productPrice) ?? 0)}',
            ),
            _paymentRow(
              colors,
              'Deposit (${app.durationMonths > 0 ? "${((deposit / totalAmount) * 100).toStringAsFixed(0)}%" : ""})',
              '${formatCurrency(deposit)}',
            ),
            _paymentRow(
              colors,
              'Monthly Payment',
              '${formatCurrency(monthly)}',
            ),
            _paymentRow(colors, 'Duration', '${app.durationMonths} months'),
            const Divider(height: 24),
            _paymentRow(
              colors,
              'Total Amount',
              '${formatCurrency(totalAmount)}',
              isBold: true,
            ),
            _paymentRow(
              colors,
              'Total Paid',
              '${formatCurrency(totalPaid)}',
              valueColor: Colors.green,
            ),
            _paymentRow(
              colors,
              'Balance Remaining',
              '${formatCurrency(balance)}',
              valueColor: balance > 0 ? colors.error : Colors.green,
            ),
            const SizedBox(height: 16),

            // Progress bar
            Text(
              'Payment Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: app.paymentProgress,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  app.paymentProgress >= 1.0 ? Colors.teal : colors.primary,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(app.paymentProgress * 100).toStringAsFixed(1)}% complete',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),

            // Payment history
            if (app.payments.isNotEmpty) ...[
              _PaymentHistorySection(
                payments: app.payments,
                formatCurrency: formatCurrency,
                formatDateTime: _formatDateTime,
                paymentMethodIcon: _paymentMethodIcon,
                paymentMethodLabel: _paymentMethodLabel,
              ),
            ],
            const SizedBox(height: 16),

            // Dates
            Text(
              'Dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _infoRow(colors, 'Applied', _formatDate(app.createdAt)),
            if (app.approvedAt != null)
              _infoRow(colors, 'Approved', _formatDate(app.approvedAt!)),
            if (app.lastPaymentAt != null)
              _infoRow(colors, 'Last Payment', _formatDate(app.lastPaymentAt!)),
            if (app.completedAt != null)
              _infoRow(colors, 'Completed', _formatDate(app.completedAt!)),
            const SizedBox(height: 24),

            // Pay button
            if (canPay)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showPaymentBottomSheet(context, ref, app),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Make Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.image, color: colors.onSurface.withOpacity(0.3)),
    );
  }

  Widget _infoRow(ColorScheme colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(
    ColorScheme colors,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour =
          date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $amPm';
    } catch (_) {
      return dateStr;
    }
  }

  IconData _paymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'payfast':
        return Icons.credit_card;
      case 'bank_transfer':
      case 'bank':
        return Icons.account_balance;
      case 'office_payment':
        return Icons.store;
      case 'airtel':
      case 'mtn':
      case 'airtel_mtn':
        return Icons.phone_android;
      case 'ecocash':
      case 'innbucks':
      case 'ecocash_innbucks':
        return Icons.smartphone;
      default:
        return Icons.payment;
    }
  }

  String _paymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'payfast':
        return 'Payfast';
      case 'bank_transfer':
      case 'bank':
        return 'Bank';
      case 'office_payment':
        return 'Office Payment';
      case 'airtel':
        return 'Airtel';
      case 'mtn':
        return 'MTN';
      case 'airtel_mtn':
        return 'Airtel/MTN';
      case 'ecocash':
        return 'Ecocash';
      case 'innbucks':
        return 'Innbucks';
      case 'ecocash_innbucks':
        return 'Ecocash/Innbucks';
      default:
        return method;
    }
  }

  void _showPaymentBottomSheet(
    BuildContext context,
    WidgetRef ref,
    LaybyApplication app,
  ) {
    final monthly = double.tryParse(app.monthlyAmount) ?? 0;
    final balance = double.tryParse(app.balanceRemaining) ?? 0;

    // Get the user's selected currency code for the payment API
    final selectedCurrency = ref.read(selectedCurrencyProvider);
    final currencyCode = selectedCurrency?.code ?? 'USD';

    // Layby amounts from the API are already in the store's base currency (ZAR).
    // Do NOT multiply by exchange rate — that inflates the suggested amount.
    final suggestedAmount = monthly > balance ? balance : monthly;

    final formatCurrency = ref.watch(currencyFormattingProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _PaymentMethodSheet(
          app: app,
          suggestedAmount: suggestedAmount,
          balance: balance,
          formatCurrency: formatCurrency,
          onPaymentSubmit: (paymentMethod, amount) async {
            Navigator.pop(ctx);

            // Gateway methods that redirect to webview
            final gatewayMethods = ['payfast', 'pdo_zambia', 'pese'];

            if (gatewayMethods.contains(paymentMethod)) {
              final redirectUrl = await ref
                  .read(laybyNotifierProvider.notifier)
                  .makePayment(
                    applicationId: app.id,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    currency: currencyCode,
                  );
              if (redirectUrl != null && context.mounted) {
                context.push(
                  '/layby/payment',
                  extra: {'url': redirectUrl, 'applicationId': app.id},
                );
              }
            } else if (paymentMethod == 'bank_transfer') {
              // Submit via API with bank_transfer method, then show confirmation
              await ref
                  .read(laybyNotifierProvider.notifier)
                  .makePayment(
                    applicationId: app.id,
                    amount: amount,
                    paymentMethod: 'bank_transfer',
                    currency: currencyCode,
                  );
              if (context.mounted) {
                _showBankTransferConfirmation(
                  context,
                  app,
                  amount,
                  formatCurrency,
                );
              }
            } else if (paymentMethod == 'cod' ||
                paymentMethod == 'office_payment') {
              // Submit via API with office/cod method, then show confirmation
              await ref
                  .read(laybyNotifierProvider.notifier)
                  .makePayment(
                    applicationId: app.id,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    currency: currencyCode,
                  );
              if (context.mounted) {
                _showOfficePaymentConfirmation(
                  context,
                  app,
                  amount,
                  formatCurrency,
                );
              }
            } else {
              // Unknown method — try as gateway
              final redirectUrl = await ref
                  .read(laybyNotifierProvider.notifier)
                  .makePayment(
                    applicationId: app.id,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    currency: currencyCode,
                  );
              if (redirectUrl != null && context.mounted) {
                context.push(
                  '/layby/payment',
                  extra: {'url': redirectUrl, 'applicationId': app.id},
                );
              }
            }
          },
        );
      },
    );
  }

  void _showBankTransferConfirmation(
    BuildContext context,
    LaybyApplication app,
    double amount,
    String Function(double) formatCurrency,
  ) {
    final colors = Theme.of(context).colorScheme;

    // Same bank accounts as checkout
    final bankAccounts = [
      {
        'name': 'CBZ – Zimbabwe',
        'account': '12626684910022',
        'bic': 'COBZZWHAXXX',
      },
      {'name': 'FNB – Zambia', 'account': '63100161916', 'bic': 'FIRNZMLX XXX'},
      {
        'name': 'FNB – South Africa',
        'account': '63023044695',
        'bic': 'FIRNZAJJ',
      },
    ];

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.account_balance, color: colors.primary),
                const SizedBox(width: 8),
                const Text('Bank Transfer Details'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Payment recorded!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          'Amount: ${formatCurrency(amount)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please transfer the exact amount to one of the following accounts:',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...bankAccounts.map(
                    (acc) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildBankDetail(
                        context,
                        acc['name']!,
                        'Account: ${acc['account']!}',
                        'BIC: ${acc['bic']!}',
                        'Ref: ${app.applicationNumber}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use your application number as the payment reference',
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
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  Widget _buildBankDetail(
    BuildContext context,
    String bankName,
    String account,
    String branch,
    String reference,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bankName,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            account,
            style: TextStyle(fontSize: 12, color: colors.onSurface),
          ),
          Text(branch, style: TextStyle(fontSize: 12, color: colors.onSurface)),
          Row(
            children: [
              Expanded(
                child: Text(
                  reference,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: reference.replaceAll('Ref: ', '')),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reference copied!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(Icons.copy, size: 16, color: colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOfficePaymentConfirmation(
    BuildContext context,
    LaybyApplication app,
    double amount,
    String Function(double) formatCurrency,
  ) {
    final colors = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.store, color: colors.primary),
                const SizedBox(width: 8),
                const Text('Office Payment'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Payment recorded!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'Amount: ${formatCurrency(amount)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Visit your nearest Raines Africa office to complete your payment.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please bring your application number: ${app.applicationNumber}',
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
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Payment History Section with filter chips, stats & pagination
// ═══════════════════════════════════════════════════════════════════

enum _PaymentFilter { all, paid, pending, failed }

class _PaymentHistorySection extends StatefulWidget {
  final List<LaybyPayment> payments;
  final String Function(double) formatCurrency;
  final String Function(String) formatDateTime;
  final IconData Function(String) paymentMethodIcon;
  final String Function(String) paymentMethodLabel;

  const _PaymentHistorySection({
    required this.payments,
    required this.formatCurrency,
    required this.formatDateTime,
    required this.paymentMethodIcon,
    required this.paymentMethodLabel,
  });

  @override
  State<_PaymentHistorySection> createState() => _PaymentHistorySectionState();
}

class _PaymentHistorySectionState extends State<_PaymentHistorySection> {
  _PaymentFilter _activeFilter = _PaymentFilter.all;
  static const int _pageSize = 5;
  int _visibleCount = _pageSize;

  // ── Helpers ──

  List<LaybyPayment> get _filteredPayments {
    switch (_activeFilter) {
      case _PaymentFilter.paid:
        return widget.payments.where((p) => _isPaid(p.status)).toList();
      case _PaymentFilter.pending:
        return widget.payments.where((p) => _isPending(p.status)).toList();
      case _PaymentFilter.failed:
        return widget.payments.where((p) => _isFailed(p.status)).toList();
      case _PaymentFilter.all:
        return widget.payments;
    }
  }

  static bool _isPaid(String status) {
    final s = status.toLowerCase();
    return s == 'completed' || s == 'success' || s == 'paid';
  }

  static bool _isPending(String status) {
    final s = status.toLowerCase();
    return s == 'pending' || s == 'processing';
  }

  static bool _isFailed(String status) {
    final s = status.toLowerCase();
    return s == 'failed' || s == 'error' || s == 'cancelled' || s == 'refunded';
  }

  int _countByFilter(_PaymentFilter f) {
    switch (f) {
      case _PaymentFilter.all:
        return widget.payments.length;
      case _PaymentFilter.paid:
        return widget.payments.where((p) => _isPaid(p.status)).length;
      case _PaymentFilter.pending:
        return widget.payments.where((p) => _isPending(p.status)).length;
      case _PaymentFilter.failed:
        return widget.payments.where((p) => _isFailed(p.status)).length;
    }
  }

  ({Color color, IconData icon, String label}) _statusInfo(String status) {
    final s = status.toLowerCase();
    if (_isPaid(s)) {
      return (
        color: Colors.green.shade600,
        icon: Icons.check_circle,
        label: 'Paid',
      );
    } else if (_isPending(s)) {
      return (
        color: Colors.amber.shade700,
        icon: Icons.schedule,
        label: 'Pending',
      );
    } else if (s == 'failed' || s == 'error') {
      return (color: Colors.red.shade600, icon: Icons.cancel, label: 'Failed');
    } else if (s == 'refunded') {
      return (
        color: Colors.blue.shade600,
        icon: Icons.replay,
        label: 'Refunded',
      );
    } else if (s == 'cancelled') {
      return (
        color: Colors.grey.shade600,
        icon: Icons.block,
        label: 'Cancelled',
      );
    }
    return (
      color: Colors.grey.shade500,
      icon: Icons.info_outline,
      label:
          status.isNotEmpty
              ? status[0].toUpperCase() + status.substring(1)
              : 'Unknown',
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filteredPayments;
    final shown = filtered.take(_visibleCount).toList();
    final hasMore = _visibleCount < filtered.length;

    // Summary
    final totalForFilter = filtered.fold<double>(0, (sum, p) => sum + p.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Payment History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // ── Filter Chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                _PaymentFilter.values.map((f) {
                  final isActive = _activeFilter == f;
                  final count = _countByFilter(f);
                  final label = switch (f) {
                    _PaymentFilter.all => 'All',
                    _PaymentFilter.paid => 'Paid',
                    _PaymentFilter.pending => 'Pending',
                    _PaymentFilter.failed => 'Failed',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isActive,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(label),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? colors.onPrimary.withOpacity(0.2)
                                      : colors.onSurface.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color:
                                    isActive
                                        ? colors.onPrimary
                                        : colors.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      selectedColor: colors.primary,
                      backgroundColor: colors.surfaceContainerHigh,
                      checkmarkColor: colors.onPrimary,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? colors.onPrimary : colors.onSurface,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color:
                              isActive
                                  ? colors.primary
                                  : colors.outline.withOpacity(0.15),
                        ),
                      ),
                      showCheckmark: false,
                      onSelected: (_) {
                        setState(() {
                          _activeFilter = f;
                          _visibleCount = _pageSize; // reset pagination
                        });
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // ── Summary Stats ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.receipt_long, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                '${filtered.length} payment${filtered.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${widget.formatCurrency(totalForFilter)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Payment Cards or Empty State ──
        if (filtered.isEmpty)
          _buildEmptyState(colors)
        else ...[
          ...shown.asMap().entries.map((entry) {
            final index = entry.key;
            final payment = entry.value;
            return _buildPaymentCard(context, payment, index + 1, colors);
          }),
          // ── Show More / Show Less ──
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _visibleCount += _pageSize;
                    });
                  },
                  icon: const Icon(Icons.expand_more, size: 20),
                  label: Text(
                    'Show More (${filtered.length - shown.length} remaining)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          if (!hasMore && filtered.length > _pageSize)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _visibleCount = _pageSize;
                    });
                  },
                  icon: const Icon(Icons.expand_less, size: 20),
                  label: const Text(
                    'Show Less',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    final label = switch (_activeFilter) {
      _PaymentFilter.all => 'No payments recorded yet',
      _PaymentFilter.paid => 'No paid payments yet',
      _PaymentFilter.pending => 'No pending payments',
      _PaymentFilter.failed => 'No failed payments',
    };
    final icon = switch (_activeFilter) {
      _PaymentFilter.all => Icons.receipt_long_outlined,
      _PaymentFilter.paid => Icons.check_circle_outline,
      _PaymentFilter.pending => Icons.schedule,
      _PaymentFilter.failed => Icons.cancel_outlined,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 40, color: colors.onSurface.withOpacity(0.25)),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    LaybyPayment payment,
    int displayNumber,
    ColorScheme colors,
  ) {
    final info = _statusInfo(payment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.12), width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left status accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: info.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: number + amount + status
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              '#$displayNumber',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.formatCurrency(payment.amount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: info.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(info.icon, size: 13, color: info.color),
                              const SizedBox(width: 4),
                              Text(
                                info.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: info.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Bottom row: date & payment method
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: colors.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          payment.createdAt != null
                              ? widget.formatDateTime(payment.createdAt!)
                              : 'Date unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                        ),
                        if (payment.paymentMethod != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.paymentMethodIcon(
                                    payment.paymentMethod!,
                                  ),
                                  size: 12,
                                  color: colors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.paymentMethodLabel(
                                    payment.paymentMethod!,
                                  ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet with payment method selection using checkout payment methods
class _PaymentMethodSheet extends ConsumerStatefulWidget {
  final LaybyApplication app;
  final double suggestedAmount;
  final double balance;
  final String Function(double) formatCurrency;
  final Future<void> Function(String paymentMethod, double amount)
  onPaymentSubmit;

  const _PaymentMethodSheet({
    required this.app,
    required this.suggestedAmount,
    required this.balance,
    required this.formatCurrency,
    required this.onPaymentSubmit,
  });

  @override
  ConsumerState<_PaymentMethodSheet> createState() =>
      _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends ConsumerState<_PaymentMethodSheet> {
  PaymentMethodEntity? _selectedMethod;
  late TextEditingController _amountController;
  bool _isProcessing = false;
  String? _amountError;
  late double _convertedBalance;

  @override
  void initState() {
    super.initState();
    // Convert suggestedAmount to the selected currency using exchange rate
    // so the pre-filled value matches the currency symbol shown
    final selectedCurrency = ref.read(selectedCurrencyProvider);
    final exchangeRate = selectedCurrency?.exchangeRateAsDouble ?? 1.0;
    final convertedAmount = widget.suggestedAmount * exchangeRate;
    _convertedBalance = widget.balance * exchangeRate;
    _amountController = TextEditingController(
      text: convertedAmount.toStringAsFixed(2),
    );
    _amountController.addListener(_validateAmount);
  }

  void _validateAmount() {
    final text = _amountController.text;
    final amount = double.tryParse(text);
    setState(() {
      if (text.isEmpty) {
        _amountError = null;
      } else if (amount == null) {
        _amountError = 'Please enter a valid number';
      } else if (amount <= 0) {
        _amountError = 'Amount must be greater than 0';
      } else if (amount > _convertedBalance) {
        _amountError =
            'Amount exceeds balance of ${widget.formatCurrency(widget.balance)}';
      } else {
        _amountError = null;
      }
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Text(
                  'Make Layby Payment',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how you want to pay',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),

                // Reuse checkout payment section
                CheckoutPaymentSection(
                  selectedPaymentMethod: _selectedMethod,
                  onPaymentMethodSelected: (method) {
                    setState(() => _selectedMethod = method);
                  },
                ),

                const SizedBox(height: 20),

                // Amount input
                Text(
                  'Payment Amount',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          _amountError != null
                              ? colors.error
                              : colors.outline.withOpacity(0.3),
                      width: _amountError != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          widget
                              .formatCurrency(0)
                              .replaceAll(RegExp(r'[0-9,.]'), '')
                              .trim(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                _amountError != null
                                    ? colors.error
                                    : colors.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color:
                                _amountError != null
                                    ? colors.error
                                    : colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_amountError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _amountError!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Suggested: ${widget.formatCurrency(widget.suggestedAmount)} (Monthly payment)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_isProcessing ||
                                _selectedMethod == null ||
                                _amountError != null)
                            ? null
                            : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      disabledBackgroundColor: colors.primary.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              _selectedMethod != null
                                  ? 'Continue'
                                  : 'Select a payment method',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    // Convert balance to the selected currency for comparison
    final selectedCurrency = ref.read(selectedCurrencyProvider);
    final exchangeRate = selectedCurrency?.exchangeRateAsDouble ?? 1.0;
    final convertedBalance = widget.balance * exchangeRate;
    if (amount > convertedBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Amount cannot exceed balance of ${widget.formatCurrency(widget.balance)}',
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final methodKey = _selectedMethod!.name;
      await widget.onPaymentSubmit(methodKey, amount);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
