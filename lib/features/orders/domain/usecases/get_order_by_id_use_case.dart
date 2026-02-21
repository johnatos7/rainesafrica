import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetOrderByIdUseCase implements UseCase<OrderEntity, GetOrderByIdParams> {
  final OrderRepository _repository;

  GetOrderByIdUseCase({required OrderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) async {
    try {
      final result = await _repository.getOrderById(params.orderId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class GetOrderByIdParams {
  final int orderId;

  GetOrderByIdParams({required this.orderId});
}
