import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/data/datasources/payment_account_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/data/models/payment_account_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/domain/entities/payment_account_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/domain/repositories/payment_account_repository.dart';

class PaymentAccountRepositoryImpl implements PaymentAccountRepository {
  final PaymentAccountRemoteDataSource _remoteDataSource;

  PaymentAccountRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, PaymentAccountEntity>> getPaymentAccount() async {
    try {
      final paymentAccount = await _remoteDataSource.getPaymentAccount();
      return Right(paymentAccount.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentAccountEntity>> createPaymentAccount({
    required String bankAccountNo,
    required String bankHolderName,
    required String bankName,
    required String paypalEmail,
    required String swift,
    String? ifsc,
  }) async {
    try {
      final request = PaymentAccountRequestModel(
        bankAccountNo: bankAccountNo,
        bankHolderName: bankHolderName,
        bankName: bankName,
        paypalEmail: paypalEmail,
        swift: swift,
        ifsc: ifsc,
      );

      final paymentAccount = await _remoteDataSource.createPaymentAccount(
        request,
      );
      return Right(paymentAccount.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentAccountEntity>> updatePaymentAccount({
    required int id,
    required String bankAccountNo,
    required String bankHolderName,
    required String bankName,
    required String paypalEmail,
    required String swift,
    String? ifsc,
  }) async {
    try {
      final request = PaymentAccountRequestModel(
        bankAccountNo: bankAccountNo,
        bankHolderName: bankHolderName,
        bankName: bankName,
        paypalEmail: paypalEmail,
        swift: swift,
        ifsc: ifsc,
      );

      final paymentAccount = await _remoteDataSource.updatePaymentAccount(
        id,
        request,
      );
      return Right(paymentAccount.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentAccount(int id) async {
    try {
      await _remoteDataSource.deletePaymentAccount(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on Exception {
      return const Left(ServerFailure());
    }
  }
}
