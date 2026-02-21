import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/repositories/wallet_repository.dart';

class GetWallet {
  final WalletRepository repository;

  GetWallet({required this.repository});

  Future<({Failure? failure, WalletEntity? data})> call() async {
    return await repository.getWallet();
  }
}
