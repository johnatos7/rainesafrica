import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/usecases/process_checkout_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/models/checkout_request_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/providers/cart_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/providers/points_provider.dart';

// Checkout State
class CheckoutState {
  final AddressEntity? shippingAddress;
  final AddressEntity? billingAddress;
  final PaymentMethodEntity? selectedPaymentMethod;
  final ShippingOptionEntity? selectedShipping;
  final String orderNotes;
  final String couponCode;
  final bool usePoints;
  final bool useWallet;
  final bool isProcessing;
  final Map<String, dynamic>? checkoutResponse;
  final String? error;

  const CheckoutState({
    this.shippingAddress,
    this.billingAddress,
    this.selectedPaymentMethod,
    this.selectedShipping,
    this.orderNotes = '',
    this.couponCode = '',
    this.usePoints = false,
    this.useWallet = false,
    this.isProcessing = false,
    this.checkoutResponse,
    this.error,
  });

  CheckoutState copyWith({
    AddressEntity? shippingAddress,
    AddressEntity? billingAddress,
    PaymentMethodEntity? selectedPaymentMethod,
    ShippingOptionEntity? selectedShipping,
    String? orderNotes,
    String? couponCode,
    bool? usePoints,
    bool? useWallet,
    bool? isProcessing,
    Map<String, dynamic>? checkoutResponse,
    String? error,
  }) {
    return CheckoutState(
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedShipping: selectedShipping ?? this.selectedShipping,
      orderNotes: orderNotes ?? this.orderNotes,
      couponCode: couponCode ?? this.couponCode,
      usePoints: usePoints ?? this.usePoints,
      useWallet: useWallet ?? this.useWallet,
      isProcessing: isProcessing ?? this.isProcessing,
      checkoutResponse: checkoutResponse ?? this.checkoutResponse,
      error: error ?? this.error,
    );
  }

  bool get isFormValid {
    return shippingAddress != null &&
        billingAddress != null &&
        selectedPaymentMethod != null &&
        selectedShipping != null;
  }
}

// Checkout Notifier
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final ProcessCheckoutUseCase _processCheckoutUseCase;
  final Ref _ref;

  CheckoutNotifier(this._processCheckoutUseCase, this._ref)
    : super(const CheckoutState());

  void initializeCheckout() {
    // Initialize with default values if needed
    state = state.copyWith();
  }

  void setShippingAddress(AddressEntity? address) {
    state = state.copyWith(shippingAddress: address);
  }

  void setBillingAddress(AddressEntity? address) {
    state = state.copyWith(billingAddress: address);
  }

  void setPaymentMethod(PaymentMethodEntity? method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setSelectedShipping(ShippingOptionEntity? shipping) {
    state = state.copyWith(selectedShipping: shipping);
  }

  void setOrderNotes(String notes) {
    state = state.copyWith(orderNotes: notes);
  }

  void setCouponCode(String couponCode) {
    state = state.copyWith(couponCode: couponCode);
  }

  void setUsePoints(bool value) {
    state = state.copyWith(usePoints: value);
  }

  void setUseWallet(bool value) {
    state = state.copyWith(useWallet: value);
  }

  Future<void> processCheckout() async {
    print('DEBUG: processCheckout called');
    print('DEBUG: Current state: $state');

    if (!state.isFormValid) {
      print('DEBUG: Form validation failed - not all required fields filled');
      throw Exception('Please fill in all required fields');
    }

    print('DEBUG: Setting processing state to true');
    state = state.copyWith(isProcessing: true, error: null);

    try {
      print('DEBUG: Getting cart data...');
      // Get cart data
      final cartAsync = _ref.read(cartProvider);
      final cart = cartAsync.value;

      print('DEBUG: Cart data: $cart');
      if (cart == null || cart.items.isEmpty) {
        print('DEBUG: Cart is empty or null');
        throw Exception('Cart is empty');
      }

      print('DEBUG: Creating checkout request...');

      // Get selected currency (fallback to USD if none selected)
      final currencyState = _ref.read(currencyProvider);
      final selectedCurrency = currencyState.selectedCurrency;
      final currencyCode = selectedCurrency?.code ?? 'USD';
      final currencySymbol = selectedCurrency?.symbol ?? '\$';
      final subtotal = cart.calculatedSubtotal;
      final exchangeRate =
          currencyState.selectedCurrency?.exchangeRateAsDouble ?? 1.0;

      final subtotalInUsd = subtotal / exchangeRate;

      const double defaultUsdShipping = 10.0;
      final double shippingFee =
          subtotalInUsd >= 100.0 ? 0.0 : defaultUsdShipping * exchangeRate;
      final double shippingFeeUsd =
          subtotal >= 100.0 ? 0.0 : defaultUsdShipping;

      // Calculate fast shipping fee from cart items
      final double fastShippingFee = cart.calculatedExpeditedShippingFee;

      // Calculate grand_total in selected currency (for display and other calculations)
      final double grand_total =
          subtotal +
          shippingFee +
          state.selectedShipping!.price +
          fastShippingFee;

      // Calculate grand_total in USD for orderTotal and grandTotal fields
      final double grand_total_in_usd =
          subtotal +
          shippingFeeUsd +
          state.selectedShipping!.price +
          fastShippingFee;

      if (selectedCurrency == null) {
        print(
          'DEBUG: No currency selected, falling back to $currencyCode ($currencySymbol)',
        );
      } else {
        print('DEBUG: Using currency: $currencyCode ($currencySymbol)');
      }

      // Credits calculation (points + wallet) when opted in
      final settings = _ref.read(settingsProvider).value;
      final walletState = _ref.read(walletProvider);
      final pointsState = _ref.read(pointsProvider);

      final pointRatio =
          double.tryParse(settings?.walletPoints.pointCurrencyRatio ?? '') ??
          0.0;
      final userPoints = pointsState.points?.balance ?? 0.0;
      final walletBalanceVal = walletState.wallet?.balance ?? 0.0;

      final usePoints = state.usePoints && pointRatio > 0;
      final useWallet = state.useWallet;

      final pointsValue = usePoints ? (userPoints / pointRatio) : 0.0;
      final walletValue = useWallet ? walletBalanceVal : 0.0;
      final totalCredits = pointsValue + walletValue;

      // If fully covered by credits, force wallet payment and short-circuit
      final walletPayment = totalCredits >= grand_total;
      // if (totalCredits >= grand_total) {
      //   final response = {
      //     'order_number': DateTime.now().millisecondsSinceEpoch % 10000,
      //     'payment_method': 'wallet',
      //     'payment_status': 'COMPLETED',
      //   };
      //   state = state.copyWith(isProcessing: false, checkoutResponse: response);
      //   return;
      // }
      print('DEBUG: grand_total_in_usd: $grand_total_in_usd');

      // Create checkout request
      final request = CheckoutRequestModel(
        billingAddressId: state.billingAddress!.id,
        shippingAddressId: state.shippingAddress!.id,
        paymentMethod:
            walletPayment ? 'wallet' : state.selectedPaymentMethod!.name,
        deliveryTitle: state.selectedShipping!.title,
        deliveryDescription: state.selectedShipping!.description,
        deliveryPrice: state.selectedShipping!.price,
        couponCode: state.couponCode,
        pointsAmount: usePoints ? 1 : 0,
        note: state.orderNotes,
        currency: currencyCode,
        currencySymbol: currencySymbol,
        returnUrl: 'https://raines.africa/en/account/order/details',
        cancelUrl: 'https://raines.africa',
        shippingTotal: shippingFeeUsd,
        taxTotal: 0.0,
        orderTotal: grand_total_in_usd,
        grandTotal: grand_total_in_usd,
        subTotal: grand_total_in_usd,
        walletFlag: useWallet ? 1 : 0,
        products:
            cart.items.map((item) {
              final productModel = CheckoutProductModel(
                productId: item.productId ?? 0,
                variationId: item.selectedVariationId,
                selectedAttributeIds: item.selectedAttributeIds,
                variationDisplayName: item.variationDisplayName,
                quantity: item.quantity,
                price: item.unitPrice,
                itemShippingMethod: item.itemShippingMethod,
              );

              // Debug: Print product JSON to verify format
              print('DEBUG: Product JSON: ${productModel.toJson()}');

              return productModel;
            }).toList(),
      );

      print('DEBUG: Checkout request created: ${request.toJson()}');
      print('DEBUG: Calling processCheckoutUseCase...');
      final response = await _processCheckoutUseCase(request);
      print('DEBUG: Checkout use case completed with response: $response');

      print('DEBUG: Setting processing state to false and saving response');
      state = state.copyWith(isProcessing: false, checkoutResponse: response);
      print('DEBUG: Checkout process completed successfully');
    } catch (e) {
      print('DEBUG: Checkout failed with error: $e');

      state = state.copyWith(isProcessing: false, error: e.toString());
      rethrow;
    } finally {
      // Always clear cart after checkout attempt (success or failure)
      print('DEBUG: Clearing cart after checkout attempt...');
      try {
        await _ref.read(clearCartProvider.future);
        print('DEBUG: Cart cleared successfully');
      } catch (e) {
        print('DEBUG: Failed to clear cart in finally: $e');
        // Do not throw from finally
      }
    }
  }
}

// Providers
final authenticatedApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthenticatedApiClient(secureStorage: secureStorage);
});

final checkoutRepositoryProvider = Provider<CheckoutRepositoryImpl>((ref) {
  final apiClient = ref.watch(authenticatedApiClientProvider);
  final remoteDataSource = CheckoutRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = CheckoutLocalDataSourceImpl();
  return CheckoutRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

final processCheckoutUseCaseProvider = Provider<ProcessCheckoutUseCase>((ref) {
  final repository = ref.watch(checkoutRepositoryProvider);
  return ProcessCheckoutUseCase(repository);
});

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    final useCase = ref.watch(processCheckoutUseCaseProvider);
    return CheckoutNotifier(useCase, ref);
  },
);
