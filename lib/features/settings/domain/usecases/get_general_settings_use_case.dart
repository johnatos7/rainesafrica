import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/repositories/settings_repository_impl.dart';

class GetGeneralSettingsUseCase {
  final SettingsRepository _repository;

  GetGeneralSettingsUseCase(this._repository);

  Future<Either<Failure, GeneralSettingsEntity>> execute() async {
    final result = await _repository.getSettings();
    return result.fold(
      (failure) => Left(failure),
      (settings) => Right(settings.general),
    );
  }
}

// Provider
final getGeneralSettingsUseCaseProvider = Provider<GetGeneralSettingsUseCase>((
  ref,
) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetGeneralSettingsUseCase(repository);
});
