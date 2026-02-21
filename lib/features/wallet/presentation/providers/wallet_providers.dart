import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

final authenticatedApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  return AuthenticatedApiClient(secureStorage: ref.read(secureStorageProvider));
});

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  return WalletRemoteDataSourceImpl(
    client: ref.read(authenticatedApiClientProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl(
    remoteDataSource: ref.read(walletRemoteDataSourceProvider),
  );
});
