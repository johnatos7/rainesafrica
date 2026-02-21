import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/models/address_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';

abstract class AddressRemoteDataSource {
  Future<List<AddressEntity>> getUserAddresses();
  Future<AddressEntity> createAddress(AddressFormData addressData);
  Future<AddressEntity> updateAddress(
    int addressId,
    AddressFormData addressData,
  );
  Future<void> deleteAddress(int addressId);
  Future<AddressEntity> setDefaultAddress(int addressId);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final ApiClient _apiClient;

  AddressRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AddressEntity>> getUserAddresses() async {
    try {
      final response = await _apiClient.get('/api/address');
      if (response is List) {
        return response
            .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException();
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<AddressEntity> createAddress(AddressFormData addressData) async {
    try {
      print('=== DEBUG: Creating address ===');
      print('Address data being sent: ${addressData.toJson()}');

      final response = await _apiClient.post(
        '/api/address',
        data: addressData.toJson(),
      );

      print('=== DEBUG: API Response ===');
      print('Response type: ${response.runtimeType}');
      print('Response data: $response');
      print('=============================');

      return AddressModel.fromJson(response as Map<String, dynamic>);
    } on Exception catch (e) {
      print('=== DEBUG: Exception in createAddress ===');
      print('Exception type: ${e.runtimeType}');
      print('Exception message: $e');
      print('=========================================');
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<AddressEntity> updateAddress(
    int addressId,
    AddressFormData addressData,
  ) async {
    try {
      final response = await _apiClient.put(
        '/api/address/$addressId',
        data: addressData.toJson(),
      );
      return AddressModel.fromJson(response as Map<String, dynamic>);
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<void> deleteAddress(int addressId) async {
    try {
      await _apiClient.delete('/api/address/$addressId');
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<AddressEntity> setDefaultAddress(int addressId) async {
    try {
      final response = await _apiClient.put(
        '/api/address/$addressId/set-default',
      );
      return AddressModel.fromJson(response as Map<String, dynamic>);
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }
}
