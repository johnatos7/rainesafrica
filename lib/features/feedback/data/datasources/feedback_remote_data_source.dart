import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/entities/feedback_entity.dart';

/// Remote data source for marketing feedback API calls
abstract class FeedbackRemoteDataSource {
  Future<FeedbackEntity> submitFeedback(FeedbackRequest request);
  Future<CheckFeedbackResponse> checkSubmitted({
    required String orderNumber,
    String? feedbackToken,
  });
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final ApiClient _apiClient;

  FeedbackRemoteDataSourceImpl(this._apiClient);

  @override
  Future<FeedbackEntity> submitFeedback(FeedbackRequest request) async {
    final data = await _apiClient.post(
      '/api/marketing-feedback/submit',
      data: request.toJson(),
    );

    // API may return null on success — handle gracefully
    if (data == null) {
      return FeedbackEntity.fromJson({});
    }

    if (data is Map<String, dynamic>) {
      final feedbackData = data['feedback'];
      if (feedbackData is Map<String, dynamic>) {
        return FeedbackEntity.fromJson(feedbackData);
      }
      return FeedbackEntity.fromJson(data);
    }

    return FeedbackEntity.fromJson({});
  }

  @override
  Future<CheckFeedbackResponse> checkSubmitted({
    required String orderNumber,
    String? feedbackToken,
  }) async {
    final queryParams = <String, dynamic>{'order_number': orderNumber};
    if (feedbackToken != null) queryParams['feedback_token'] = feedbackToken;

    final data = await _apiClient.get(
      '/api/marketing-feedback/check-submitted',
      queryParameters: queryParams,
    );

    if (data is Map<String, dynamic>) {
      return CheckFeedbackResponse.fromJson(data);
    }

    // Default to not-submitted if response is null
    return CheckFeedbackResponse.fromJson({});
  }
}
