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

    return SingleChildScrollView(
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
          _paymentRow(colors, 'Monthly Payment', '${formatCurrency(monthly)}'),
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
            Text(
              'Payment History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${app.payments.length} payment${app.payments.length == 1 ? '' : 's'} recorded',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            ...app.payments.asMap().entries.map((entry) {
              final index = entry.key;
              final payment = entry.value;
              final statusLower = payment.status.toLowerCase();

              // Determine status color, icon, and label
              Color statusColor;
              IconData statusIcon;
              String statusLabel;

              switch (statusLower) {
                case 'completed':
                case 'success':
                case 'paid':
                  statusColor = Colors.green.shade600;
                  statusIcon = Icons.check_circle;
                  statusLabel = 'Paid';
                  break;
                case 'pending':
                case 'processing':
                  statusColor = Colors.amber.shade700;
                  statusIcon = Icons.schedule;
                  statusLabel = 'Pending';
                  break;
                case 'failed':
                case 'error':
                  statusColor = Colors.red.shade600;
                  statusIcon = Icons.cancel;
                  statusLabel = 'Failed';
                  break;
                case 'refunded':
                  statusColor = Colors.blue.shade600;
                  statusIcon = Icons.replay;
                  statusLabel = 'Refunded';
                  break;
                case 'cancelled':
                  statusColor = Colors.grey.shade600;
                  statusIcon = Icons.block;
                  statusLabel = 'Cancelled';
                  break;
                default:
                  statusColor = Colors.grey.shade500;
                  statusIcon = Icons.info_outline;
                  statusLabel =
                      payment.status.isNotEmpty
                          ? payment.status[0].toUpperCase() +
                              payment.status.substring(1)
                          : 'Unknown';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outline.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left status accent bar
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: statusColor,
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
                              // Top row: payment number + amount + status
                              Row(
                                children: [
                                  // Payment number
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: colors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#${index + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: colors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Amount
                                  Expanded(
                                    child: Text(
                                      formatCurrency(payment.amount),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colors.onSurface,
                                      ),
                                    ),
                                  ),
                                  // Status badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          statusIcon,
                                          size: 13,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
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
                                        ? _formatDateTime(payment.createdAt!)
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
                                            _paymentMethodIcon(
                                              payment.paymentMethod!,
                                            ),
                                            size: 12,
                                            color: colors.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _paymentMethodLabel(
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
            }),
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

    // Get the user's selected currency for exchange rate conversion
    final selectedCurrency = ref.read(selectedCurrencyProvider);
    final exchangeRate = selectedCurrency?.exchangeRateAsDouble ?? 1.0;
    final currencyCode = selectedCurrency?.code ?? 'USD';

    // Convert base-currency amounts to the user's selected currency
    final convertedMonthly = monthly * exchangeRate;
    final convertedBalance = balance * exchangeRate;
    final suggestedAmount =
        convertedMonthly > convertedBalance
            ? convertedBalance
            : convertedMonthly;

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
          balance: convertedBalance,
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
                  'Please transfer the amount to one of these accounts:',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                _buildBankDetail(
                  context,
                  'FNB Bank',
                  'Account: 62925950498',
                  'Branch Code: 250655',
                  'Ref: ${app.applicationNumber}',
                ),
                const SizedBox(height: 8),
                _buildBankDetail(
                  context,
                  'CBZ Bank',
                  'Account: 01131244540028',
                  'Branch: Union Ave',
                  'Ref: ${app.applicationNumber}',
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
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Refresh the details
                },
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
                Icon(Icons.location_on, color: colors.primary),
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
                  'Visit our nearest office to complete your payment:',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.outline.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, size: 18, color: colors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Raines Africa Office',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '1st Floor, Batanai Gardens,\nFirst Street & Jason Moyo Ave,\nHarare, Zimbabwe',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mon–Fri: 8:00 AM – 5:00 PM',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: colors.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+263 78 222 3456',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
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

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.suggestedAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
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
                    border: Border.all(color: colors.outline.withOpacity(0.3)),
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
                            color: colors.onSurface,
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
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        (_isProcessing || _selectedMethod == null)
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
    if (amount > widget.balance) {
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
