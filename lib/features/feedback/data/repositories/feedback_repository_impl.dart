import 'package:flutter_riverpod_clean_architecture/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/entities/feedback_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/repositories/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource _remoteDataSource;

  FeedbackRepositoryImpl(this._remoteDataSource);

  @override
  Future<FeedbackEntity> submitFeedback(FeedbackRequest request) {
    return _remoteDataSource.submitFeedback(request);
  }

  @override
  Future<CheckFeedbackResponse> checkSubmitted({
    required String orderNumber,
    String? feedbackToken,
  }) {
    return _remoteDataSource.checkSubmitted(
      orderNumber: orderNumber,
      feedbackToken: feedbackToken,
    );
  }
}
