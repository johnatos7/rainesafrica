import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_list_entity.dart';

abstract class RefundReturnRemoteDataSource {
  Future<RefundEntity> requestRefund(RefundRequestEntity request);
  Future<ReturnEntity> requestReturn(ReturnRequestEntity request);
  Future<RefundListResponse> getRefunds({int page = 1});
  Future<ReturnListResponse> getReturns();
}

class RefundReturnRemoteDataSourceImpl implements RefundReturnRemoteDataSource {
  final AuthenticatedApiClient _apiClient;

  RefundReturnRemoteDataSourceImpl({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<RefundEntity> requestRefund(RefundRequestEntity request) async {
    try {
      print('API Client: Making POST request to /api/refund');
      print('API Client: Request data: ${request.toJson()}');

      final response = await _apiClient.post(
        '/api/refund',
        data: request.toJson(),
      );
      print('API Client: Refund response: $response');

      // Check if response is a Map
      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>, got ${response.runtimeType}',
        );
      }

      // Check if the response indicates an error
      if (response.containsKey('success') && response['success'] == false) {
        throw Exception(response['message'] ?? 'Refund request failed');
      }

      return RefundEntity.fromJson(response);
    } catch (e) {
      print('API Client: Error requesting refund: $e');
      throw Exception('Failed to request refund: $e');
    }
  }

  @override
  Future<ReturnEntity> requestReturn(ReturnRequestEntity request) async {
    try {
      print('API Client: Making POST request to /api/returns');
      print('API Client: Request data: ${request.toJson()}');

      final response = await _apiClient.post(
        '/api/returns',
        data: request.toJson(),
      );
      print('API Client: Return response: $response');

      // Check if response is a Map
      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>, got ${response.runtimeType}',
        );
      }

      return ReturnEntity.fromJson(response);
    } catch (e) {
      print('API Client: Error requesting return: $e');
      throw Exception('Failed to request return: $e');
    }
  }

  @override
  Future<RefundListResponse> getRefunds({int page = 1}) async {
    try {
      print('API Client: Making GET request to /api/refund?page=$page');

      final response = await _apiClient.get(
        '/api/refund',
        queryParameters: {'page': page},
      );
      print('API Client: Refunds list response: $response');

      // Check if response is a Map
      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>, got ${response.runtimeType}',
        );
      }

      return RefundListResponse.fromJson(response);
    } catch (e) {
      print('API Client: Error getting refunds: $e');
      throw Exception('Failed to get refunds: $e');
    }
  }

  @override
  Future<ReturnListResponse> getReturns() async {
    try {
      print('API Client: Making GET request to /api/returns');

      final response = await _apiClient.get('/api/returns');
      print('API Client: Returns list response: $response');

      // Check if response is a Map
      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response format: expected Map<String, dynamic>, got ${response.runtimeType}',
        );
      }

      return ReturnListResponse.fromJson(response);
    } catch (e) {
      print('API Client: Error getting returns: $e');
      throw Exception('Failed to get returns: $e');
    }
  }
}
