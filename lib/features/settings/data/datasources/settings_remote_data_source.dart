import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/models/settings_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsEntity> fetchSettings();
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient _apiClient;

  SettingsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<SettingsEntity> fetchSettings() async {
    try {
      final response = await _apiClient.get('/api/settings');
      return SettingsModel.fromJson(response as Map<String, dynamic>);
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw ServerException();
    }
  }
}
