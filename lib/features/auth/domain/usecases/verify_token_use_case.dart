import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';

class VerifyTokenUseCase {
  final AuthRepository _repository;

  VerifyTokenUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String email,
    required String token,
  }) async {
    return await _repository.verifyToken(email: email, token: token);
  }
}

final verifyTokenUseCaseProvider = Provider<VerifyTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyTokenUseCase(repository);
});
