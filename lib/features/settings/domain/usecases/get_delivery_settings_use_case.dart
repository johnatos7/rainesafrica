import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/repositories/settings_repository_impl.dart';

class GetDeliverySettingsUseCase {
  final SettingsRepository _repository;

  GetDeliverySettingsUseCase(this._repository);

  Future<Either<Failure, DeliverySettingsEntity>> execute() async {
    final result = await _repository.getSettings();
    return result.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.delivery),
    );
  }

  Future<Either<Failure, List<ShippingOptionEntity>>>
  getShippingOptions() async {
    final result = await execute();
    return result.fold(
      (failure) => Left(failure),
      (deliverySettings) => Right(deliverySettings.shippingOptions),
    );
  }

  Future<Either<Failure, List<ShippingOptionEntity>>>
  getFreeShippingOptions() async {
    final result = await getShippingOptions();
    return result.fold(
      (failure) => Left(failure),
      (shippingOptions) =>
          Right(shippingOptions.where((option) => option.price == 0).toList()),
    );
  }

  Future<Either<Failure, List<ShippingOptionEntity>>>
  getPaidShippingOptions() async {
    final result = await getShippingOptions();
    return result.fold(
      (failure) => Left(failure),
      (shippingOptions) =>
          Right(shippingOptions.where((option) => option.price > 0).toList()),
    );
  }
}

// Provider
final getDeliverySettingsUseCaseProvider = Provider<GetDeliverySettingsUseCase>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return GetDeliverySettingsUseCase(repository);
  },
);
