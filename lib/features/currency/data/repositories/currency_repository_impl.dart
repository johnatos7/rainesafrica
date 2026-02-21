import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/datasources/currency_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/datasources/currency_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/models/currency_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/entities/currency_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource _remote;
  final CurrencyLocalDataSource _local;

  CurrencyRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, PaginatedCurrencyResponse>> getCurrencies({
    int page = 1,
  }) async {
    try {
      final data = await _remote.fetchCurrencies(page: page);

      // Cache the currencies
      final entities = data.data.map((model) => model.toEntity()).toList();
      await _local.cacheCurrencies(entities);

      return Right(data);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CurrencyEntity>>> getCachedCurrencies() async {
    try {
      final currencies = await _local.getCachedCurrencies();
      return Right(currencies);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cacheCurrencies(
    List<CurrencyEntity> currencies,
  ) async {
    try {
      await _local.cacheCurrencies(currencies);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CurrencyEntity?>> getSelectedCurrency() async {
    try {
      final currency = await _local.getSelectedCurrency();
      return Right(currency);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setSelectedCurrency(
    CurrencyEntity currency,
  ) async {
    try {
      await _local.cacheSelectedCurrency(currency);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(CacheFailure());
    }
  }
}

// Providers
final currencyApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final currencyRemoteDataSourceProvider = Provider<CurrencyRemoteDataSource>((
  ref,
) {
  final client = ref.watch(currencyApiClientProvider);
  return CurrencyRemoteDataSourceImpl(client);
});

final currencyLocalDataSourceProvider = Provider<CurrencyLocalDataSource>((
  ref,
) {
  return CurrencyLocalDataSourceImpl();
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepositoryImpl(
    ref.watch(currencyRemoteDataSourceProvider),
    ref.watch(currencyLocalDataSourceProvider),
  );
});
