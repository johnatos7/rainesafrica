import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage;

  SecureStorageService(this._secureStorage);

  // Keys
  static const String authTokenKey = 'authToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userDataKey = 'userData';

  // Default constructor
  factory SecureStorageService.create() {
    return SecureStorageService(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      ),
    );
  }

  // Write value
  Future<void> write({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(message: 'Failed to write secure data: $e');
    }
  }

  // Read value
  Future<String?> read({required String key}) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to read secure data: $e');
    }
  }

  // Delete value
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete secure data: $e');
    }
  }

  // Delete all
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Failed to delete all secure data: $e');
    }
  }

  // Check if key exists
  Future<bool> containsKey({required String key}) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to check secure key: $e');
    }
  }

  // Read all values
  Future<Map<String, String>> readAll() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      throw CacheException(message: 'Failed to read all secure data: $e');
    }
  }

  // Store auth token
  Future<void> storeAuthToken(String token) async {
    await write(key: authTokenKey, value: token);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    return await read(key: authTokenKey);
  }

  // Store refresh token
  Future<void> storeRefreshToken(String token) async {
    await write(key: refreshTokenKey, value: token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await read(key: refreshTokenKey);
  }

  // Store user data
  Future<void> storeUserData(String userData) async {
    await write(key: userDataKey, value: userData);
  }

  // Get user data
  Future<String?> getUserData() async {
    return await read(key: userDataKey);
  }

  // Clear all stored data
  Future<void> clearAll() async {
    await deleteAll();
  }
}

// Provider for secure storage service
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.create();
});
