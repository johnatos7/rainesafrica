import 'package:flutter_riverpod_clean_architecture/features/repayment/data/models/repayment_request_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';

abstract class RepaymentRemoteDataSource {
  Future<Map<String, dynamic>> processRepayment(RepaymentRequestModel request);
}

class RepaymentRemoteDataSourceImpl implements RepaymentRemoteDataSource {
  final AuthenticatedApiClient _apiClient;

  RepaymentRemoteDataSourceImpl({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> processRepayment(
    RepaymentRequestModel request,
  ) async {
    try {
      print('💳 REPAYMENT API: Processing repayment request');
      print('💳 REPAYMENT API: Payment method: ${request.paymentMethod}');
      print('💳 REPAYMENT API: Order number: ${request.orderNumber}');
      print('💳 REPAYMENT API: Amount: ${request.amount}');

      // Make API call to Raines Africa
      final response = await _apiClient.post(
        '/api/rePayment',
        data: request.toJson(),
      );

      print('💳 REPAYMENT API: Response received');
      print('💳 REPAYMENT API: Full response: $response');
      print(
        '💳 REPAYMENT API: Order number: ${response['order_number']} (type: ${response['order_number'].runtimeType})',
      );
      print(
        '💳 REPAYMENT API: Transaction ID: ${response['transaction_id']} (type: ${response['transaction_id']?.runtimeType})',
      );
      print(
        '💳 REPAYMENT API: Is redirect: ${response['is_redirect']} (type: ${response['is_redirect'].runtimeType})',
      );
      print('💳 REPAYMENT API: URL: ${response['url']}');
      print('💳 REPAYMENT API: Redirect URL: ${response['redirect_url']}');
      print('💳 REPAYMENT API: Status: ${response['status']}');

      // Validate response has required fields
      if (response['order_number'] == null) {
        throw ServerException(
          message: 'Invalid response: missing order number',
        );
      }

      print('✅ REPAYMENT API: Repayment successful');

      return response;
    } catch (e) {
      print('❌ REPAYMENT API: Error processing repayment: $e');
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to process repayment: $e');
    }
  }
}
