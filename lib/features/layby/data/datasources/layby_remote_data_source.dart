import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';

/// Abstract data source for Layby API endpoints
abstract class LaybyRemoteDataSource {
  Future<LaybyEligibility> checkEligibility({
    required int productId,
    int? variationId,
  });

  Future<List<LaybyDocument>> getUploadedDocuments();

  Future<Map<String, dynamic>> uploadDocumentChunk({
    required String uploadId,
    required String fileName,
    required int chunkIndex,
    required int totalChunks,
    required Uint8List chunkData,
  });

  Future<LaybyAttachment> completeDocumentUpload({
    required String uploadId,
    required String fileName,
    required int totalChunks,
  });

  Future<LaybyApplication> applyForLayby(LaybyApplyRequest request);

  Future<LaybyApplicationsResponse> getMyApplications({
    String? status,
    int perPage = 10,
    int page = 1,
  });

  Future<LaybyApplication> getApplicationDetails(int applicationId);

  Future<Map<String, dynamic>> makePayment({
    required int applicationId,
    required double amount,
    required String paymentMethod,
    String currency = 'ZAR',
  });
}

/// Implementation of LaybyRemoteDataSource using ApiClient
class LaybyRemoteDataSourceImpl implements LaybyRemoteDataSource {
  final ApiClient _apiClient;

  LaybyRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<LaybyEligibility> checkEligibility({
    required int productId,
    int? variationId,
  }) async {
    final data = <String, dynamic>{'product_id': productId};
    if (variationId != null) {
      data['variation_id'] = variationId;
    }
    final response = await _apiClient.post(
      '/api/layby/check-eligibility',
      data: data,
    );
    return LaybyEligibility.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<List<LaybyDocument>> getUploadedDocuments() async {
    final response = await _apiClient.get('/api/layby/uploaded-document');
    final list = response as List<dynamic>? ?? [];
    return list
        .map((e) => LaybyDocument.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> uploadDocumentChunk({
    required String uploadId,
    required String fileName,
    required int chunkIndex,
    required int totalChunks,
    required Uint8List chunkData,
  }) async {
    final formData = FormData.fromMap({
      'uploadId': uploadId,
      'fileName': fileName,
      'chunkIndex': chunkIndex,
      'totalChunks': totalChunks,
      'chunk': MultipartFile.fromBytes(
        chunkData,
        filename: '${fileName}_chunk_$chunkIndex',
      ),
    });
    final response = await _apiClient.post(
      '/api/layby/documents/upload-chunk',
      data: formData,
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<LaybyAttachment> completeDocumentUpload({
    required String uploadId,
    required String fileName,
    required int totalChunks,
  }) async {
    final response = await _apiClient.post(
      '/api/layby/documents/upload-complete',
      data: {
        'uploadId': uploadId,
        'fileName': fileName,
        'totalChunks': totalChunks,
      },
    );
    final data = response as Map<String, dynamic>;
    return LaybyAttachment.fromJson(
      data['attachment'] as Map<String, dynamic>? ?? data,
    );
  }

  @override
  Future<LaybyApplication> applyForLayby(LaybyApplyRequest request) async {
    final response = await _apiClient.post(
      '/api/layby/apply',
      data: request.toJson(),
    );
    final data = response as Map<String, dynamic>;
    return LaybyApplication.fromJson(
      data['application'] as Map<String, dynamic>? ?? data,
    );
  }

  @override
  Future<LaybyApplicationsResponse> getMyApplications({
    String? status,
    int perPage = 10,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'per_page': perPage, 'page': page};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    final response = await _apiClient.get(
      '/api/layby/my-applications',
      queryParameters: queryParams,
    );
    return LaybyApplicationsResponse.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<LaybyApplication> getApplicationDetails(int applicationId) async {
    final response = await _apiClient.get(
      '/api/layby/applications/$applicationId',
    );
    final data = response as Map<String, dynamic>;
    // API may return data in 'application' key or directly
    final applicationData =
        data['application'] as Map<String, dynamic>? ?? data;
    return LaybyApplication.fromJson(applicationData);
  }

  @override
  Future<Map<String, dynamic>> makePayment({
    required int applicationId,
    required double amount,
    required String paymentMethod,
    String currency = 'ZAR',
  }) async {
    final response = await _apiClient.post(
      '/api/layby/applications/$applicationId/payment',
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'currency': currency,
      },
    );
    return response as Map<String, dynamic>;
  }
}
