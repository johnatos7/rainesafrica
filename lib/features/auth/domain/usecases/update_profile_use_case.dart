import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> execute({
    required String name,
    required String email,
    required String countryCode,
    required int phone,
  }) async {
    return await _repository.updateProfile(
      name: name,
      email: email,
      countryCode: countryCode,
      phone: phone,
    );
  }
}

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});
