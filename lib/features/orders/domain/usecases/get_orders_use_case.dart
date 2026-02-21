import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/order_repository.dart';
import 'package:dartz/dartz.dart';

class GetOrdersUseCase implements UseCase<OrderListResponse, GetOrdersParams> {
  final OrderRepository _repository;

  GetOrdersUseCase({required OrderRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, OrderListResponse>> call(
    GetOrdersParams params,
  ) async {
    try {
      final result = await _repository.getOrders(page: params.page);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class GetOrdersParams {
  final int page;

  GetOrdersParams({required this.page});
}
