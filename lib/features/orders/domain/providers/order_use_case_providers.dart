import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/providers/order_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/usecases/get_order_by_id_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/usecases/get_order_statuses_use_case.dart';

// Use case providers
final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrdersUseCase(repository: repository);
});

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderByIdUseCase(repository: repository);
});

final getOrderStatusesUseCaseProvider = Provider<GetOrderStatusesUseCase>((
  ref,
) {
  final repository = ref.watch(orderRepositoryProvider);
  return GetOrderStatusesUseCase(repository: repository);
});
