import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/data/models/payment_account_model.dart';

abstract class PaymentAccountRemoteDataSource {
  Future<PaymentAccountModel> getPaymentAccount();
  Future<PaymentAccountModel> createPaymentAccount(
    PaymentAccountRequestModel request,
  );
  Future<PaymentAccountModel> updatePaymentAccount(
    int id,
    PaymentAccountRequestModel request,
  );
  Future<void> deletePaymentAccount(int id);
}

class PaymentAccountRemoteDataSourceImpl
    implements PaymentAccountRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  PaymentAccountRemoteDataSourceImpl(this._apiClient, this._secureStorage);

  @override
  Future<PaymentAccountModel> getPaymentAccount() async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      // Get the current auth token
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      // Set the authorization token for this request
      _apiClient.setToken(token);

      final response = await _apiClient.get('/api/paymentAccount');

      // Clear the token after the request
      _apiClient.removeToken();

      // Check if response is a Map (JSON object)
      if (response is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format from server. Expected JSON object but got ${response.runtimeType}. Response: ${response.toString()}',
        );
      }

      final paymentAccount = PaymentAccountModel.fromJson(response);
      return paymentAccount;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<PaymentAccountModel> createPaymentAccount(
    PaymentAccountRequestModel request,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      // Get the current auth token
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      // Set the authorization token for this request
      _apiClient.setToken(token);

      final response = await _apiClient.post(
        '/api/paymentAccount',
        data: request.toJson(),
      );

      // Clear the token after the request
      _apiClient.removeToken();

      // Check if response is a Map (JSON object)
      if (response is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format from server. Expected JSON object but got ${response.runtimeType}. Response: ${response.toString()}',
        );
      }

      final paymentAccount = PaymentAccountModel.fromJson(response);
      return paymentAccount;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<PaymentAccountModel> updatePaymentAccount(
    int id,
    PaymentAccountRequestModel request,
  ) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      // Get the current auth token
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      // Set the authorization token for this request
      _apiClient.setToken(token);

      final response = await _apiClient.post(
        '/api/paymentAccount',
        data: request.toJson(),
      );

      // Clear the token after the request
      _apiClient.removeToken();

      // Check if response is a Map (JSON object)
      if (response is! Map<String, dynamic>) {
        throw ServerException(
          message:
              'Invalid response format from server. Expected JSON object but got ${response.runtimeType}. Response: ${response.toString()}',
        );
      }

      final paymentAccount = PaymentAccountModel.fromJson(response);
      return paymentAccount;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> deletePaymentAccount(int id) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      // Get the current auth token
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        throw UnauthorizedException(message: 'No authentication token found');
      }

      // Set the authorization token for this request
      _apiClient.setToken(token);

      await _apiClient.delete('/api/paymentAccount/$id');

      // Clear the token after the request
      _apiClient.removeToken();
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  Exception _handleException(Exception e) {
    if (e is ServerException) {
      return e;
    } else if (e is NetworkException) {
      return e;
    } else if (e is UnauthorizedException) {
      return e;
    } else {
      return ServerException(message: 'An unexpected error occurred');
    }
  }
}
