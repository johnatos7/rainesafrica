import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/data/datasources/voucher_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/entities/voucher_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherRemoteDataSource remoteDataSource;

  VoucherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<VoucherEntity>>> getMyVouchers({
    String? status,
  }) async {
    try {
      final vouchers = await remoteDataSource.getMyVouchers(status: status);
      return Right(vouchers);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VoucherEntity>>> getRedeemedVouchers() async {
    try {
      final vouchers = await remoteDataSource.getRedeemedVouchers();
      return Right(vouchers);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VoucherActionResult>> checkVoucher(String code) async {
    try {
      final result = await remoteDataSource.checkVoucher(code);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VoucherActionResult>> redeemVoucher(
    String code,
  ) async {
    try {
      final result = await remoteDataSource.redeemVoucher(code);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> resendVoucherEmail(int voucherId) async {
    try {
      final message = await remoteDataSource.resendVoucherEmail(voucherId);
      return Right(message);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
