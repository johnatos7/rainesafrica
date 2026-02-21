import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/domain/entities/points_entity.dart';

abstract class PointsRemoteDataSource {
  Future<PointsEntity> getPoints();
  Future<PointsTransactionsEntity> getPointsTransactions({
    int page = 1,
    int paginate = 20,
  });
}

class PointsRemoteDataSourceImpl implements PointsRemoteDataSource {
  final ApiClient client;
  final NetworkInfo networkInfo;

  PointsRemoteDataSourceImpl({required this.client, required this.networkInfo});

  @override
  Future<PointsEntity> getPoints() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final response = await client.get('/api/points/consumer');
      return PointsEntity.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<PointsTransactionsEntity> getPointsTransactions({
    int page = 1,
    int paginate = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final response = await client.get(
        '/api/points/consumer',
        queryParameters: {'page': page, 'paginate': paginate},
      );
      return PointsTransactionsEntity.fromJson(response['transactions'] ?? {});
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
