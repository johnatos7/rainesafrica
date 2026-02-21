import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> execute({
    required String email,
  }) async {
    return await _repository.forgotPassword(email: email);
  }
}

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ForgotPasswordUseCase(repository);
});
