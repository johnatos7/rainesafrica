import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/repositories/currency_repository.dart';

class GetSelectedCurrencyUseCase {
  final CurrencyRepository _repository;

  GetSelectedCurrencyUseCase(this._repository);

  Future<Either<Failure, CurrencyEntity?>> call() async {
    return await _repository.getSelectedCurrency();
  }
}
