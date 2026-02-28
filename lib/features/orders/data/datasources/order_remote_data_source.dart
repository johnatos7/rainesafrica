import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';

abstract class OrderRemoteDataSource {
  Future<OrderListResponse> getOrders({int page = 1});
  Future<OrderEntity> getOrderById(int orderId);
  Future<OrderStatusListResponse> getOrderStatuses();
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final AuthenticatedApiClient _apiClient;

  OrderRemoteDataSourceImpl({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<OrderListResponse> getOrders({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/api/order',
        queryParameters: {'page': page, 'paginate': 15},
      );

      return OrderListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<OrderEntity> getOrderById(int orderId) async {
    try {
      print('API Client: Making GET request to /api/order/$orderId');
      final response = await _apiClient.get('/api/order/$orderId');
      print('API Client: Response type: ${response.runtimeType}');
      print('API Client: Response data: $response');

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>, got ${response.runtimeType}',
        );
      }

      return OrderEntity.fromJson(response);
    } on AppException catch (e) {
      // Some backends treat the path segment as order number. If ID lookup fails
      // with an order-number-related error, retry using a query parameter filter.
      final lower = e.message.toLowerCase();
      final looksLikeOrderNumberError =
          lower.contains('order number') || lower.contains('order_number');

      if (looksLikeOrderNumberError) {
        print(
          'API Client: ID lookup failed; retrying by order number using /api/order?order_number=$orderId',
        );
        final fallback = await _apiClient.get(
          '/api/order',
          queryParameters: {'order_number': orderId},
        );

        // Support either a single object or a wrapped response
        dynamic payload = fallback;
        if (fallback is Map<String, dynamic> && fallback['data'] != null) {
          payload = fallback['data'];
        }

        if (payload is List && payload.isNotEmpty) {
          final first = payload.first;
          if (first is Map<String, dynamic>) {
            return OrderEntity.fromJson(first);
          }
        }
        if (payload is Map<String, dynamic>) {
          return OrderEntity.fromJson(payload);
        }

        throw Exception('Invalid response while fetching by order number');
      }

      print('API Client: Error fetching order details: $e');
      throw Exception('Failed to fetch order details: $e');
    } catch (e) {
      print('API Client: Error fetching order details: $e');
      throw Exception('Failed to fetch order details: $e');
    }
  }

  @override
  Future<OrderStatusListResponse> getOrderStatuses() async {
    try {
      final response = await _apiClient.get('/api/orderStatus');
      return OrderStatusListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order statuses: $e');
    }
  }
}
