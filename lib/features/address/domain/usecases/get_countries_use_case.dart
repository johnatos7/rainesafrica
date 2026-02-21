import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/repositories/address_repository_impl.dart';

class GetCountriesUseCase {
  final CountryRepository _repository;

  GetCountriesUseCase(this._repository);

  Future<Either<Failure, List<CountryEntity>>> execute() {
    return _repository.getCountries();
  }
}

class GetStatesByCountryUseCase {
  final CountryRepository _repository;

  GetStatesByCountryUseCase(this._repository);

  Future<Either<Failure, List<StateEntity>>> execute(int countryId) {
    return _repository.getStatesByCountry(countryId);
  }
}

// Providers
final getCountriesUseCaseProvider = Provider<GetCountriesUseCase>((ref) {
  final repository = ref.watch(countryRepositoryProvider);
  return GetCountriesUseCase(repository);
});

final getStatesByCountryUseCaseProvider = Provider<GetStatesByCountryUseCase>((
  ref,
) {
  final repository = ref.watch(countryRepositoryProvider);
  return GetStatesByCountryUseCase(repository);
});
