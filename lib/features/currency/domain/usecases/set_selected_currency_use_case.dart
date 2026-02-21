import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/repositories/currency_repository.dart';

class SetSelectedCurrencyUseCase {
  final CurrencyRepository _repository;

  SetSelectedCurrencyUseCase(this._repository);

  Future<Either<Failure, void>> call(CurrencyEntity currency) async {
    return await _repository.setSelectedCurrency(currency);
  }
}
