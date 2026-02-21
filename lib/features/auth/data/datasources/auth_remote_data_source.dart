import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/login_request_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  /// Login a user with email and password
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  /// Get current user information
  Future<UserModel> getCurrentUser({required String accessToken});

  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String countryCode,
    required int phone,
  });

  /// Update user profile
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String countryCode,
    required int phone,
  });

  /// Send forgot password email
  Future<Map<String, dynamic>> forgotPassword({required String email});

  /// Verify reset token
  Future<Map<String, dynamic>> verifyToken({
    required String email,
    required String token,
  });

  /// Update password with token
  Future<Map<String, dynamic>> updatePassword({
    required String password,
    required String passwordConfirmation,
    required String token,
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRemoteDataSourceImpl(this._apiClient, this._secureStorage);

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    print('🔵 REMOTE DATA SOURCE: login() called with email: $email');

    try {
      print('🔵 REMOTE DATA SOURCE: Checking network connection');
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        print('🔴 REMOTE DATA SOURCE: No network connection');
        throw NetworkException();
      }
      print('🔵 REMOTE DATA SOURCE: Network connection available');

      final loginRequest = LoginRequestModel(
        email: email,
        password: password,
        recaptcha: '',
      );
      print('🔵 REMOTE DATA SOURCE: Making API call to /api/login');

      final response = await _apiClient.post(
        '/api/login',
        data: loginRequest.toJson(),
      );

      // LOG COMPLETE LOGIN RESPONSE
      print('🔵 REMOTE DATA SOURCE: ===== LOGIN RESPONSE START =====');
      print('🔵 REMOTE DATA SOURCE: Full response: $response');
      print('🔵 REMOTE DATA SOURCE: Response keys: ${response.keys.toList()}');
      print('🔵 REMOTE DATA SOURCE: Success status: ${response['success']}');
      print('🔵 REMOTE DATA SOURCE: Message: ${response['message']}');
      print('🔵 REMOTE DATA SOURCE: Data type: ${response.runtimeType}');
      print('🔵 REMOTE DATA SOURCE: ===== LOGIN RESPONSE END =====');

      if (response['success'] == false) {
        print('🔴 REMOTE DATA SOURCE: Login failed: ${response['message']}');
        throw UnauthorizedException(
          message: response['message'] ?? 'Login failed',
        );
      }

      print(
        '🟢 REMOTE DATA SOURCE: Login successful, creating LoginResponseModel',
      );
      final loginResponse = LoginResponseModel.fromJson(response);
      print(
        '🔵 REMOTE DATA SOURCE: LoginResponseModel created: ${loginResponse.toJson()}',
      );
      return loginResponse;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser({required String accessToken}) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      // Set the authorization token for this request
      _apiClient.setToken(accessToken);

      final response = await _apiClient.get('/api/self');

      // LOG COMPLETE USER DATA RESPONSE
      print('🔵 REMOTE DATA SOURCE: ===== USER DATA RESPONSE START =====');
      print('🔵 REMOTE DATA SOURCE: Full user response: $response');
      print('🔵 REMOTE DATA SOURCE: Response keys: ${response.keys.toList()}');
      print('🔵 REMOTE DATA SOURCE: User ID: ${response['id']}');
      print('🔵 REMOTE DATA SOURCE: User name: ${response['name']}');
      print('🔵 REMOTE DATA SOURCE: User email: ${response['email']}');
      print('🔵 REMOTE DATA SOURCE: User role: ${response['role']}');
      print(
        '🔵 REMOTE DATA SOURCE: User permission: ${response['permission']}',
      );
      print('🔵 REMOTE DATA SOURCE: User address: ${response['address']}');
      print('🔵 REMOTE DATA SOURCE: User point: ${response['point']}');
      print('🔵 REMOTE DATA SOURCE: User wallet: ${response['wallet']}');
      print('🔵 REMOTE DATA SOURCE: Data type: ${response.runtimeType}');
      print('🔵 REMOTE DATA SOURCE: ===== USER DATA RESPONSE END =====');

      // Clear the token after the request to avoid affecting other requests
      _apiClient.removeToken();

      print('🔵 REMOTE DATA SOURCE: Creating UserModel from response');
      final userModel = UserModel.fromJson(response);
      print('🔵 REMOTE DATA SOURCE: UserModel created successfully');
      print('🔵 REMOTE DATA SOURCE: UserModel JSON: ${userModel.toJson()}');
      return userModel;
    } on Exception catch (e) {
      // Ensure token is cleared even if an exception occurs
      _apiClient.removeToken();
      throw _handleException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String countryCode,
    required int phone,
  }) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }

      final response = await _apiClient.post(
        '/api/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'country_code': countryCode,
          'phone': phone,
        },
      );

      if (response['success'] == false) {
        throw BadRequestException(
          message: response['message'] ?? 'Registration failed',
        );
      }

      // Store the access token
      final accessToken = response['access_token'] as String;
      _apiClient.setToken(accessToken);

      // Get user data
      final userData = await getCurrentUser(accessToken: accessToken);

      // Clear the token after the request
      _apiClient.removeToken();

      return userData;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String countryCode,
    required int phone,
  }) async {
    try {
      print('🔵 REMOTE DATA SOURCE: updateProfile() called');

      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        print('🔴 REMOTE DATA SOURCE: No network connection');
        throw NetworkException();
      }
      print('🔵 REMOTE DATA SOURCE: Network connection available');

      // Get the current auth token
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) {
        print('🔴 REMOTE DATA SOURCE: No auth token found');
        throw UnauthorizedException(message: 'No authentication token found');
      }

      // Set the authorization token for this request
      _apiClient.setToken(token);

      final response = await _apiClient.post(
        '/api/updateProfile',
        data: {
          'name': name,
          'email': email,
          'country_code': countryCode,
          'phone': phone,
          '_method': 'PUT',
        },
      );

      print('🔵 REMOTE DATA SOURCE: ===== UPDATE PROFILE RESPONSE START =====');
      print('🔵 REMOTE DATA SOURCE: Full response: $response');
      print('🔵 REMOTE DATA SOURCE: Response keys: ${response.keys.toList()}');
      print('🔵 REMOTE DATA SOURCE: ===== UPDATE PROFILE RESPONSE END =====');

      // Clear the token after the request
      _apiClient.removeToken();

      print('🔵 REMOTE DATA SOURCE: Creating UserModel from response');
      final userModel = UserModel.fromJson(response);
      print('🔵 REMOTE DATA SOURCE: UserModel created successfully');
      return userModel;
    } on Exception catch (e) {
      // Ensure token is cleared even if an exception occurs
      _apiClient.removeToken();
      throw _handleException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      print(
        '🔵 REMOTE DATA SOURCE: forgotPassword() called with email: $email',
      );

      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        print('🔴 REMOTE DATA SOURCE: No network connection');
        throw NetworkException();
      }
      print('🔵 REMOTE DATA SOURCE: Network connection available');

      final response = await _apiClient.post(
        '/api/forgot-password',
        data: {'email': email},
      );

      print(
        '🔵 REMOTE DATA SOURCE: ===== FORGOT PASSWORD RESPONSE START =====',
      );
      print('🔵 REMOTE DATA SOURCE: Full response: $response');
      print('🔵 REMOTE DATA SOURCE: ===== FORGOT PASSWORD RESPONSE END =====');

      return response;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyToken({
    required String email,
    required String token,
  }) async {
    try {
      print('🔵 REMOTE DATA SOURCE: verifyToken() called');

      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        print('🔴 REMOTE DATA SOURCE: No network connection');
        throw NetworkException();
      }
      print('🔵 REMOTE DATA SOURCE: Network connection available');

      final response = await _apiClient.post(
        '/api/verify-token',
        data: {'email': email, 'token': token},
      );

      print('🔵 REMOTE DATA SOURCE: ===== VERIFY TOKEN RESPONSE START =====');
      print('🔵 REMOTE DATA SOURCE: Full response: $response');
      print('🔵 REMOTE DATA SOURCE: ===== VERIFY TOKEN RESPONSE END =====');

      return response;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> updatePassword({
    required String password,
    required String passwordConfirmation,
    required String token,
    required String email,
  }) async {
    try {
      print('🔵 REMOTE DATA SOURCE: updatePassword() called');

      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        print('🔴 REMOTE DATA SOURCE: No network connection');
        throw NetworkException();
      }
      print('🔵 REMOTE DATA SOURCE: Network connection available');

      final response = await _apiClient.post(
        '/api/update-password',
        data: {
          'password': password,
          'password_confirmation': passwordConfirmation,
          'token': token,
          'email': email,
        },
      );

      print(
        '🔵 REMOTE DATA SOURCE: ===== UPDATE PASSWORD RESPONSE START =====',
      );
      print('🔵 REMOTE DATA SOURCE: Full response: $response');
      print('🔵 REMOTE DATA SOURCE: ===== UPDATE PASSWORD RESPONSE END =====');

      return response;
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  // Helper method to handle exceptions
  Exception _handleException(Exception e) {
    if (e is NetworkException ||
        e is ServerException ||
        e is UnauthorizedException ||
        e is BadRequestException) {
      return e;
    }
    return ServerException(message: e.toString());
  }
}

// Provider — uses the shared apiClientProvider from network_providers.dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRemoteDataSourceImpl(apiClient, secureStorage);
});

// NOTE: apiClientProvider is now defined in core/providers/network_providers.dart
