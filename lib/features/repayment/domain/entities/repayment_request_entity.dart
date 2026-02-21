class RepaymentRequestEntity {
  final String paymentMethod;
  final String returnUrl;
  final String cancelUrl;
  final String orderNumber;
  final double amount;
  final double total;
  final double grandTotal;
  final double payableTotal;
  final double payableAmount;
  final double amountToPay;
  final String currency;
  final String currencyCode;
  final String currencySymbol;
  final double baseAmount;
  final double fee;
  final double subTotal;
  final double shippingTotal;
  final double deliveryPrice;
  final double taxTotal;
  final double couponTotalDiscount;
  final double walletBalance;
  final double pointsAmount;

  const RepaymentRequestEntity({
    required this.paymentMethod,
    required this.returnUrl,
    required this.cancelUrl,
    required this.orderNumber,
    required this.amount,
    required this.total,
    required this.grandTotal,
    required this.payableTotal,
    required this.payableAmount,
    required this.amountToPay,
    required this.currency,
    required this.currencyCode,
    required this.currencySymbol,
    required this.baseAmount,
    required this.fee,
    required this.subTotal,
    required this.shippingTotal,
    required this.deliveryPrice,
    required this.taxTotal,
    required this.couponTotalDiscount,
    required this.walletBalance,
    required this.pointsAmount,
  });
}
