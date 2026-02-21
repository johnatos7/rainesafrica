import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/data/datasources/payment_account_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/data/repositories/payment_account_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/domain/entities/payment_account_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/domain/repositories/payment_account_repository.dart';

// Providers
final paymentAccountRemoteDataSourceProvider =
    Provider<PaymentAccountRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      final secureStorage = ref.watch(secureStorageProvider);
      return PaymentAccountRemoteDataSourceImpl(apiClient, secureStorage);
    });

final paymentAccountRepositoryProvider = Provider<PaymentAccountRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(paymentAccountRemoteDataSourceProvider);
  return PaymentAccountRepositoryImpl(remoteDataSource);
});

// State classes
class PaymentAccountState {
  final bool isLoading;
  final PaymentAccountEntity? paymentAccount;
  final String? errorMessage;

  const PaymentAccountState({
    this.isLoading = false,
    this.paymentAccount,
    this.errorMessage,
  });

  PaymentAccountState copyWith({
    bool? isLoading,
    PaymentAccountEntity? paymentAccount,
    String? errorMessage,
  }) {
    return PaymentAccountState(
      isLoading: isLoading ?? this.isLoading,
      paymentAccount: paymentAccount ?? this.paymentAccount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier
class PaymentAccountNotifier extends StateNotifier<PaymentAccountState> {
  final PaymentAccountRepository _repository;

  PaymentAccountNotifier(this._repository) : super(const PaymentAccountState());

  Future<void> loadPaymentAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.getPaymentAccount();
    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (paymentAccount) =>
          state = state.copyWith(
            isLoading: false,
            paymentAccount: paymentAccount,
          ),
    );
  }

  Future<void> createPaymentAccount({
    required String bankAccountNo,
    required String bankHolderName,
    required String bankName,
    required String paypalEmail,
    required String swift,
    String? ifsc,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.createPaymentAccount(
      bankAccountNo: bankAccountNo,
      bankHolderName: bankHolderName,
      bankName: bankName,
      paypalEmail: paypalEmail,
      swift: swift,
      ifsc: ifsc,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (paymentAccount) =>
          state = state.copyWith(
            isLoading: false,
            paymentAccount: paymentAccount,
          ),
    );
  }

  Future<void> updatePaymentAccount({
    required int id,
    required String bankAccountNo,
    required String bankHolderName,
    required String bankName,
    required String paypalEmail,
    required String swift,
    String? ifsc,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.updatePaymentAccount(
      id: id,
      bankAccountNo: bankAccountNo,
      bankHolderName: bankHolderName,
      bankName: bankName,
      paypalEmail: paypalEmail,
      swift: swift,
      ifsc: ifsc,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (paymentAccount) =>
          state = state.copyWith(
            isLoading: false,
            paymentAccount: paymentAccount,
          ),
    );
  }

  Future<void> deletePaymentAccount(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _repository.deletePaymentAccount(id);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (_) => state = state.copyWith(isLoading: false, paymentAccount: null),
    );
  }
}

// Provider
final paymentAccountProvider =
    StateNotifierProvider<PaymentAccountNotifier, PaymentAccountState>((ref) {
      final repository = ref.watch(paymentAccountRepositoryProvider);
      return PaymentAccountNotifier(repository);
    });
