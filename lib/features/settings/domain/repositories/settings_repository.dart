import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsEntity>> getSettings();
}
