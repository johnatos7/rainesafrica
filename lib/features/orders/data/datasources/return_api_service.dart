import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_status_entity.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

class ReturnApiService {
  static const String _baseUrl = 'https://api.raines.africa';
  final SecureStorageService _secureStorage;

  ReturnApiService({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  Future<Map<String, dynamic>> submitReturnRequest(
    Map<String, dynamic> payload,
  ) async {
    try {
      // Get the auth token
      final token = await _secureStorage.getAuthToken();

      // Prepare headers
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/returns'),
        headers: headers,
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 201:
          // Success - Return request created
          return {'success': true, 'data': responseData};
        case 409:
          // Conflict - Return already submitted for this item
          return {
            'success': false,
            'message': 'Return already submitted for this item',
          };
        case 422:
          // Validation error
          return {
            'success': false,
            'message':
                'Validation error: ${responseData['message'] ?? 'Invalid data provided'}',
          };
        case 401:
          // Unauthorized
          return {
            'success': false,
            'message': 'Unauthorized. Please login again.',
          };
        case 500:
          // Server error
          return {
            'success': false,
            'message': 'Server error. Please try again later.',
          };
        default:
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'An unexpected error occurred',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }

  Future<Map<String, dynamic>> getReturnsByOrderId(int orderId) async {
    try {
      // Get the auth token
      final token = await _secureStorage.getAuthToken();

      // Prepare headers
      final headers = {'Accept': 'application/json'};

      // Add authorization header if token is available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/returns?order_id=$orderId'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);

      switch (response.statusCode) {
        case 200:
          // Success - Returns fetched
          final List<dynamic> returnsData = responseData['data'] ?? [];
          final List<ReturnStatusEntity> returns =
              returnsData
                  .map((returnData) => ReturnStatusEntity.fromJson(returnData))
                  .toList();

          return {'success': true, 'data': returns};
        case 401:
          // Unauthorized
          return {
            'success': false,
            'message': 'Unauthorized. Please login again.',
          };
        case 500:
          // Server error
          return {
            'success': false,
            'message': 'Server error. Please try again later.',
          };
        default:
          return {
            'success': false,
            'message':
                responseData['message'] ?? 'An unexpected error occurred',
          };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection and try again.',
      };
    }
  }
}
