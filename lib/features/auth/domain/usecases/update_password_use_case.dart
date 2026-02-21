import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';

class UpdatePasswordUseCase {
  final AuthRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String password,
    required String passwordConfirmation,
    required String token,
    required String email,
  }) async {
    return await _repository.updatePassword(
      password: password,
      passwordConfirmation: passwordConfirmation,
      token: token,
      email: email,
    );
  }
}

final updatePasswordUseCaseProvider = Provider<UpdatePasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdatePasswordUseCase(repository);
});
