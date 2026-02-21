import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/repositories/settings_repository_impl.dart';

class GetSettingsUseCase {
  final SettingsRepository _repository;

  GetSettingsUseCase(this._repository);

  Future<Either<Failure, SettingsEntity>> execute() {
    return _repository.getSettings();
  }
}

// Provider
final getSettingsUseCaseProvider = Provider<GetSettingsUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettingsUseCase(repository);
});
