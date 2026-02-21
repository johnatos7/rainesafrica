import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/repositories/address_repository_impl.dart';

class CreateAddressUseCase {
  final AddressRepository _repository;

  CreateAddressUseCase(this._repository);

  Future<Either<Failure, AddressEntity>> execute(AddressFormData addressData) {
    return _repository.createAddress(addressData);
  }
}

class UpdateAddressUseCase {
  final AddressRepository _repository;

  UpdateAddressUseCase(this._repository);

  Future<Either<Failure, AddressEntity>> execute(
    int addressId,
    AddressFormData addressData,
  ) {
    return _repository.updateAddress(addressId, addressData);
  }
}

class DeleteAddressUseCase {
  final AddressRepository _repository;

  DeleteAddressUseCase(this._repository);

  Future<Either<Failure, void>> execute(int addressId) {
    return _repository.deleteAddress(addressId);
  }
}

class SetDefaultAddressUseCase {
  final AddressRepository _repository;

  SetDefaultAddressUseCase(this._repository);

  Future<Either<Failure, AddressEntity>> execute(int addressId) {
    return _repository.setDefaultAddress(addressId);
  }
}

// Providers
final createAddressUseCaseProvider = Provider<CreateAddressUseCase>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return CreateAddressUseCase(repository);
});

final updateAddressUseCaseProvider = Provider<UpdateAddressUseCase>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return UpdateAddressUseCase(repository);
});

final deleteAddressUseCaseProvider = Provider<DeleteAddressUseCase>((ref) {
  final repository = ref.watch(addressRepositoryProvider);
  return DeleteAddressUseCase(repository);
});

final setDefaultAddressUseCaseProvider = Provider<SetDefaultAddressUseCase>((
  ref,
) {
  final repository = ref.watch(addressRepositoryProvider);
  return SetDefaultAddressUseCase(repository);
});
