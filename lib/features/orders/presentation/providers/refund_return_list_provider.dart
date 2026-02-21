import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/refund_return_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/providers/refund_return_providers.dart';

// Refund List State
class RefundListState {
  final bool isLoading;
  final List<RefundListItemEntity> refunds;
  final String? errorMessage;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  const RefundListState({
    this.isLoading = false,
    this.refunds = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = true,
  });

  RefundListState copyWith({
    bool? isLoading,
    List<RefundListItemEntity>? refunds,
    String? errorMessage,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
  }) {
    return RefundListState(
      isLoading: isLoading ?? this.isLoading,
      refunds: refunds ?? this.refunds,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Return List State
class ReturnListState {
  final bool isLoading;
  final List<ReturnListItemEntity> returns;
  final String? errorMessage;

  const ReturnListState({
    this.isLoading = false,
    this.returns = const [],
    this.errorMessage,
  });

  ReturnListState copyWith({
    bool? isLoading,
    List<ReturnListItemEntity>? returns,
    String? errorMessage,
  }) {
    return ReturnListState(
      isLoading: isLoading ?? this.isLoading,
      returns: returns ?? this.returns,
      errorMessage: errorMessage,
    );
  }
}

// Refund List Notifier
class RefundListNotifier extends StateNotifier<RefundListState> {
  final RefundReturnRepository _repository;

  RefundListNotifier(this._repository) : super(const RefundListState());

  Future<void> loadRefunds({bool refresh = false}) async {
    if (refresh) {
      state = const RefundListState(isLoading: true);
    } else {
      if (state.isLoading || !state.hasMore) return;
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final page = refresh ? 1 : state.currentPage + 1;
      final response = await _repository.getRefunds(page: page);

      if (refresh) {
        state = RefundListState(
          isLoading: false,
          refunds: response.data,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasMore: response.currentPage < response.lastPage,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          refunds: [...state.refunds, ...response.data],
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasMore: response.currentPage < response.lastPage,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() {
    state = const RefundListState();
  }
}

// Return List Notifier
class ReturnListNotifier extends StateNotifier<ReturnListState> {
  final RefundReturnRepository _repository;

  ReturnListNotifier(this._repository) : super(const ReturnListState());

  Future<void> loadReturns({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _repository.getReturns();

      state = state.copyWith(isLoading: false, returns: response.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() {
    state = const ReturnListState();
  }
}

// Providers
final refundListProvider =
    StateNotifierProvider<RefundListNotifier, RefundListState>((ref) {
      final repository = ref.watch(refundReturnRepositoryProvider);
      return RefundListNotifier(repository);
    });

final returnListProvider =
    StateNotifierProvider<ReturnListNotifier, ReturnListState>((ref) {
      final repository = ref.watch(refundReturnRepositoryProvider);
      return ReturnListNotifier(repository);
    });
