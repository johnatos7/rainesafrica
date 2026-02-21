import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletTransactions {
  final WalletRepository repository;

  GetWalletTransactions({required this.repository});

  Future<({Failure? failure, WalletTransactionsEntity? data})> call({
    int page = 1,
    int paginate = 20,
  }) async {
    return await repository.getWalletTransactions(
      page: page,
      paginate: paginate,
    );
  }
}
