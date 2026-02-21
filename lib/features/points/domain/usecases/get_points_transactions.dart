import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/repositories/points_repository.dart';

class GetPointsTransactions {
  final PointsRepository repository;

  GetPointsTransactions({required this.repository});

  Future<({Failure? failure, PointsTransactionsEntity? data})> call({
    int page = 1,
    int paginate = 20,
  }) async {
    return await repository.getPointsTransactions(
      page: page,
      paginate: paginate,
    );
  }
}
