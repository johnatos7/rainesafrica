import 'dart:convert';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/models/settings_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsEntity?> getCachedSettings();
  Future<void> cacheSettings(SettingsEntity settings);
  Future<void> clearCachedSettings();
  Future<bool> hasCachedSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final LocalStorageService _localStorageService;
  static const String _settingsCacheKey = 'cached_settings';
  static const String _settingsCacheTimestampKey = 'settings_cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(hours: 24);

  SettingsLocalDataSourceImpl(this._localStorageService);

  @override
  Future<SettingsEntity?> getCachedSettings() async {
    try {
      final cachedData = await _localStorageService.getString(
        _settingsCacheKey,
      );
      if (cachedData == null) return null;

      // Check if cache is still valid
      final timestamp = await _localStorageService.getInt(
        _settingsCacheTimestampKey,
      );
      if (timestamp == null) return null;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheValidityDuration) {
        // Cache expired, clear it
        await clearCachedSettings();
        return null;
      }

      final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
      return SettingsModel.fromJson(jsonData);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheSettings(SettingsEntity settings) async {
    try {
      final settingsModel = settings as SettingsModel;
      final jsonData = settingsModel.toJson();
      final jsonString = jsonEncode(jsonData);

      await _localStorageService.setString(_settingsCacheKey, jsonString);
      await _localStorageService.setInt(
        _settingsCacheTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCachedSettings() async {
    try {
      await _localStorageService.remove(_settingsCacheKey);
      await _localStorageService.remove(_settingsCacheTimestampKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> hasCachedSettings() async {
    try {
      final cachedData = await _localStorageService.getString(
        _settingsCacheKey,
      );
      if (cachedData == null) return false;

      // Check if cache is still valid
      final timestamp = await _localStorageService.getInt(
        _settingsCacheTimestampKey,
      );
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      return now.difference(cacheTime) <= _cacheValidityDuration;
    } catch (e) {
      return false;
    }
  }
}
