import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/data/datasources/points_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/data/repositories/points_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/repositories/points_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

final authenticatedApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  return AuthenticatedApiClient(secureStorage: ref.read(secureStorageProvider));
});

final pointsRemoteDataSourceProvider = Provider<PointsRemoteDataSource>((ref) {
  return PointsRemoteDataSourceImpl(
    client: ref.read(authenticatedApiClientProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final pointsRepositoryProvider = Provider<PointsRepository>((ref) {
  return PointsRepositoryImpl(
    remoteDataSource: ref.read(pointsRemoteDataSourceProvider),
  );
});
