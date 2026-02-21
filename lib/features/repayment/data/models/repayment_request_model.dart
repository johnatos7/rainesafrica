import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_request_entity.dart';

class RepaymentRequestModel {
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

  const RepaymentRequestModel({
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

  factory RepaymentRequestModel.fromEntity(RepaymentRequestEntity entity) {
    return RepaymentRequestModel(
      paymentMethod: entity.paymentMethod,
      returnUrl: entity.returnUrl,
      cancelUrl: entity.cancelUrl,
      orderNumber: entity.orderNumber,
      amount: entity.amount,
      total: entity.total,
      grandTotal: entity.grandTotal,
      payableTotal: entity.payableTotal,
      payableAmount: entity.payableAmount,
      amountToPay: entity.amountToPay,
      currency: entity.currency,
      currencyCode: entity.currencyCode,
      currencySymbol: entity.currencySymbol,
      baseAmount: entity.baseAmount,
      fee: entity.fee,
      subTotal: entity.subTotal,
      shippingTotal: entity.shippingTotal,
      deliveryPrice: entity.deliveryPrice,
      taxTotal: entity.taxTotal,
      couponTotalDiscount: entity.couponTotalDiscount,
      walletBalance: entity.walletBalance,
      pointsAmount: entity.pointsAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'return_url': returnUrl,
      'cancel_url': cancelUrl,
      'order_number': orderNumber,
      'amount': amount,
      'total': total,
      'grand_total': grandTotal,
      'payable_total': payableTotal,
      'payable_amount': payableAmount,
      'amount_to_pay': amountToPay,
      'currency': currency,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'base_amount': baseAmount,
      'fee': fee,
      'sub_total': subTotal,
      'shipping_total': shippingTotal,
      'delivery_price': deliveryPrice,
      'tax_total': taxTotal,
      'coupon_total_discount': couponTotalDiscount,
      'wallet_balance': walletBalance,
      'points_amount': pointsAmount,
    };
  }
}
