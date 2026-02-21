import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_request_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_response_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/repositories/repayment_repository.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class ProcessRepaymentUseCase {
  final RepaymentRepository _repository;

  ProcessRepaymentUseCase({required RepaymentRepository repository})
    : _repository = repository;

  Future<Either<Failure, RepaymentResponseEntity>> call(
    RepaymentRequestEntity request,
  ) async {
    try {
      final result = await _repository.processRepayment(request);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
