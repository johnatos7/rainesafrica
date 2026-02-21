import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/data/models/currency_model.dart';

abstract class CurrencyRemoteDataSource {
  Future<PaginatedCurrencyResponse> fetchCurrencies({int page = 1});
}

class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final ApiClient _apiClient;

  CurrencyRemoteDataSourceImpl(this._apiClient);

  @override
  Future<PaginatedCurrencyResponse> fetchCurrencies({int page = 1}) async {
    try {
      final response = await _apiClient.get(
        '/api/currency',
        queryParameters: {'page': page},
      );
      return PaginatedCurrencyResponse.fromJson(
        response as Map<String, dynamic>,
      );
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }
}
