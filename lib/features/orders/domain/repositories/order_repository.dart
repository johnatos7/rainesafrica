import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderListResponse> getOrders({int page = 1});
  Future<OrderEntity> getOrderById(int orderId);
  Future<OrderStatusListResponse> getOrderStatuses();
}
