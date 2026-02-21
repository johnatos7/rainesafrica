import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/usecases/get_points.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/usecases/get_points_transactions.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/providers/points_providers.dart';

final pointsProvider = StateNotifierProvider<PointsNotifier, PointsState>((
  ref,
) {
  return PointsNotifier(
    getPoints: GetPoints(repository: ref.read(pointsRepositoryProvider)),
    getPointsTransactions: GetPointsTransactions(
      repository: ref.read(pointsRepositoryProvider),
    ),
  );
});

class PointsNotifier extends StateNotifier<PointsState> {
  final GetPoints getPoints;
  final GetPointsTransactions getPointsTransactions;

  PointsNotifier({required this.getPoints, required this.getPointsTransactions})
    : super(const PointsState());

  Future<void> loadPoints() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getPoints();

    if (result.failure != null) {
      state = state.copyWith(isLoading: false, error: result.failure!.message);
    } else {
      state = state.copyWith(
        isLoading: false,
        points: result.data,
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

    final result = await getPointsTransactions(page: page, paginate: paginate);

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

  void refreshPoints() {
    loadPoints();
    loadTransactions();
  }
}

class PointsState {
  final bool isLoading;
  final bool isLoadingTransactions;
  final bool isLoadingMoreTransactions;
  final PointsEntity? points;
  final List<PointsTransactionEntity> transactions;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final String? error;
  final String? transactionError;

  const PointsState({
    this.isLoading = false,
    this.isLoadingTransactions = false,
    this.isLoadingMoreTransactions = false,
    this.points,
    this.transactions = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasNextPage = false,
    this.error,
    this.transactionError,
  });

  PointsState copyWith({
    bool? isLoading,
    bool? isLoadingTransactions,
    bool? isLoadingMoreTransactions,
    PointsEntity? points,
    List<PointsTransactionEntity>? transactions,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? error,
    String? transactionError,
  }) {
    return PointsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingTransactions:
          isLoadingTransactions ?? this.isLoadingTransactions,
      isLoadingMoreTransactions:
          isLoadingMoreTransactions ?? this.isLoadingMoreTransactions,
      points: points ?? this.points,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      error: error ?? this.error,
      transactionError: transactionError ?? this.transactionError,
    );
  }
}
