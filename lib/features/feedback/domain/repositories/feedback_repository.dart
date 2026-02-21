import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/entities/feedback_entity.dart';

/// Abstract repository for marketing feedback operations
abstract class FeedbackRepository {
  /// Submit marketing feedback for an order
  Future<FeedbackEntity> submitFeedback(FeedbackRequest request);

  /// Check if feedback was already submitted for an order
  Future<CheckFeedbackResponse> checkSubmitted({
    required String orderNumber,
    String? feedbackToken,
  });
}
