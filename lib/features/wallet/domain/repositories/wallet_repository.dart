import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<({Failure? failure, WalletEntity? data})> getWallet();
  Future<({Failure? failure, WalletTransactionsEntity? data})>
  getWalletTransactions({int page = 1, int paginate = 20});
  Future<Failure?> refundAll();
}
