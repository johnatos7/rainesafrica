import 'package:flutter_riverpod_clean_architecture/features/orders/data/datasources/refund_return_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/repositories/refund_return_repository.dart';

class RefundReturnRepositoryImpl implements RefundReturnRepository {
  final RefundReturnRemoteDataSource _remoteDataSource;

  RefundReturnRepositoryImpl({
    required RefundReturnRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<RefundEntity> requestRefund(RefundRequestEntity request) async {
    return await _remoteDataSource.requestRefund(request);
  }

  @override
  Future<ReturnEntity> requestReturn(ReturnRequestEntity request) async {
    return await _remoteDataSource.requestReturn(request);
  }

  @override
  Future<RefundListResponse> getRefunds({int page = 1}) async {
    return await _remoteDataSource.getRefunds(page: page);
  }

  @override
  Future<ReturnListResponse> getReturns() async {
    return await _remoteDataSource.getReturns();
  }
}
