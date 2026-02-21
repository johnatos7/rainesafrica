import 'package:equatable/equatable.dart';

/// Marketing feedback entity returned after submission
class FeedbackEntity extends Equatable {
  final int id;
  final String orderNumber;
  final int? orderId;
  final int? userId;
  final String orderingProcessRating;
  final String heardAboutSource;
  final String? heardAboutOther;
  final String? additionalComments;
  final String createdAt;
  final String updatedAt;

  const FeedbackEntity({
    required this.id,
    required this.orderNumber,
    this.orderId,
    this.userId,
    required this.orderingProcessRating,
    required this.heardAboutSource,
    this.heardAboutOther,
    this.additionalComments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackEntity.fromJson(Map<String, dynamic> json) {
    return FeedbackEntity(
      id: json['id'] as int,
      orderNumber: json['order_number']?.toString() ?? '',
      orderId: json['order_id'] as int?,
      userId: json['user_id'] as int?,
      orderingProcessRating: json['ordering_process_rating'] as String? ?? '',
      heardAboutSource: json['heard_about_source'] as String? ?? '',
      heardAboutOther: json['heard_about_other'] as String?,
      additionalComments: json['additional_comments'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, orderNumber];
}

/// Check-submitted response
class CheckFeedbackResponse {
  final bool submitted;
  final FeedbackEntity? feedback;
  final String? orderNumber;

  const CheckFeedbackResponse({
    required this.submitted,
    this.feedback,
    this.orderNumber,
  });

  factory CheckFeedbackResponse.fromJson(Map<String, dynamic> json) {
    return CheckFeedbackResponse(
      submitted: json['submitted'] as bool? ?? false,
      feedback:
          json['feedback'] != null
              ? FeedbackEntity.fromJson(
                json['feedback'] as Map<String, dynamic>,
              )
              : null,
      orderNumber:
          json['order'] != null
              ? (json['order'] as Map<String, dynamic>)['order_number']
                  ?.toString()
              : null,
    );
  }
}

/// Request model for submitting feedback
class FeedbackRequest {
  final String orderNumber;
  final String orderingProcessRating;
  final String heardAboutSource;
  final String? heardAboutOther;
  final String? additionalComments;
  final String? feedbackToken;

  const FeedbackRequest({
    required this.orderNumber,
    required this.orderingProcessRating,
    required this.heardAboutSource,
    this.heardAboutOther,
    this.additionalComments,
    this.feedbackToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'order_number': orderNumber,
      'ordering_process_rating': orderingProcessRating,
      'heard_about_source': heardAboutSource,
    };
    if (heardAboutOther != null) map['heard_about_other'] = heardAboutOther;
    if (additionalComments != null && additionalComments!.isNotEmpty) {
      map['additional_comments'] = additionalComments;
    }
    if (feedbackToken != null) map['feedback_token'] = feedbackToken;
    return map;
  }
}
