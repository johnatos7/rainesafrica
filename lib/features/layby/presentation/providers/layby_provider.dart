import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/data/datasources/layby_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/data/repositories/layby_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/repositories/layby_repository.dart';

// ---------------------------------------------------------------------------
// Data Source & Repository providers
// ---------------------------------------------------------------------------

final laybyRemoteDataSourceProvider = Provider<LaybyRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LaybyRemoteDataSourceImpl(apiClient: apiClient);
});

final laybyRepositoryProvider = Provider<LaybyRepository>((ref) {
  final dataSource = ref.watch(laybyRemoteDataSourceProvider);
  return LaybyRepositoryImpl(remoteDataSource: dataSource);
});

// ---------------------------------------------------------------------------
// Eligibility check
// ---------------------------------------------------------------------------

/// Parameter class for eligibility check
class EligibilityParams {
  final int productId;
  final int? variationId;

  const EligibilityParams({required this.productId, this.variationId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EligibilityParams &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          variationId == other.variationId;

  @override
  int get hashCode => productId.hashCode ^ (variationId?.hashCode ?? 0);
}

final laybyEligibilityProvider =
    FutureProvider.family<LaybyEligibility, EligibilityParams>((
      ref,
      params,
    ) async {
      final repo = ref.watch(laybyRepositoryProvider);
      return repo.checkEligibility(
        productId: params.productId,
        variationId: params.variationId,
      );
    });

// ---------------------------------------------------------------------------
// Uploaded documents
// ---------------------------------------------------------------------------

final laybyUploadedDocumentsProvider = FutureProvider<List<LaybyDocument>>((
  ref,
) async {
  final repo = ref.watch(laybyRepositoryProvider);
  return repo.getUploadedDocuments();
});

// ---------------------------------------------------------------------------
// Applications list
// ---------------------------------------------------------------------------

class ApplicationsListParams {
  final String? status;
  final int page;

  const ApplicationsListParams({this.status, this.page = 1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationsListParams &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          page == other.page;

  @override
  int get hashCode => (status?.hashCode ?? 0) ^ page.hashCode;
}

final laybyApplicationsProvider =
    FutureProvider.family<LaybyApplicationsResponse, ApplicationsListParams>((
      ref,
      params,
    ) async {
      final repo = ref.watch(laybyRepositoryProvider);
      return repo.getMyApplications(status: params.status, page: params.page);
    });

// ---------------------------------------------------------------------------
// Application details
// ---------------------------------------------------------------------------

final laybyApplicationDetailsProvider =
    FutureProvider.family<LaybyApplication, int>((ref, id) async {
      final repo = ref.watch(laybyRepositoryProvider);
      return repo.getApplicationDetails(id);
    });

// ---------------------------------------------------------------------------
// Layby Notifier — handles apply, upload, payment state
// ---------------------------------------------------------------------------

@immutable
class LaybyState {
  final bool isLoading;
  final String? error;
  final LaybyApplication? lastApplication;
  final double uploadProgress;
  final String? paymentRedirectUrl;

  const LaybyState({
    this.isLoading = false,
    this.error,
    this.lastApplication,
    this.uploadProgress = 0,
    this.paymentRedirectUrl,
  });

  LaybyState copyWith({
    bool? isLoading,
    String? error,
    LaybyApplication? lastApplication,
    double? uploadProgress,
    String? paymentRedirectUrl,
  }) {
    return LaybyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastApplication: lastApplication ?? this.lastApplication,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      paymentRedirectUrl: paymentRedirectUrl,
    );
  }
}

class LaybyNotifier extends StateNotifier<LaybyState> {
  final LaybyRepository _repository;

  LaybyNotifier({required LaybyRepository repository})
    : _repository = repository,
      super(const LaybyState());

  /// Upload a document in chunks and return the attachment
  Future<LaybyAttachment?> uploadDocument({
    required Uint8List fileBytes,
    required String fileName,
    int chunkSize = 90 * 1024, // 90KB chunks (server limit: 100KB)
  }) async {
    state = state.copyWith(isLoading: true, error: null, uploadProgress: 0);

    try {
      final uploadId = DateTime.now().millisecondsSinceEpoch.toString();
      final totalChunks = (fileBytes.length / chunkSize).ceil();

      print('📤 [LAYBY UPLOAD] Starting upload: $fileName');
      print('📤 [LAYBY UPLOAD] File size: ${fileBytes.length} bytes');
      print('📤 [LAYBY UPLOAD] Total chunks: $totalChunks');
      print('📤 [LAYBY UPLOAD] Upload ID: $uploadId');

      // Upload chunks
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end =
            (start + chunkSize > fileBytes.length)
                ? fileBytes.length
                : start + chunkSize;
        final chunk = fileBytes.sublist(start, end);

        print(
          '📤 [LAYBY UPLOAD] Uploading chunk ${i + 1}/$totalChunks (${chunk.length} bytes)',
        );

        await _repository.uploadDocumentChunk(
          uploadId: uploadId,
          fileName: fileName,
          chunkIndex: i,
          totalChunks: totalChunks,
          chunkData: Uint8List.fromList(chunk),
        );

        state = state.copyWith(uploadProgress: (i + 1) / totalChunks);
      }

      print('📤 [LAYBY UPLOAD] All chunks uploaded, completing...');

      // Complete upload
      final attachment = await _repository.completeDocumentUpload(
        uploadId: uploadId,
        fileName: fileName,
        totalChunks: totalChunks,
      );

      print(
        '📤 [LAYBY UPLOAD] Upload complete! Attachment ID: ${attachment.id}',
      );

      state = state.copyWith(isLoading: false, uploadProgress: 1.0);
      return attachment;
    } catch (e, stackTrace) {
      print('❌ [LAYBY UPLOAD] Upload failed: $e');
      print('❌ [LAYBY UPLOAD] Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        uploadProgress: 0,
      );
      return null;
    }
  }

  /// Apply for layby
  Future<LaybyApplication?> applyForLayby(LaybyApplyRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final application = await _repository.applyForLayby(request);
      state = state.copyWith(isLoading: false, lastApplication: application);
      return application;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Make a payment and get redirect URL
  Future<String?> makePayment({
    required int applicationId,
    required double amount,
    required String paymentMethod,
    String currency = 'ZAR',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.makePayment(
        applicationId: applicationId,
        amount: amount,
        paymentMethod: paymentMethod,
        currency: currency,
      );
      final redirectUrl = response['redirect_url'] as String?;
      state = state.copyWith(isLoading: false, paymentRedirectUrl: redirectUrl);
      return redirectUrl;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearPaymentUrl() {
    state = state.copyWith(paymentRedirectUrl: null);
  }
}

final laybyNotifierProvider = StateNotifierProvider<LaybyNotifier, LaybyState>((
  ref,
) {
  final repository = ref.watch(laybyRepositoryProvider);
  return LaybyNotifier(repository: repository);
});
