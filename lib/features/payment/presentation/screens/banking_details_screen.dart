import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/presentation/providers/payment_account_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/presentation/widgets/payment_account_form.dart';

class BankingDetailsScreen extends ConsumerStatefulWidget {
  const BankingDetailsScreen({super.key});

  @override
  ConsumerState<BankingDetailsScreen> createState() =>
      _BankingDetailsScreenState();
}

class _BankingDetailsScreenState extends ConsumerState<BankingDetailsScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();
    // Load payment account data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentAccountProvider.notifier).loadPaymentAccount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentAccountState = ref.watch(paymentAccountProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Banking Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body:
          paymentAccountState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : paymentAccountState.paymentAccount != null
              ? _buildPaymentAccountDetails(
                context,
                paymentAccountState.paymentAccount!,
              )
              : _buildEmptyState(context),
    );
  }

  Widget _buildPaymentAccountDetails(BuildContext context, paymentAccount) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Card Widget
          _buildCreditCardWidget(context, paymentAccount),

          const SizedBox(height: 24),

          // Bank Details Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/paypal.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Paypal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  _buildDetailRow('PayPal Email', paymentAccount.paypalEmail),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardWidget(BuildContext context, paymentAccount) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Format the account number to display as card number
    String formattedCardNumber = paymentAccount.bankAccountNo;
    if (formattedCardNumber.length > 16) {
      formattedCardNumber = formattedCardNumber.substring(0, 16);
    }
    // Pad with zeros if less than 16 digits
    formattedCardNumber = formattedCardNumber.padLeft(16, '0');
    // Add spaces every 4 digits
    formattedCardNumber =
        formattedCardNumber
            .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
            .trim();

    return Container(
      height: 200,
      child: CreditCardWidget(
        cardNumber: formattedCardNumber,
        expiryDate: '--/--',
        cardHolderName: paymentAccount.bankHolderName,
        cvvCode: '***', // Masked CVV
        showBackView: isCvvFocused,
        onCreditCardWidgetChange: (CreditCardBrand brand) {},
        bankName: paymentAccount.bankName,
        enableFloatingCard: true,
        floatingConfig: FloatingConfig(
          isGlareEnabled: true,
          isShadowEnabled: true,
          shadowConfig: FloatingShadowConfig(),
        ),
        labelValidThru: 'VALID\nTHRU',
        obscureCardNumber: false,
        obscureInitialCardNumber: false,
        obscureCardCvv: true,
        labelCardHolder: 'CARD HOLDER',
        cardType: CardType.otherBrand,
        isHolderNameVisible: true,
        height: 200,
        textStyle: TextStyle(color: colors.onSurface),
        width: MediaQuery.of(context).size.width,
        isChipVisible: true,
        isSwipeGestureEnabled: true,
        animationDuration: const Duration(milliseconds: 1000),
        padding: 16,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 40,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Banking Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your banking details to manage payments and withdrawals',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Banking Details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => PaymentAccountForm(
            onSave: (
              bankAccountNo,
              bankHolderName,
              bankName,
              paypalEmail,
              swift,
              ifsc,
            ) {
              ref
                  .read(paymentAccountProvider.notifier)
                  .createPaymentAccount(
                    bankAccountNo: bankAccountNo,
                    bankHolderName: bankHolderName,
                    bankName: bankName,
                    paypalEmail: paypalEmail,
                    swift: swift,
                    ifsc: ifsc,
                  );
            },
          ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final paymentAccount = ref.read(paymentAccountProvider).paymentAccount;
    if (paymentAccount == null) return;

    showDialog(
      context: context,
      builder:
          (context) => PaymentAccountForm(
            initialData: {
              'bankAccountNo': paymentAccount.bankAccountNo,
              'bankHolderName': paymentAccount.bankHolderName,
              'bankName': paymentAccount.bankName,
              'paypalEmail': paymentAccount.paypalEmail,
              'swift': paymentAccount.swift,
              'ifsc': paymentAccount.ifsc ?? '',
            },
            onSave: (
              bankAccountNo,
              bankHolderName,
              bankName,
              paypalEmail,
              swift,
              ifsc,
            ) {
              ref
                  .read(paymentAccountProvider.notifier)
                  .updatePaymentAccount(
                    id: paymentAccount.id,
                    bankAccountNo: bankAccountNo,
                    bankHolderName: bankHolderName,
                    bankName: bankName,
                    paypalEmail: paypalEmail,
                    swift: swift,
                    ifsc: ifsc,
                  );
            },
          ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final paymentAccount = ref.read(paymentAccountProvider).paymentAccount;
    if (paymentAccount == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Banking Details'),
            content: const Text(
              'Are you sure you want to delete your banking details? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref
                      .read(paymentAccountProvider.notifier)
                      .deletePaymentAccount(paymentAccount.id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
