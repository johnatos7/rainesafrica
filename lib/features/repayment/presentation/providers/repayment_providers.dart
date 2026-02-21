import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_request_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_response_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/usecases/process_repayment_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/data/providers/repayment_providers.dart'
    as data_providers;
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

// Repayment State
class RepaymentState {
  final bool isLoading;
  final bool isProcessing;
  final RepaymentResponseEntity? repaymentResponse;
  final String? errorMessage;
  final PaymentMethodEntity? selectedPaymentMethod;

  const RepaymentState({
    this.isLoading = false,
    this.isProcessing = false,
    this.repaymentResponse,
    this.errorMessage,
    this.selectedPaymentMethod,
  });

  RepaymentState copyWith({
    bool? isLoading,
    bool? isProcessing,
    RepaymentResponseEntity? repaymentResponse,
    String? errorMessage,
    PaymentMethodEntity? selectedPaymentMethod,
  }) {
    return RepaymentState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      repaymentResponse: repaymentResponse ?? this.repaymentResponse,
      errorMessage: errorMessage,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}

// Repayment Notifier
class RepaymentNotifier extends StateNotifier<RepaymentState> {
  final ProcessRepaymentUseCase _processRepaymentUseCase;

  RepaymentNotifier({required ProcessRepaymentUseCase processRepaymentUseCase})
    : _processRepaymentUseCase = processRepaymentUseCase,
      super(const RepaymentState());

  void setPaymentMethod(PaymentMethodEntity paymentMethod) {
    state = state.copyWith(selectedPaymentMethod: paymentMethod);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearResponse() {
    state = state.copyWith(repaymentResponse: null);
  }

  Future<void> processRepayment({
    required String orderNumber,
    required double amount,
    required String currency,
    required String currencyCode,
    required String currencySymbol,
  }) async {
    print('🎯 REPAYMENT PROVIDER: Starting repayment process');
    print('🎯 REPAYMENT PROVIDER: Order number: $orderNumber');
    print('🎯 REPAYMENT PROVIDER: Amount: $amount');
    print('🎯 REPAYMENT PROVIDER: Currency: $currency');

    if (state.selectedPaymentMethod == null) {
      print('❌ REPAYMENT PROVIDER: No payment method selected');
      state = state.copyWith(errorMessage: 'Please select a payment method');
      return;
    }

    print(
      '🎯 REPAYMENT PROVIDER: Payment method: ${state.selectedPaymentMethod!.name}',
    );
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      print('🎯 REPAYMENT PROVIDER: Creating request entity');
      final request = RepaymentRequestEntity(
        paymentMethod: state.selectedPaymentMethod!.name,
        returnUrl: 'https://raines.africa/en/account/order/details',
        cancelUrl: 'https://raines.africa',
        orderNumber: orderNumber,
        amount: amount,
        total: amount,
        grandTotal: amount,
        payableTotal: amount,
        payableAmount: amount,
        amountToPay: amount,
        currency: currency,
        currencyCode: currencyCode,
        currencySymbol: currencySymbol,
        baseAmount: amount,
        fee: 0.0,
        subTotal: 0.0,
        shippingTotal: 0.0,
        deliveryPrice: 0.0,
        taxTotal: 0.0,
        couponTotalDiscount: 0.0,
        walletBalance: 0.0,
        pointsAmount: 0.0,
      );

      print('🎯 REPAYMENT PROVIDER: Calling use case');
      final result = await _processRepaymentUseCase(request);

      result.fold(
        (failure) {
          print('❌ REPAYMENT PROVIDER: Failure received: ${failure.message}');
          state = state.copyWith(
            isProcessing: false,
            errorMessage: failure.message,
          );
        },
        (response) {
          print('✅ REPAYMENT PROVIDER: Success! Response received');
          print('✅ REPAYMENT PROVIDER: Order number: ${response.orderNumber}');
          print('✅ REPAYMENT PROVIDER: Is redirect: ${response.isRedirect}');
          print('✅ REPAYMENT PROVIDER: Redirect URL: ${response.redirectUrl}');
          state = state.copyWith(
            isProcessing: false,
            repaymentResponse: response,
            errorMessage: null,
          );
        },
      );
    } catch (e, stackTrace) {
      print('❌ REPAYMENT PROVIDER: Exception caught: $e');
      print('❌ REPAYMENT PROVIDER: Stack trace: $stackTrace');
      state = state.copyWith(isProcessing: false, errorMessage: e.toString());
    }
  }
}

// Repayment Provider
final repaymentProvider =
    StateNotifierProvider<RepaymentNotifier, RepaymentState>((ref) {
      final processRepaymentUseCase = ref.watch(
        data_providers.processRepaymentUseCaseProvider,
      );
      return RepaymentNotifier(
        processRepaymentUseCase: processRepaymentUseCase,
      );
    });
