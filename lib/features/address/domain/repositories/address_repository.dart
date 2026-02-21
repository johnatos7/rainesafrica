import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses();
  Future<Either<Failure, AddressEntity>> createAddress(
    AddressFormData addressData,
  );
  Future<Either<Failure, AddressEntity>> updateAddress(
    int addressId,
    AddressFormData addressData,
  );
  Future<Either<Failure, void>> deleteAddress(int addressId);
  Future<Either<Failure, AddressEntity>> setDefaultAddress(int addressId);
}

abstract class CountryRepository {
  Future<Either<Failure, List<CountryEntity>>> getCountries();
  Future<Either<Failure, List<StateEntity>>> getStatesByCountry(int countryId);
}
