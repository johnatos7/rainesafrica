import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/entities/voucher_entity.dart';

abstract class VoucherRepository {
  Future<Either<Failure, List<VoucherEntity>>> getMyVouchers({String? status});
  Future<Either<Failure, List<VoucherEntity>>> getRedeemedVouchers();
  Future<Either<Failure, VoucherActionResult>> checkVoucher(String code);
  Future<Either<Failure, VoucherActionResult>> redeemVoucher(String code);
  Future<Either<Failure, String>> resendVoucherEmail(int voucherId);
}
