import 'package:equatable/equatable.dart';

class CheckoutRequestEntity extends Equatable {
  final int billingAddressId;
  final int shippingAddressId;
  final String paymentMethod;
  final String deliveryTitle;
  final String deliveryDescription;
  final double deliveryPrice;
  final double shippingTotal;
  final double taxTotal;
  final double orderTotal;
  final double subTotal;
  final double grandTotal;
  final String couponCode;
  final int pointsAmount;
  final String note;
  final String currency;
  final String currencySymbol;
  final String returnUrl;
  final String cancelUrl;
  final List<CheckoutProductEntity> products;

  const CheckoutRequestEntity({
    required this.billingAddressId,
    required this.shippingAddressId,
    required this.paymentMethod,
    required this.deliveryTitle,
    required this.deliveryDescription,
    required this.deliveryPrice,
    required this.couponCode,
    required this.pointsAmount,
    required this.note,
    required this.currency,
    required this.currencySymbol,
    required this.returnUrl,
    required this.cancelUrl,
    required this.products,
    required this.shippingTotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.orderTotal,
    required this.subTotal,
  });

  @override
  List<Object?> get props => [
    billingAddressId,
    shippingAddressId,
    paymentMethod,
    deliveryTitle,
    deliveryDescription,
    deliveryPrice,
    couponCode,
    pointsAmount,
    note,
    currency,
    currencySymbol,
    returnUrl,
    cancelUrl,
    products,
    shippingTotal,
    taxTotal,
    grandTotal,
    orderTotal,
    subTotal,
  ];
}

class CheckoutProductEntity extends Equatable {
  final int productId;
  final int? variationId;
  final List<int>? selectedAttributeIds;
  final String? variationDisplayName;
  final int quantity;
  final double price;
  final String? itemShippingMethod;

  const CheckoutProductEntity({
    required this.productId,
    this.variationId,
    this.selectedAttributeIds,
    this.variationDisplayName,
    required this.quantity,
    required this.price,
    this.itemShippingMethod,
  });

  @override
  List<Object?> get props => [
    productId,
    variationId,
    selectedAttributeIds,
    variationDisplayName,
    quantity,
    price,
    itemShippingMethod,
  ];
}

class CheckoutResponseEntity extends Equatable {
  final int? orderNumber;
  final String? transactionId;
  final String? url;
  final bool? isRedirect;

  const CheckoutResponseEntity({
    this.orderNumber,
    this.transactionId,
    this.url,
    this.isRedirect,
  });

  @override
  List<Object?> get props => [orderNumber, transactionId, url, isRedirect];
}
