import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/usecases/get_wallet.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/usecases/get_wallet_transactions.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/repositories/wallet_repository.dart';

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((
  ref,
) {
  return WalletNotifier(
    getWallet: GetWallet(repository: ref.read(walletRepositoryProvider)),
    getWalletTransactions: GetWalletTransactions(
      repository: ref.read(walletRepositoryProvider),
    ),
    repository: ref.read(walletRepositoryProvider),
  );
});

class WalletNotifier extends StateNotifier<WalletState> {
  final GetWallet getWallet;
  final GetWalletTransactions getWalletTransactions;
  final WalletRepository repository;

  WalletNotifier({
    required this.getWallet,
    required this.getWalletTransactions,
    required this.repository,
  }) : super(const WalletState());

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getWallet();

    if (result.failure != null) {
      state = state.copyWith(isLoading: false, error: result.failure!.message);
    } else {
      state = state.copyWith(
        isLoading: false,
        wallet: result.data,
        error: null,
      );
    }
  }

  Future<void> loadTransactions({int page = 1, int paginate = 20}) async {
    if (page == 1) {
      state = state.copyWith(
        isLoadingTransactions: true,
        transactionError: null,
      );
    } else {
      state = state.copyWith(isLoadingMoreTransactions: true);
    }

    final result = await getWalletTransactions(page: page, paginate: paginate);

    if (result.failure != null) {
      state = state.copyWith(
        isLoadingTransactions: false,
        isLoadingMoreTransactions: false,
        transactionError: result.failure!.message,
      );
    } else {
      final transactions = result.data!;
      final allTransactions =
          page == 1
              ? transactions.data
              : [...state.transactions, ...transactions.data];

      state = state.copyWith(
        isLoadingTransactions: false,
        isLoadingMoreTransactions: false,
        transactions: allTransactions,
        currentPage: transactions.currentPage,
        lastPage: transactions.lastPage,
        hasNextPage: transactions.nextPageUrl != null,
        transactionError: null,
      );
    }
  }

  void refreshWallet() {
    loadWallet();
    loadTransactions();
  }

  Future<String?> requestRefundAll() async {
    if (state.wallet == null || state.wallet!.balance <= 0) {
      return 'No funds to refund';
    }

    state = state.copyWith(isRequestingRefund: true, refundError: null);

    final failure = await repository.refundAll();

    if (failure != null) {
      state = state.copyWith(
        isRequestingRefund: false,
        refundError: failure.message,
      );
      return failure.message;
    }

    // Refresh wallet after successful refund request
    await loadWallet();
    state = state.copyWith(isRequestingRefund: false, lastRefundSuccess: true);
    return null;
  }
}

class WalletState {
  final bool isLoading;
  final bool isLoadingTransactions;
  final bool isLoadingMoreTransactions;
  final bool isRequestingRefund;
  final WalletEntity? wallet;
  final List<WalletTransactionEntity> transactions;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final String? error;
  final String? transactionError;
  final String? refundError;
  final bool lastRefundSuccess;

  const WalletState({
    this.isLoading = false,
    this.isLoadingTransactions = false,
    this.isLoadingMoreTransactions = false,
    this.isRequestingRefund = false,
    this.wallet,
    this.transactions = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasNextPage = false,
    this.error,
    this.transactionError,
    this.refundError,
    this.lastRefundSuccess = false,
  });

  WalletState copyWith({
    bool? isLoading,
    bool? isLoadingTransactions,
    bool? isLoadingMoreTransactions,
    bool? isRequestingRefund,
    WalletEntity? wallet,
    List<WalletTransactionEntity>? transactions,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? error,
    String? transactionError,
    String? refundError,
    bool? lastRefundSuccess,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingTransactions:
          isLoadingTransactions ?? this.isLoadingTransactions,
      isLoadingMoreTransactions:
          isLoadingMoreTransactions ?? this.isLoadingMoreTransactions,
      isRequestingRefund: isRequestingRefund ?? this.isRequestingRefund,
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      error: error ?? this.error,
      transactionError: transactionError ?? this.transactionError,
      refundError: refundError ?? this.refundError,
      lastRefundSuccess: lastRefundSuccess ?? this.lastRefundSuccess,
    );
  }
}
