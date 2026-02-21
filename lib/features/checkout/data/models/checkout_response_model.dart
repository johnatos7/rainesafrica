import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/entities/checkout_entity.dart';

class CheckoutResponseModel extends CheckoutResponseEntity {
  final String? feedbackToken;

  CheckoutResponseModel({
    super.orderNumber,
    super.transactionId,
    super.url,
    super.isRedirect,
    this.feedbackToken,
  });

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResponseModel(
      orderNumber: json['order_number'] as int?,
      transactionId: json['transaction_id'] as String?,
      url: json['url'] as String?,
      isRedirect: json['is_redirect'] as bool?,
      feedbackToken: json['feedback_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'transaction_id': transactionId,
      'url': url,
      'is_redirect': isRedirect,
      'feedback_token': feedbackToken,
    };
  }
}
