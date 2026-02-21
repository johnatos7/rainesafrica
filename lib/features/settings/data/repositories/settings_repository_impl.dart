import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  SettingsRepositoryImpl({
    required SettingsRemoteDataSource remoteDataSource,
    required SettingsLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    if (await _networkInfo.isConnected) {
      try {
        // Try to fetch from remote
        final remoteSettings = await _remoteDataSource.fetchSettings();

        // Cache the settings locally
        await _localDataSource.cacheSettings(remoteSettings);

        return Right(remoteSettings);
      } on NetworkException catch (e) {
        // If network fails, try to get from cache
        return await _getFromCacheOrFail(NetworkFailure(message: e.message));
      } on TimeoutException catch (e) {
        return await _getFromCacheOrFail(TimeoutFailure(message: e.message));
      } on UnauthorizedException catch (e) {
        return Left(UnauthorizedFailure(message: e.message));
      } on BadRequestException catch (e) {
        return Left(ValidationFailure(message: e.message));
      } on NotFoundException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: 404));
      } on ServerException catch (e) {
        return await _getFromCacheOrFail(ServerFailure(message: e.message));
      } on AppException catch (e) {
        return await _getFromCacheOrFail(ServerFailure(message: e.message));
      } on Exception {
        return await _getFromCacheOrFail(const ServerFailure());
      }
    } else {
      // No network connection, try to get from cache
      return await _getFromCacheOrFail(const NetworkFailure());
    }
  }

  Future<Either<Failure, SettingsEntity>> _getFromCacheOrFail(
    Failure failure,
  ) async {
    try {
      final cachedSettings = await _localDataSource.getCachedSettings();
      if (cachedSettings != null) {
        return Right(cachedSettings);
      } else {
        return Left(failure);
      }
    } on CacheException {
      return Left(failure);
    }
  }

  // Method to force refresh settings from remote
  Future<Either<Failure, SettingsEntity>> refreshSettings() async {
    try {
      // Clear cache first
      await _localDataSource.clearCachedSettings();

      // Fetch fresh data from remote
      final remoteSettings = await _remoteDataSource.fetchSettings();

      // Cache the new settings
      await _localDataSource.cacheSettings(remoteSettings);

      return Right(remoteSettings);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  // Method to check if settings are cached
  Future<bool> hasCachedSettings() async {
    return await _localDataSource.hasCachedSettings();
  }

  // Method to clear cached settings
  Future<void> clearCachedSettings() async {
    await _localDataSource.clearCachedSettings();
  }
}

// Providers
final settingsApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((
  ref,
) {
  final client = ref.watch(settingsApiClientProvider);
  return SettingsRemoteDataSourceImpl(client);
});

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return SettingsLocalDataSourceImpl(localStorageService);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  final localDataSource = ref.watch(settingsLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);

  return SettingsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});
