import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/secure_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/datasources/address_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/datasources/country_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/repositories/address_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/repositories/auth_repository_impl.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource _remoteDataSource;
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AddressRepositoryImpl(
    this._remoteDataSource,
    this._apiClient,
    this._secureStorage,
  );

  // Helper method to set auth token
  Future<void> _setAuthToken() async {
    try {
      print('DEBUG: _setAuthToken called');
      final token = await _secureStorage.getAuthToken();
      print(
        'DEBUG: Token retrieved: ${token != null ? "Token exists (${token.length} chars)" : "No token"}',
      );
      if (token != null && token.isNotEmpty) {
        print('DEBUG: Setting token on API client');
        _apiClient.setToken(token);
        print('DEBUG: Token set successfully');
      } else {
        print('DEBUG: No token available, proceeding without authentication');
      }
    } catch (e) {
      // If we can't get the token, we'll let the API call fail with 401
      print('DEBUG: Failed to get auth token: $e');
    }
  }

  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses() async {
    try {
      final addresses = await _remoteDataSource.getUserAddresses();
      return Right(addresses);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> createAddress(
    AddressFormData addressData,
  ) async {
    try {
      print('DEBUG: createAddress called in repository');
      print('DEBUG: Address data: $addressData');
      await _setAuthToken();
      print('DEBUG: Calling remote data source createAddress');
      final address = await _remoteDataSource.createAddress(addressData);
      print('DEBUG: Address created successfully: $address');
      return Right(address);
    } on NetworkException catch (e) {
      print('DEBUG: NetworkException in createAddress: ${e.message}');
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      print('DEBUG: TimeoutException in createAddress: ${e.message}');
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      print('DEBUG: UnauthorizedException in createAddress: ${e.message}');
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      print('DEBUG: BadRequestException in createAddress: ${e.message}');
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      print('DEBUG: NotFoundException in createAddress: ${e.message}');
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      print('DEBUG: ServerException in createAddress: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      print('DEBUG: AppException in createAddress: ${e.message}');
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      print('DEBUG: Generic Exception in createAddress: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress(
    int addressId,
    AddressFormData addressData,
  ) async {
    try {
      await _setAuthToken();
      final address = await _remoteDataSource.updateAddress(
        addressId,
        addressData,
      );
      return Right(address);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(int addressId) async {
    try {
      await _setAuthToken();
      await _remoteDataSource.deleteAddress(addressId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> setDefaultAddress(
    int addressId,
  ) async {
    try {
      await _setAuthToken();
      final address = await _remoteDataSource.setDefaultAddress(addressId);
      return Right(address);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}

class CountryRepositoryImpl implements CountryRepository {
  final CountryRemoteDataSource _remoteDataSource;

  CountryRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    try {
      final countries = await _remoteDataSource.getCountries();
      return Right(countries);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StateEntity>>> getStatesByCountry(
    int countryId,
  ) async {
    try {
      final states = await _remoteDataSource.getStatesByCountry(countryId);
      return Right(states);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on BadRequestException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AppException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}

// Providers
final addressApiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((
  ref,
) {
  final client = ref.watch(addressApiClientProvider);
  return AddressRemoteDataSourceImpl(client);
});

final countryRemoteDataSourceProvider = Provider<CountryRemoteDataSource>((
  ref,
) {
  final client = ref.watch(addressApiClientProvider);
  return CountryRemoteDataSourceImpl(client);
});

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(
    ref.watch(addressRemoteDataSourceProvider),
    ref.watch(addressApiClientProvider),
    ref.watch(secureStorageServiceProvider),
  );
});

final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  return CountryRepositoryImpl(ref.watch(countryRemoteDataSourceProvider));
});
