import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRemoteDataSource {
  Future<WalletEntity> getWallet();
  Future<WalletTransactionsEntity> getWalletTransactions({
    int page = 1,
    int paginate = 20,
  });
  Future<void> refundAll();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient client;
  final NetworkInfo networkInfo;

  WalletRemoteDataSourceImpl({required this.client, required this.networkInfo});

  @override
  Future<WalletEntity> getWallet() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final response = await client.get('/api/wallet/consumer');
      return WalletEntity.fromJson(response as Map<String, dynamic>);
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
  Future<WalletTransactionsEntity> getWalletTransactions({
    int page = 1,
    int paginate = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final response = await client.get(
        '/api/wallet/consumer',
        queryParameters: {'page': page, 'paginate': paginate},
      );
      return WalletTransactionsEntity.fromJson(response['transactions'] ?? {});
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
  Future<void> refundAll() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      await client.post('/api/wallet/refund-all');
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
