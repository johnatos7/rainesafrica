import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';

class AuthenticatedApiClient extends ApiClient {
  final SecureStorageService _secureStorage;

  AuthenticatedApiClient({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    await _setAuthToken();
    return super.get(path, queryParameters: queryParameters);
  }

  @override
  Future<dynamic> post(String path, {dynamic data}) async {
    await _setAuthToken();
    return super.post(path, data: data);
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    await _setAuthToken();
    return super.put(path, data: data);
  }

  @override
  Future<dynamic> delete(String path) async {
    await _setAuthToken();
    return super.delete(path);
  }

  Future<void> _setAuthToken() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token != null && token.isNotEmpty) {
        setToken(token);
      }
    } catch (e) {
      // Token not available, continue without authentication
      print('No auth token available: $e');
    }
  }
}
