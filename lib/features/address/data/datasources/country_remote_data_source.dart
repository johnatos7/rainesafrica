import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/models/address_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';

abstract class CountryRemoteDataSource {
  Future<List<CountryEntity>> getCountries();
  Future<List<StateEntity>> getStatesByCountry(int countryId);
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final ApiClient _apiClient;

  CountryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CountryEntity>> getCountries() async {
    try {
      final response = await _apiClient.get('/api/country');
      if (response is List) {
        return response
            .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException();
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }

  @override
  Future<List<StateEntity>> getStatesByCountry(int countryId) async {
    try {
      final response = await _apiClient.get('/api/country/$countryId/states');
      if (response is List) {
        return response
            .map((e) => StateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw ServerException();
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }
}
