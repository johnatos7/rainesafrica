import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/order_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl({required OrderRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<OrderListResponse> getOrders({int page = 1}) async {
    return await _remoteDataSource.getOrders(page: page);
  }

  @override
  Future<OrderEntity> getOrderById(int orderId) async {
    return await _remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<OrderStatusListResponse> getOrderStatuses() async {
    return await _remoteDataSource.getOrderStatuses();
  }
}
