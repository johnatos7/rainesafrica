import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/data/models/home_config_model.dart';

abstract class HomeConfigRemoteDataSource {
  Future<HomeConfigModel> fetchHomeConfig();
}

class HomeConfigRemoteDataSourceImpl implements HomeConfigRemoteDataSource {
  final ApiClient _apiClient;

  HomeConfigRemoteDataSourceImpl(this._apiClient);

  @override
  Future<HomeConfigModel> fetchHomeConfig() async {
    try {
      // Endpoint fetches the current home configuration
      final response = await _apiClient.get('/api/home');
      return HomeConfigModel.fromJson(response as Map<String, dynamic>);
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }
}
