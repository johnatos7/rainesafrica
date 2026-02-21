import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetOrderStatusesUseCase
    implements UseCase<OrderStatusListResponse, NoParams> {
  final OrderRepository _repository;

  GetOrderStatusesUseCase({required OrderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrderStatusListResponse>> call(NoParams params) async {
    try {
      final result = await _repository.getOrderStatuses();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
