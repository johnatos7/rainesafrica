import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<({Failure? failure, WalletEntity? data})> getWallet() async {
    try {
      final wallet = await remoteDataSource.getWallet();
      return (failure: null, data: wallet);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } on UnauthorizedException catch (e) {
      return (failure: UnauthorizedFailure(message: e.message), data: null);
    } on NotFoundException catch (e) {
      return (failure: NotFoundFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'Unexpected error: $e'),
        data: null,
      );
    }
  }

  @override
  Future<({Failure? failure, WalletTransactionsEntity? data})>
  getWalletTransactions({int page = 1, int paginate = 20}) async {
    try {
      final transactions = await remoteDataSource.getWalletTransactions(
        page: page,
        paginate: paginate,
      );
      return (failure: null, data: transactions);
    } on ServerException catch (e) {
      return (failure: ServerFailure(message: e.message), data: null);
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } on UnauthorizedException catch (e) {
      return (failure: UnauthorizedFailure(message: e.message), data: null);
    } on NotFoundException catch (e) {
      return (failure: NotFoundFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: ServerFailure(message: 'Unexpected error: $e'),
        data: null,
      );
    }
  }

  @override
  Future<Failure?> refundAll() async {
    try {
      await remoteDataSource.refundAll();
      return null;
    } on ServerException catch (e) {
      return ServerFailure(message: e.message);
    } on NetworkException catch (e) {
      return NetworkFailure(message: e.message);
    } on UnauthorizedException catch (e) {
      return UnauthorizedFailure(message: e.message);
    } on NotFoundException catch (e) {
      return NotFoundFailure(message: e.message);
    } catch (e) {
      return ServerFailure(message: 'Unexpected error: $e');
    }
  }
}
