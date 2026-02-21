import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_response_entity.dart';

class RepaymentResponseModel {
  final String orderNumber;
  final String? transactionId;
  final bool isRedirect;
  final String? redirectUrl;
  final String? paymentUrl;
  final String status;
  final String? message;

  const RepaymentResponseModel({
    required this.orderNumber,
    this.transactionId,
    required this.isRedirect,
    this.redirectUrl,
    this.paymentUrl,
    required this.status,
    this.message,
  });

  factory RepaymentResponseModel.fromJson(Map<String, dynamic> json) {
    print('🔄 REPAYMENT MODEL: Parsing JSON response');
    print('🔄 REPAYMENT MODEL: Raw JSON: $json');

    try {
      final orderNumber = json['order_number']?.toString() ?? '';
      print('🔄 REPAYMENT MODEL: Parsed orderNumber: $orderNumber');

      final transactionId = json['transaction_id']?.toString();
      print('🔄 REPAYMENT MODEL: Parsed transactionId: $transactionId');

      final isRedirect = json['is_redirect'] as bool? ?? false;
      print('🔄 REPAYMENT MODEL: Parsed isRedirect: $isRedirect');

      final redirectUrl =
          json['url'] as String? ?? json['redirect_url'] as String?;
      print('🔄 REPAYMENT MODEL: Parsed redirectUrl: $redirectUrl');

      final paymentUrl = json['payment_url'] as String?;
      print('🔄 REPAYMENT MODEL: Parsed paymentUrl: $paymentUrl');

      final status = json['status']?.toString() ?? 'pending';
      print('🔄 REPAYMENT MODEL: Parsed status: $status');

      final message = json['message'] as String?;
      print('🔄 REPAYMENT MODEL: Parsed message: $message');

      print('✅ REPAYMENT MODEL: Successfully parsed all fields');

      return RepaymentResponseModel(
        orderNumber: orderNumber,
        transactionId: transactionId,
        isRedirect: isRedirect,
        redirectUrl: redirectUrl,
        paymentUrl: paymentUrl,
        status: status,
        message: message,
      );
    } catch (e, stackTrace) {
      print('❌ REPAYMENT MODEL: Error parsing JSON: $e');
      print('❌ REPAYMENT MODEL: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'transaction_id': transactionId,
      'is_redirect': isRedirect,
      'redirect_url': redirectUrl,
      'payment_url': paymentUrl,
      'status': status,
      'message': message,
    };
  }

  RepaymentResponseEntity toEntity() {
    return RepaymentResponseEntity(
      orderNumber: orderNumber,
      transactionId: transactionId,
      isRedirect: isRedirect,
      redirectUrl: redirectUrl,
      paymentUrl: paymentUrl,
      status: status,
      message: message,
    );
  }
}
