import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorageService;
  final SecureStorageService _secureStorageService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalStorageService localStorageService,
    required SecureStorageService secureStorageService,
  }) : _remoteDataSource = remoteDataSource,
       _localStorageService = localStorageService,
       _secureStorageService = secureStorageService;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    print('🔵 AUTH REPOSITORY: login() called with email: $email');

    try {
      print('🔵 AUTH REPOSITORY: Calling remote data source login');
      final loginResponse = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      print('🔵 AUTH REPOSITORY: Remote login successful, storing auth token');

      // Save auth token securely
      await _secureStorageService.storeAuthToken(loginResponse.accessToken);

      print('🔵 AUTH REPOSITORY: Getting current user info');
      // Get user information using the access token
      final userResponse = await _remoteDataSource.getCurrentUser(
        accessToken: loginResponse.accessToken,
      );

      print('🔵 AUTH REPOSITORY: Saving user data locally');
      // Save user data locally
      await _localStorageService.setObject(
        AppConstants.userDataKey,
        userResponse.toJson(),
      );

      print(
        '🟢 AUTH REPOSITORY: Login successful, converting UserModel to UserEntity',
      );
      print(
        '🔵 AUTH REPOSITORY: ===== USER MODEL TO ENTITY CONVERSION START =====',
      );
      print('🔵 AUTH REPOSITORY: UserModel JSON: ${userResponse.toJson()}');

      try {
        final userEntity = userResponse.toEntity();
        return Right(userEntity);
      } catch (e) {
        print(
          '🔴 AUTH REPOSITORY: Error converting UserModel to UserEntity: $e',
        );
        print('🔴 AUTH REPOSITORY: Stack trace: ${StackTrace.current}');
        return Left(ServerFailure(message: 'Failed to convert user data: $e'));
      }
    } on ServerException catch (e) {
      print('🔴 AUTH REPOSITORY: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      print('🔴 AUTH REPOSITORY: Network exception');
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String countryCode,
    required int phone,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        countryCode: countryCode,
        phone: phone,
      );

      // Save user data locally
      await _localStorageService.setObject(
        AppConstants.userDataKey,
        response.toJson(),
      );

      // Note: Registration doesn't provide an authentication token
      // User needs to login separately to get authenticated

      return Right(response.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Remove user data from local storage
      await _localStorageService.remove(AppConstants.userDataKey);

      // Remove auth token from secure storage
      await _secureStorageService.clearAll();

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await _secureStorageService.getAuthToken();
      return Right(token != null && token.isNotEmpty);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // First check if we have a token
      final token = await _secureStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        return const Left(
          AuthFailure(message: 'No authentication token found'),
        );
      }

      // Try to get fresh user data from API
      try {
        final userResponse = await _remoteDataSource.getCurrentUser(
          accessToken: token,
        );

        // Save updated user data locally
        await _localStorageService.setObject(
          AppConstants.userDataKey,
          userResponse.toJson(),
        );

        return Right(userResponse.toEntity());
      } catch (e) {
        // If API call fails, try to get cached data
        final userData = _localStorageService.getObject(
          AppConstants.userDataKey,
        );

        if (userData == null) {
          return const Left(CacheFailure(message: 'No user data found'));
        }

        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);
        return Right(userModel.toEntity());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    required String email,
    required String countryCode,
    required int phone,
  }) async {
    print('🔵 AUTH REPOSITORY: updateProfile() called');

    try {
      print('🔵 AUTH REPOSITORY: Calling remote data source updateProfile');
      final userResponse = await _remoteDataSource.updateProfile(
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
      );

      print(
        '🔵 AUTH REPOSITORY: Remote updateProfile successful, saving user data locally',
      );
      // Save updated user data locally
      await _localStorageService.setObject(
        AppConstants.userDataKey,
        userResponse.toJson(),
      );

      print(
        '🟢 AUTH REPOSITORY: UpdateProfile successful, converting UserModel to UserEntity',
      );
      final userEntity = userResponse.toEntity();
      return Right(userEntity);
    } on ServerException catch (e) {
      print('🔴 AUTH REPOSITORY: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      print('🔴 AUTH REPOSITORY: Network exception');
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    print('🔵 AUTH REPOSITORY: forgotPassword() called');

    try {
      print('🔵 AUTH REPOSITORY: Calling remote data source forgotPassword');
      final response = await _remoteDataSource.forgotPassword(email: email);

      print('🟢 AUTH REPOSITORY: ForgotPassword successful');
      return Right(response);
    } on ServerException catch (e) {
      print('🔴 AUTH REPOSITORY: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      print('🔴 AUTH REPOSITORY: Network exception');
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyToken({
    required String email,
    required String token,
  }) async {
    print('🔵 AUTH REPOSITORY: verifyToken() called');

    try {
      print('🔵 AUTH REPOSITORY: Calling remote data source verifyToken');
      final response = await _remoteDataSource.verifyToken(
        email: email,
        token: token,
      );

      print('🟢 AUTH REPOSITORY: VerifyToken successful');
      return Right(response);
    } on ServerException catch (e) {
      print('🔴 AUTH REPOSITORY: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      print('🔴 AUTH REPOSITORY: Network exception');
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updatePassword({
    required String password,
    required String passwordConfirmation,
    required String token,
    required String email,
  }) async {
    print('🔵 AUTH REPOSITORY: updatePassword() called');

    try {
      print('🔵 AUTH REPOSITORY: Calling remote data source updatePassword');
      final response = await _remoteDataSource.updatePassword(
        password: password,
        passwordConfirmation: passwordConfirmation,
        token: token,
        email: email,
      );

      print('🟢 AUTH REPOSITORY: UpdatePassword successful');
      return Right(response);
    } on ServerException catch (e) {
      print('🔴 AUTH REPOSITORY: Server exception: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      print('🔴 AUTH REPOSITORY: Network exception');
      return const Left(NetworkFailure());
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}

// Dependencies — apiClientProvider is now defined in core/providers/network_providers.dart

// Using sharedPreferencesProvider from main.dart

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.create();
});

// Remote data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRemoteDataSourceImpl(apiClient, secureStorage);
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localStorageService: ref.watch(localStorageServiceProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});
