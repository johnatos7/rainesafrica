import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/models/currency_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/repositories/currency_repository.dart';

class GetCurrenciesUseCase {
  final CurrencyRepository _repository;

  GetCurrenciesUseCase(this._repository);

  Future<Either<Failure, PaginatedCurrencyResponse>> call({
    int page = 1,
  }) async {
    return await _repository.getCurrencies(page: page);
  }
}
