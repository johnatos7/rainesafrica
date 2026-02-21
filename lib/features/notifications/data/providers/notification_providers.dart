import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/repositories/notification_repository.dart';

// Authenticated API Client provider
final notificationApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthenticatedApiClient(secureStorage: secureStorage);
});

// Data source provider
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      final apiClient = ref.watch(notificationApiClientProvider);
      return NotificationRemoteDataSourceImpl(apiClient: apiClient);
    });

// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remoteDataSource: remoteDataSource);
});
