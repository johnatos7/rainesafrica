import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/repositories/address_repository_impl.dart';

class GetUserAddressesUseCase {
  final AddressRepository _repository;

  GetUserAddressesUseCase(this._repository);

  Future<Either<Failure, List<AddressEntity>>> execute() {
    return _repository.getUserAddresses();
  }
}

// Provider
final getUserAddressesUseCaseProvider = Provider<GetUserAddressesUseCase>((
  ref,
) {
  final repository = ref.watch(addressRepositoryProvider);
  return GetUserAddressesUseCase(repository);
});
