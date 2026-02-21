import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/domain/entities/payment_account_entity.dart';

abstract class PaymentAccountRepository {
  Future<Either<Failure, PaymentAccountEntity>> getPaymentAccount();
  Future<Either<Failure, PaymentAccountEntity>> createPaymentAccount({
    required String bankAccountNo,
    required String bankHolderName,
    required String bankName,
    required String paypalEmail,
    required String swift,
    String? ifsc,
  });
  Future<Either<Failure, PaymentAccountEntity>> updatePaymentAccount({
    required int id,
    required String bankAccountNo,
    required String bankHolderName,
    required String bankName,
    required String paypalEmail,
    required String swift,
    String? ifsc,
  });
  Future<Either<Failure, void>> deletePaymentAccount(int id);
}
