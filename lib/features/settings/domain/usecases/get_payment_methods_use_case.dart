import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/repositories/settings_repository_impl.dart';

class GetPaymentMethodsUseCase {
  final SettingsRepository _repository;

  GetPaymentMethodsUseCase(this._repository);

  Future<Either<Failure, List<PaymentMethodEntity>>> execute() async {
    final result = await _repository.getSettings();
    return result.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.paymentMethods),
    );
  }

  Future<Either<Failure, List<PaymentMethodEntity>>>
  getEnabledPaymentMethods() async {
    final result = await execute();
    return result.fold(
      (failure) => Left(failure),
      (paymentMethods) =>
          Right(paymentMethods.where((method) => method.isEnabled).toList()),
    );
  }
}

// Provider
final getPaymentMethodsUseCaseProvider = Provider<GetPaymentMethodsUseCase>((
  ref,
) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetPaymentMethodsUseCase(repository);
});
