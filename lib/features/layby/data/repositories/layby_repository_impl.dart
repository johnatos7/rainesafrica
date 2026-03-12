import 'dart:typed_data';
import 'package:flutter_riverpod_clean_architecture/features/layby/data/datasources/layby_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/repositories/layby_repository.dart';

class LaybyRepositoryImpl implements LaybyRepository {
  final LaybyRemoteDataSource _remoteDataSource;

  LaybyRepositoryImpl({required LaybyRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<LaybyDocument>> getUploadedDocuments() async {
    return _remoteDataSource.getUploadedDocuments();
  }

  @override
  Future<Map<String, dynamic>> uploadDocumentChunk({
    required String uploadId,
    required String fileName,
    required int chunkIndex,
    required int totalChunks,
    required Uint8List chunkData,
  }) async {
    return _remoteDataSource.uploadDocumentChunk(
      uploadId: uploadId,
      fileName: fileName,
      chunkIndex: chunkIndex,
      totalChunks: totalChunks,
      chunkData: chunkData,
    );
  }

  @override
  Future<LaybyAttachment> completeDocumentUpload({
    required String uploadId,
    required String fileName,
    required int totalChunks,
  }) async {
    return _remoteDataSource.completeDocumentUpload(
      uploadId: uploadId,
      fileName: fileName,
      totalChunks: totalChunks,
    );
  }

  @override
  Future<LaybyApplication> applyForLayby(LaybyApplyRequest request) async {
    return _remoteDataSource.applyForLayby(request);
  }

  @override
  Future<LaybyApplicationsResponse> getMyApplications({
    String? status,
    int perPage = 10,
    int page = 1,
  }) async {
    return _remoteDataSource.getMyApplications(
      status: status,
      perPage: perPage,
      page: page,
    );
  }

  @override
  Future<LaybyApplication> getApplicationDetails(int applicationId) async {
    return _remoteDataSource.getApplicationDetails(applicationId);
  }

  @override
  Future<Map<String, dynamic>> makePayment({
    required int applicationId,
    required double amount,
    required String paymentMethod,
    String currency = 'USD',
  }) async {
    return _remoteDataSource.makePayment(
      applicationId: applicationId,
      amount: amount,
      paymentMethod: paymentMethod,
      currency: currency,
    );
  }

  @override
  Future<void> updateApplicationDocument({
    required int applicationId,
    required LaybyUpdateDocumentRequest request,
  }) async {
    return _remoteDataSource.updateApplicationDocument(
      applicationId: applicationId,
      request: request,
    );
  }
}
