import 'package:flutter_riverpod_clean_architecture/features/checkout/data/models/checkout_request_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/models/checkout_response_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/authenticated_api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';

abstract class CheckoutRemoteDataSource {
  Future<Map<String, dynamic>> processCheckout(CheckoutRequestModel request);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final AuthenticatedApiClient _apiClient;

  CheckoutRemoteDataSourceImpl({required AuthenticatedApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> processCheckout(
    CheckoutRequestModel request,
  ) async {
    try {
      print('🛒 CHECKOUT API: Processing checkout request');
      print('🛒 CHECKOUT API: Full request payload:');
      print('----------------------------------------');
      final requestJson = request.toJson();
      requestJson.forEach((key, value) {
        print('  $key: $value');
      });
      print('----------------------------------------');
      print('🛒 CHECKOUT API: Products details:');
      for (var product in request.products) {
        print('  - Product ID: ${product.productId}');
        print('    Quantity: ${product.quantity}');
        print('    Price: ${product.price}');
        if (product.variationId != null) {
          print('    Variation ID: ${product.variationId}');
        }
      }
      print('----------------------------------------');

      // Make API call to Raines Africa
      final response = await _apiClient.post(
        '/api/order',
        data: request.toJson(),
      );

      print('🛒 CHECKOUT API: Response received');
      print('🛒 CHECKOUT API: Order number: ${response['order_number']}');
      print('🛒 CHECKOUT API: Transaction ID: ${response['transaction_id']}');
      print('🛒 CHECKOUT API: Is redirect: ${response['is_redirect']}');

      // Validate response has required fields
      if (response['order_number'] == null) {
        throw ServerException(
          message: 'Invalid response: missing order number',
        );
      }

      print('✅ CHECKOUT API: Checkout successful');

      // Parse response into model for type safety
      final responseModel = CheckoutResponseModel.fromJson(response);
      return responseModel.toJson();
    } on ServerException {
      rethrow;
    } on Exception catch (e) {
      print('❌ CHECKOUT API: Error occurred: $e');
      throw ServerException(message: 'Failed to process checkout: $e');
    }
  }
}
