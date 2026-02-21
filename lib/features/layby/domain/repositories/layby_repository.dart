import 'dart:typed_data';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';

/// Abstract repository for the Layby feature
abstract class LaybyRepository {
  /// Check if a product is eligible for layby
  Future<LaybyEligibility> checkEligibility({
    required int productId,
    int? variationId,
  });

  /// Get user's previously uploaded ID documents
  Future<List<LaybyDocument>> getUploadedDocuments();

  /// Upload a document chunk
  Future<Map<String, dynamic>> uploadDocumentChunk({
    required String uploadId,
    required String fileName,
    required int chunkIndex,
    required int totalChunks,
    required Uint8List chunkData,
  });

  /// Complete document upload
  Future<LaybyAttachment> completeDocumentUpload({
    required String uploadId,
    required String fileName,
    required int totalChunks,
  });

  /// Apply for layby
  Future<LaybyApplication> applyForLayby(LaybyApplyRequest request);

  /// Get user's layby applications
  Future<LaybyApplicationsResponse> getMyApplications({
    String? status,
    int perPage = 10,
    int page = 1,
  });

  /// Get details of a specific application
  Future<LaybyApplication> getApplicationDetails(int applicationId);

  /// Make a layby installment payment
  Future<Map<String, dynamic>> makePayment({
    required int applicationId,
    required double amount,
    required String paymentMethod,
    String currency = 'ZAR',
  });
}
