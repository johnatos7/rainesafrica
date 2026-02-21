import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/providers/checkout_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_address_section.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_payment_section.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_shipping_section.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_summary_section.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/order_notes_field.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/widgets/checkout_step_content.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_loading.dart';
import 'package:flutter_riverpod_clean_architecture/core/ui/widgets/app_error.dart'
    as app_error;
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_type.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:go_router/go_router.dart';

class CheckoutStepsScreen extends ConsumerStatefulWidget {
  const CheckoutStepsScreen({super.key});

  @override
  ConsumerState<CheckoutStepsScreen> createState() =>
      _CheckoutStepsScreenState();
}

class _CheckoutStepsScreenState extends ConsumerState<CheckoutStepsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderNotesController = TextEditingController();
  final _pageController = PageController();

  final List<ScrollController> _scrollControllers = List.generate(
    5,
    (_) => ScrollController(),
  );

  int _currentStep = 0;
  final int _totalSteps = 5;

  final List<Map<String, String>> _bankAccounts = [
    {
      'name': 'CBZ – Zimbabwe',
      'account': '12626684910022',
      'bic': 'COBZZWHAXXX',
    },
    {'name': 'FNB – Zambia', 'account': '63100161916', 'bic': 'FIRNZMLX XXX'},
    {'name': 'FNB – South Africa', 'account': '63023044695', 'bic': 'FIRNZAJJ'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).initializeCheckout();
      ref.read(walletProvider.notifier).loadWallet();
    });
  }

  @override
  void dispose() {
    _orderNotesController.dispose();
    _pageController.dispose();
    for (final sc in _scrollControllers) {
      sc.dispose();
    }
    super.dispose();
  }

  bool _validateCurrentStep() {
    final checkoutState = ref.read(checkoutProvider);
    switch (_currentStep) {
      case 0:
        return checkoutState.shippingAddress != null;
      case 1:
        return checkoutState.billingAddress != null;
      case 2:
        return checkoutState.selectedShipping != null;
      case 3:
        return checkoutState.selectedPaymentMethod != null;
      default:
        return true;
    }
  }

  bool _canProceed() => _validateCurrentStep();

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _placeOrder();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _placeOrder() async {
    print('DEBUG: _placeOrder called');

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    // Get current checkout state
    final checkoutState = ref.read(checkoutProvider);
    print('DEBUG: Current checkout state: $checkoutState');

    // Comprehensive validation before processing
    final validationErrors = _validateCheckoutData(checkoutState);
    if (validationErrors.isNotEmpty) {
      print('DEBUG: Checkout validation failed: $validationErrors');
      _showValidationErrors(validationErrors);
      return;
    }

    print('DEBUG: All validations passed, proceeding with checkout');

    try {
      print('DEBUG: Starting checkout process...');
      await ref.read(checkoutProvider.notifier).processCheckout();

      if (mounted) {
        print('DEBUG: Checkout completed successfully');
        ref.invalidate(cartProvider);
        ref.invalidate(cartSummaryProvider);

        final state = ref.read(checkoutProvider);
        if (state.checkoutResponse != null) {
          print('DEBUG: Handling payment response');
          _handlePaymentResponse(state.checkoutResponse!);
        }
      }
    } catch (e) {
      print('DEBUG: Checkout failed with error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _placeOrder(),
            ),
          ),
        );
      }
    }
  }

  // Comprehensive validation method
  List<String> _validateCheckoutData(CheckoutState state) {
    final errors = <String>[];

    print('DEBUG: Validating checkout data...');
    print('DEBUG: Shipping address: ${state.shippingAddress}');
    print('DEBUG: Billing address: ${state.billingAddress}');
    print('DEBUG: Payment method: ${state.selectedPaymentMethod}');
    print('DEBUG: Shipping option: ${state.selectedShipping}');

    if (state.shippingAddress == null) {
      errors.add('Please select a shipping address');
    }

    if (state.billingAddress == null) {
      errors.add('Please select a billing address');
    }

    if (state.selectedPaymentMethod == null) {
      errors.add('Please select a payment method');
    }

    if (state.selectedShipping == null) {
      errors.add('Please select a shipping option');
    }

    // Additional validation for addresses
    if (state.shippingAddress != null) {
      if (state.shippingAddress!.street.trim().isEmpty) {
        errors.add('Shipping address is incomplete');
      }
      if (state.shippingAddress!.city.trim().isEmpty) {
        errors.add('Shipping city is required');
      }
      if (state.shippingAddress!.phone.toString().trim().isEmpty) {
        errors.add('Shipping phone number is required');
      }
    }

    if (state.billingAddress != null) {
      if (state.billingAddress!.street.trim().isEmpty) {
        errors.add('Billing address is incomplete');
      }
      if (state.billingAddress!.city.trim().isEmpty) {
        errors.add('Billing city is required');
      }
      if (state.billingAddress!.phone.toString().trim().isEmpty) {
        errors.add('Billing phone number is required');
      }
    }

    print('DEBUG: Validation errors found: ${errors.length}');
    return errors;
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text('Please Complete Required Fields'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  errors
                      .map(
                        (error) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(error)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _handlePaymentResponse(Map<String, dynamic> response) {
    print('DEBUG: _handlePaymentResponse called with: $response');
    final isRedirect = response['is_redirect'] as bool? ?? false;
    final url = response['url'] as String?;
    final orderNumber = response['order_number'] as int?;
    final feedbackToken = response['feedback_token'] as String?;
    final paymentMethod =
        ref.read(checkoutProvider).selectedPaymentMethod?.name ?? '';

    print(
      'DEBUG: Payment response - isRedirect: $isRedirect, url: $url, orderNumber: $orderNumber, paymentMethod: $paymentMethod',
    );

    if (isRedirect && url != null) {
      _showRedirectDialog(url, orderNumber);
    } else if (paymentMethod == 'bank_transfer') {
      _showBankTransferDialog(orderNumber, feedbackToken: feedbackToken);
    } else {
      _showPaymentConfirmationDialog(orderNumber, feedbackToken: feedbackToken);
    }
  }

  void _openPaymentWebView(String url, {int? orderNumber}) {
    final qp = <String, String>{'url': url};
    if (orderNumber != null) qp['orderNumber'] = orderNumber.toString();
    qp['successPrefix'] = '/en/account/order';
    if (mounted)
      context.go(Uri(path: '/payment_webview', queryParameters: qp).toString());
  }

  void _showRedirectDialog(String url, int? orderNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text('Complete Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.payment,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'You will be redirected to complete your payment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                if (orderNumber != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Order #$orderNumber',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openPaymentWebView(url, orderNumber: orderNumber);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Continue to Payment'),
              ),
            ],
          ),
    );
  }

  void _showPaymentConfirmationDialog(
    int? orderNumber, {
    String? feedbackToken,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildConfirmationSheet(
            icon: Icons.check_circle,
            title: 'Order Placed Successfully!',
            orderNumber: orderNumber,
            feedbackToken: feedbackToken,
            message:
                'Please check your email for order confirmation and further instructions.',
          ),
    );
  }

  void _showBankTransferDialog(int? orderNumber, {String? feedbackToken}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bank Transfer Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (orderNumber != null)
                    Text(
                      'Order #$orderNumber',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please transfer the exact amount to one of the following accounts:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ..._bankAccounts.map(
                    (acc) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBankAccount(
                        acc['name']!,
                        acc['account']!,
                        acc['bic']!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please include your order number in the payment reference.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildViewOrdersButton(
                    orderNumber: orderNumber,
                    feedbackToken: feedbackToken,
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildConfirmationSheet({
    required IconData icon,
    required String title,
    required String message,
    int? orderNumber,
    String? feedbackToken,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (orderNumber != null)
              Text(
                'Order #$orderNumber',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildViewOrdersButton(
              orderNumber: orderNumber,
              feedbackToken: feedbackToken,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewOrdersButton({int? orderNumber, String? feedbackToken}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          if (orderNumber != null) {
            // Navigate to marketing feedback screen
            final uri =
                feedbackToken != null
                    ? '/feedback/$orderNumber?token=$feedbackToken'
                    : '/feedback/$orderNumber';
            context.push(uri);
          } else {
            context.push('/orders');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Continue'),
      ),
    );
  }

  Widget _buildBankAccount(String bankName, String accountNumber, String bic) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bankName, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Account: $accountNumber',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            'BIC: $bic',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAddress(AddressType type) {
    context.pushNamed(
      'add_address',
      queryParameters: {'redirect': '/checkout_steps'},
    );
  }

  double _calculateTotalAmount(CheckoutState checkoutState, CartEntity cart) {
    if (cart.isEmpty) return 0.0;

    final subtotal = cart.calculatedSubtotal;
    final shippingCost = checkoutState.selectedShipping?.price ?? 0.0;
    // Add other costs like taxes, fees, etc. if needed

    return subtotal + shippingCost;
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(checkoutProvider);
    final cartAsync = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'CHECKOUT',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'STEP ${_currentStep + 1}/$_totalSteps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: _buildStepIndicator(primaryColor),
        ),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: Stack(
          children: [
            cartAsync.when(
              data: (cart) {
                if (cart.isEmpty) return const _EmptyCartWidget();
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged:
                              (index) => setState(() => _currentStep = index),
                          children: [
                            _buildStep1ShippingAddress(checkoutState),
                            _buildStep2BillingAddress(checkoutState),
                            _buildStep3Shipping(checkoutState),
                            _buildStep4Payment(checkoutState, cart),
                            _buildStep5OrderSummary(checkoutState, cart),
                          ],
                        ),
                      ),
                      _buildNavigation(primaryColor),
                    ],
                  ),
                );
              },
              loading: () => const AppLoading(),
              error:
                  (error, stackTrace) => app_error.AppError(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(cartProvider),
                  ),
            ),
            // Loading overlay when processing checkout
            if (checkoutState.isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Processing your order...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait while we process your payment',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Step builders
  Widget _buildStep1ShippingAddress(CheckoutState checkoutState) =>
      CheckoutStepContent(
        title: 'Shipping Address',
        subtitle: 'Where should we deliver your order?',
        icon: Icons.local_shipping,
        child: SingleChildScrollView(
          controller: _scrollControllers[0],
          child: CheckoutAddressSection(
            title: 'Shipping Address',
            addressType: AddressType.shipping,
            selectedAddress: checkoutState.shippingAddress,
            onAddressSelected:
                (address) => ref
                    .read(checkoutProvider.notifier)
                    .setShippingAddress(address),
            onAddNewAddress: () => _navigateToAddAddress(AddressType.shipping),
          ),
        ),
      );

  Widget _buildStep2BillingAddress(CheckoutState checkoutState) =>
      CheckoutStepContent(
        title: 'Billing Address',
        subtitle: 'Where should we send the invoice?',
        icon: Icons.receipt,
        child: SingleChildScrollView(
          controller: _scrollControllers[1],
          child: CheckoutAddressSection(
            title: 'Billing Address',
            addressType: AddressType.billing,
            selectedAddress: checkoutState.billingAddress,
            onAddressSelected:
                (address) => ref
                    .read(checkoutProvider.notifier)
                    .setBillingAddress(address),
            onAddNewAddress: () => _navigateToAddAddress(AddressType.billing),
          ),
        ),
      );

  Widget _buildStep3Shipping(CheckoutState checkoutState) {
    return CheckoutStepContent(
      title: 'Shipping Options',
      subtitle: 'Choose your delivery method',
      icon: Icons.local_shipping,
      child: SingleChildScrollView(
        controller: _scrollControllers[2],
        child: CheckoutShippingSection(
          selectedShipping: checkoutState.selectedShipping,
          onShippingSelected:
              (shipping) => ref
                  .read(checkoutProvider.notifier)
                  .setSelectedShipping(shipping),
        ),
      ),
    );
  }

  Widget _buildStep4Payment(CheckoutState checkoutState, CartEntity cart) {
    return CheckoutStepContent(
      title: 'Payment Method',
      subtitle: 'Choose how you want to pay',
      icon: Icons.payment,
      child: SingleChildScrollView(
        controller: _scrollControllers[3],
        child: Column(
          children: [
            CheckoutPaymentSection(
              selectedPaymentMethod: checkoutState.selectedPaymentMethod,
              onPaymentMethodSelected:
                  (method) => ref
                      .read(checkoutProvider.notifier)
                      .setPaymentMethod(method),
              totalAmount: _calculateTotalAmount(checkoutState, cart),
            ),
            OrderNotesField(
              controller: _orderNotesController,
              onChanged:
                  (notes) =>
                      ref.read(checkoutProvider.notifier).setOrderNotes(notes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5OrderSummary(
    CheckoutState checkoutState,
    CartEntity cart,
  ) => CheckoutStepContent(
    title: 'Order Summary',
    subtitle: 'Review your order before placing it',
    icon: Icons.shopping_cart,
    child: SingleChildScrollView(
      controller: _scrollControllers[4],
      child: CheckoutSummarySection(
        cart: cart,
        shippingCost: checkoutState.selectedShipping?.price ?? 0.0,
      ),
    ),
  );

  // Navigation
  Widget _buildNavigation(Color primaryColor) {
    final checkoutState = ref.watch(checkoutProvider);
    final isProcessing = checkoutState.isProcessing;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withOpacity(0.3)
                    : primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0 && !isProcessing)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: Icon(Icons.arrow_back_ios, size: 16),
                label: const Text(
                  'BACK',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  foregroundColor: isDark ? Colors.white : primaryColor,
                  side: BorderSide(
                    color: isDark ? Colors.grey[400]! : primaryColor,
                    width: 1.5,
                  ),
                  backgroundColor:
                      isDark ? Colors.grey[900] : Colors.transparent,
                ),
              ),
            ),
          if (_currentStep > 0 && !isProcessing) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: (isProcessing || !_canProceed()) ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                backgroundColor:
                    isProcessing
                        ? (isDark ? Colors.grey[700] : Colors.grey[400])
                        : primaryColor,
                foregroundColor:
                    isProcessing
                        ? (isDark ? Colors.grey[300] : Colors.grey[600])
                        : Colors.white,
                elevation: isProcessing ? 0 : 2,
                shadowColor: primaryColor.withOpacity(0.3),
              ),
              child:
                  isProcessing
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.grey[300]! : Colors.grey[600]!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'PROCESSING...',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        _currentStep == _totalSteps - 1
                            ? 'PLACE ORDER'
                            : 'CONTINUE',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color primaryColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              decoration: BoxDecoration(
                color:
                    isActive
                        ? primaryColor
                        : isCompleted
                        ? primaryColor.withOpacity(0.8)
                        : isDark
                        ? Theme.of(context).colorScheme.outline
                        : Colors.white70,
                borderRadius: BorderRadius.circular(4),
                boxShadow:
                    isActive
                        ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
              child:
                  isActive
                      ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      )
                      : null,
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyCartWidget extends StatelessWidget {
  const _EmptyCartWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Your cart is empty',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
