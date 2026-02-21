import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/data/datasources/feedback_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/data/repositories/feedback_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/entities/feedback_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/domain/repositories/feedback_repository.dart';

// --- Infrastructure ---

final feedbackDataSourceProvider = Provider<FeedbackRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FeedbackRemoteDataSourceImpl(apiClient);
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final dataSource = ref.watch(feedbackDataSourceProvider);
  return FeedbackRepositoryImpl(dataSource);
});

// --- State ---

class FeedbackFormState {
  final bool isLoading;
  final bool isSubmitted;
  final String? error;
  final FeedbackEntity? submittedFeedback;

  const FeedbackFormState({
    this.isLoading = false,
    this.isSubmitted = false,
    this.error,
    this.submittedFeedback,
  });

  FeedbackFormState copyWith({
    bool? isLoading,
    bool? isSubmitted,
    String? error,
    FeedbackEntity? submittedFeedback,
  }) {
    return FeedbackFormState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: error,
      submittedFeedback: submittedFeedback ?? this.submittedFeedback,
    );
  }
}

class FeedbackNotifier extends StateNotifier<FeedbackFormState> {
  final FeedbackRepository _repository;

  FeedbackNotifier(this._repository) : super(const FeedbackFormState());

  Future<bool> submitFeedback(FeedbackRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final feedback = await _repository.submitFeedback(request);
      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        submittedFeedback: feedback,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const FeedbackFormState();
  }
}

final feedbackNotifierProvider =
    StateNotifierProvider.autoDispose<FeedbackNotifier, FeedbackFormState>((
      ref,
    ) {
      final repo = ref.watch(feedbackRepositoryProvider);
      return FeedbackNotifier(repo);
    });
