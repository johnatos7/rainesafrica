import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/order_repository.dart';

// Authenticated API Client provider
final apiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthenticatedApiClient(secureStorage: secureStorage);
});

// Data source provider
final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrderRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: remoteDataSource);
});
