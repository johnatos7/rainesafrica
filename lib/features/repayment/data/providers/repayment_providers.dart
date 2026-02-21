import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/data/datasources/repayment_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/data/repositories/repayment_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/repositories/repayment_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/usecases/process_repayment_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

// API Client Provider
final authenticatedApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthenticatedApiClient(secureStorage: secureStorage);
});

// Data Source Provider
final repaymentRemoteDataSourceProvider = Provider<RepaymentRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(authenticatedApiClientProvider);
  return RepaymentRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository Provider
final repaymentRepositoryProvider = Provider<RepaymentRepository>((ref) {
  final remoteDataSource = ref.watch(repaymentRemoteDataSourceProvider);
  return RepaymentRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Case Provider
final processRepaymentUseCaseProvider = Provider<ProcessRepaymentUseCase>((
  ref,
) {
  final repository = ref.watch(repaymentRepositoryProvider);
  return ProcessRepaymentUseCase(repository: repository);
});
