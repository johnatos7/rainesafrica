import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Login a user with email and password
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
    required String countryCode,
    required int phone,
  });

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Check if a user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Get the current authenticated user
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    required String email,
    required String countryCode,
    required int phone,
  });

  /// Send forgot password email
  Future<Either<Failure, Map<String, dynamic>>> forgotPassword({
    required String email,
  });

  /// Verify reset token
  Future<Either<Failure, Map<String, dynamic>>> verifyToken({
    required String email,
    required String token,
  });

  /// Update password with token
  Future<Either<Failure, Map<String, dynamic>>> updatePassword({
    required String password,
    required String passwordConfirmation,
    required String token,
    required String email,
  });
}
