class RepaymentResponseEntity {
  final String orderNumber;
  final String? transactionId;
  final bool isRedirect;
  final String? redirectUrl;
  final String? paymentUrl;
  final String status;
  final String? message;

  const RepaymentResponseEntity({
    required this.orderNumber,
    this.transactionId,
    required this.isRedirect,
    this.redirectUrl,
    this.paymentUrl,
    required this.status,
    this.message,
  });
}
