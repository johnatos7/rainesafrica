import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/refund_return_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/providers/refund_return_providers.dart';

// Refund State
class RefundState {
  final bool isLoading;
  final RefundEntity? refund;
  final String? errorMessage;
  final bool isSuccess;

  const RefundState({
    this.isLoading = false,
    this.refund,
    this.errorMessage,
    this.isSuccess = false,
  });

  RefundState copyWith({
    bool? isLoading,
    RefundEntity? refund,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RefundState(
      isLoading: isLoading ?? this.isLoading,
      refund: refund ?? this.refund,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Return State
class ReturnState {
  final bool isLoading;
  final ReturnEntity? returnEntity;
  final String? errorMessage;
  final bool isSuccess;

  const ReturnState({
    this.isLoading = false,
    this.returnEntity,
    this.errorMessage,
    this.isSuccess = false,
  });

  ReturnState copyWith({
    bool? isLoading,
    ReturnEntity? returnEntity,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ReturnState(
      isLoading: isLoading ?? this.isLoading,
      returnEntity: returnEntity ?? this.returnEntity,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Refund Notifier
class RefundNotifier extends StateNotifier<RefundState> {
  final RefundReturnRepository _repository;

  RefundNotifier(this._repository) : super(const RefundState());

  Future<void> requestRefund(RefundRequestEntity request) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final refund = await _repository.requestRefund(request);
      state = state.copyWith(isLoading: false, refund: refund, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = const RefundState();
  }
}

// Return Notifier
class ReturnNotifier extends StateNotifier<ReturnState> {
  final RefundReturnRepository _repository;

  ReturnNotifier(this._repository) : super(const ReturnState());

  Future<void> requestReturn(ReturnRequestEntity request) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      final returnEntity = await _repository.requestReturn(request);
      state = state.copyWith(
        isLoading: false,
        returnEntity: returnEntity,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  void reset() {
    state = const ReturnState();
  }
}

// Providers
final refundProvider = StateNotifierProvider<RefundNotifier, RefundState>((
  ref,
) {
  final repository = ref.watch(refundReturnRepositoryProvider);
  return RefundNotifier(repository);
});

final returnProvider = StateNotifierProvider<ReturnNotifier, ReturnState>((
  ref,
) {
  final repository = ref.watch(refundReturnRepositoryProvider);
  return ReturnNotifier(repository);
});
