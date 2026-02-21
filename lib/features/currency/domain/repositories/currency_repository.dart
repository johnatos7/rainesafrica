import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/models/currency_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, PaginatedCurrencyResponse>> getCurrencies({
    int page = 1,
  });

  Future<Either<Failure, List<CurrencyEntity>>> getCachedCurrencies();
  Future<Either<Failure, void>> cacheCurrencies(
    List<CurrencyEntity> currencies,
  );
  Future<Either<Failure, CurrencyEntity?>> getSelectedCurrency();
  Future<Either<Failure, void>> setSelectedCurrency(CurrencyEntity currency);
}
