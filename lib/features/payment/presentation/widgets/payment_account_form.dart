import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/presentation/providers/payment_account_provider.dart';

class PaymentAccountForm extends ConsumerStatefulWidget {
  final Map<String, String>? initialData;
  final Function(
    String bankAccountNo,
    String bankHolderName,
    String bankName,
    String paypalEmail,
    String swift,
    String? ifsc,
  )
  onSave;

  const PaymentAccountForm({super.key, this.initialData, required this.onSave});

  @override
  ConsumerState<PaymentAccountForm> createState() => _PaymentAccountFormState();
}

class _PaymentAccountFormState extends ConsumerState<PaymentAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountNoController = TextEditingController();
  final _bankHolderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _paypalEmailController = TextEditingController();
  final _swiftController = TextEditingController();
  final _ifscController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _bankAccountNoController.text =
          widget.initialData!['bankAccountNo'] ?? '';
      _bankHolderNameController.text =
          widget.initialData!['bankHolderName'] ?? '';
      _bankNameController.text = widget.initialData!['bankName'] ?? '';
      _paypalEmailController.text = widget.initialData!['paypalEmail'] ?? '';
      _swiftController.text = widget.initialData!['swift'] ?? '';
      _ifscController.text = widget.initialData!['ifsc'] ?? '';
    }
  }

  @override
  void dispose() {
    _bankAccountNoController.dispose();
    _bankHolderNameController.dispose();
    _bankNameController.dispose();
    _paypalEmailController.dispose();
    _swiftController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final paymentAccountState = ref.watch(paymentAccountProvider);

    return AlertDialog(
      title: Text(
        widget.initialData != null
            ? 'Edit Banking Details'
            : 'Add Banking Details',
        style: theme.textTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bank Name
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(
                  labelText: 'Bank Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(
                    Icons.account_balance,
                    color: colors.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Holder Name
              TextFormField(
                controller: _bankHolderNameController,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: colors.primary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Number
              TextFormField(
                controller: _bankAccountNoController,
                decoration: InputDecoration(
                  labelText: 'Account Number *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.credit_card, color: colors.primary),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // SWIFT Code
              TextFormField(
                controller: _swiftController,
                decoration: InputDecoration(
                  labelText: 'SWIFT Code *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.code, color: colors.primary),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter SWIFT code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // IFSC Code (Optional)
              TextFormField(
                controller: _ifscController,
                decoration: InputDecoration(
                  labelText: 'IFSC Code (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.tag, color: colors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // PayPal Email
              TextFormField(
                controller: _paypalEmailController,
                decoration: InputDecoration(
                  labelText: 'PayPal Email *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.email, color: colors.primary),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PayPal email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
              onPressed:
                  paymentAccountState.isLoading
                      ? null
                      : () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave(
                            _bankAccountNoController.text,
                            _bankHolderNameController.text,
                            _bankNameController.text,
                            _paypalEmailController.text,
                            _swiftController.text,
                            _ifscController.text.isEmpty
                                ? null
                                : _ifscController.text,
                          );
                          Navigator.of(context).pop();
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  paymentAccountState.isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.onPrimary,
                          ),
                        ),
                      )
                      : Text(widget.initialData != null ? 'Update' : 'Save'),
            );
          },
        ),
      ],
    );
  }
}
