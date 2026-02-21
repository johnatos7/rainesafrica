import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/data/datasources/points_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/repositories/points_repository.dart';

class PointsRepositoryImpl implements PointsRepository {
  final PointsRemoteDataSource remoteDataSource;

  PointsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<({Failure? failure, PointsEntity? data})> getPoints() async {
    try {
      final points = await remoteDataSource.getPoints();
      return (failure: null, data: points);
    } on NetworkException {
      return (failure: NetworkFailure(), data: null);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } on UnauthorizedException {
      return (failure: UnauthorizedFailure(), data: null);
    } on NotFoundException {
      return (failure: NotFoundFailure(), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'Unexpected error: $e'),
        data: null,
      );
    }
  }

  @override
  Future<({Failure? failure, PointsTransactionsEntity? data})>
  getPointsTransactions({int page = 1, int paginate = 20}) async {
    try {
      final transactions = await remoteDataSource.getPointsTransactions(
        page: page,
        paginate: paginate,
      );
      return (failure: null, data: transactions);
    } on NetworkException {
      return (failure: NetworkFailure(), data: null);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } on UnauthorizedException {
      return (failure: UnauthorizedFailure(), data: null);
    } on NotFoundException {
      return (failure: NotFoundFailure(), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'Unexpected error: $e'),
        data: null,
      );
    }
  }
}
