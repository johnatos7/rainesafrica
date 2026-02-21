import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/legal/data/models/legal_document_model.dart';

abstract class LegalRemoteDataSource {
  Future<LegalDocumentsResponseModel> getLegalDocuments({
    int page = 1,
    int perPage = 10,
  });
}

class LegalRemoteDataSourceImpl implements LegalRemoteDataSource {
  final ApiClient client;
  final NetworkInfo networkInfo;

  LegalRemoteDataSourceImpl({required this.client, required this.networkInfo});

  @override
  Future<LegalDocumentsResponseModel> getLegalDocuments({
    int page = 1,
    int perPage = 10,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }

    try {
      final response = await client.get(
        '/api/page',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      return LegalDocumentsResponseModel.fromJson(
        response as Map<String, dynamic>,
      );
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
