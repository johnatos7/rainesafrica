import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/refund_return_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/repositories/refund_return_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/refund_return_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/providers/order_providers.dart';

// Refund Return Remote Data Source provider
final refundReturnRemoteDataSourceProvider =
    Provider<RefundReturnRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return RefundReturnRemoteDataSourceImpl(apiClient: apiClient);
    });

// Refund Return Repository provider
final refundReturnRepositoryProvider = Provider<RefundReturnRepository>((ref) {
  final remoteDataSource = ref.watch(refundReturnRemoteDataSourceProvider);
  return RefundReturnRepositoryImpl(remoteDataSource: remoteDataSource);
});
