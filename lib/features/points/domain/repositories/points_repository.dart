import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';

abstract class PointsRepository {
  Future<({Failure? failure, PointsEntity? data})> getPoints();
  Future<({Failure? failure, PointsTransactionsEntity? data})>
  getPointsTransactions({int page = 1, int paginate = 20});
}
