// Network Providers
// Riverpod providers for network-related services

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';
import '../network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

/// Provider for Connectivity instance
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider for NetworkInfo instance
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity: connectivity);
});

/// Provider for ApiClient instance — uses AuthenticatedApiClient so that
/// every feature (layby, tickets, feedback, etc.) automatically includes
/// the Bearer token from SecureStorage.
final apiClientProvider = Provider<ApiClient>((ref) {
  return AuthenticatedApiClient(secureStorage: SecureStorageService.create());
});
