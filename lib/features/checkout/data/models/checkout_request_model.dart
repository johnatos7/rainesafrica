import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/entities/checkout_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/domain/entities/cart_entity.dart';

class CheckoutRequestModel extends CheckoutRequestEntity {
  final int walletFlag;

  CheckoutRequestModel({
    required super.billingAddressId,
    required super.shippingAddressId,
    required super.paymentMethod,
    required super.deliveryTitle,
    required super.deliveryDescription,
    required super.deliveryPrice,
    required super.couponCode,
    required super.pointsAmount,
    required super.note,
    required super.currency,
    required super.currencySymbol,
    required super.returnUrl,
    required super.cancelUrl,
    required super.products,
    required super.shippingTotal,
    required super.taxTotal,
    required super.orderTotal,
    required super.grandTotal,
    required super.subTotal,
    this.walletFlag = 0,
  });

  factory CheckoutRequestModel.fromCart(
    CartEntity cart, {
    required int billingAddressId,
    required int shippingAddressId,
    required String paymentMethod,
    required String deliveryTitle,
    required String deliveryDescription,
    required double deliveryPrice,
    String couponCode = '',
    int pointsAmount = 0,
    String note = '',
    String currency = 'USD',
    String currencySymbol = '\$',
    String returnUrl = 'https://raines.africa/en/account/order/details',
    String cancelUrl = 'https://raines.africa',
    double shippingTotal = 0.00,
    double taxTotal = 0.00,
    double orderTotal = 0.00,
    double grandTotal = 0.00,
    double subTotal = 0.00,
  }) {
    return CheckoutRequestModel(
      billingAddressId: billingAddressId,
      shippingAddressId: shippingAddressId,
      paymentMethod: paymentMethod,
      deliveryTitle: deliveryTitle,
      deliveryDescription: deliveryDescription,
      deliveryPrice: deliveryPrice,
      couponCode: couponCode,
      pointsAmount: pointsAmount,
      note: note,
      currency: currency,
      currencySymbol: currencySymbol,
      returnUrl: returnUrl,
      cancelUrl: cancelUrl,
      shippingTotal: shippingTotal,
      taxTotal: taxTotal,
      orderTotal: orderTotal,
      grandTotal: grandTotal,
      subTotal: subTotal,
      walletFlag: 0,
      products:
          cart.items
              .map(
                (item) => CheckoutProductModel(
                  productId: item.productId ?? 0,
                  variationId: item.selectedVariationId,
                  selectedAttributeIds: item.selectedAttributeIds,
                  variationDisplayName: item.variationDisplayName,
                  quantity: item.quantity,
                  price: item.unitPrice,
                  itemShippingMethod: item.itemShippingMethod,
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'billing_address_id': billingAddressId,
      'shipping_address_id': shippingAddressId,
      'payment_method': paymentMethod,
      'delivery_title': deliveryTitle,
      'delivery_description': deliveryDescription,
      'delivery_price': deliveryPrice,
      'coupon_code': couponCode,
      'points_amount': pointsAmount,
      'wallet_balance': walletFlag,
      'products':
          products
              .map((product) => (product as CheckoutProductModel).toJson())
              .toList(),
      'note': note,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'sub_total': subTotal,
      'shipping_total': shippingTotal.toInt(),
      'tax_total': taxTotal,
      'order_total': orderTotal,
      'grand_total': grandTotal,
      'return_url': returnUrl,
      'cancel_url': cancelUrl,
    };
    return json;
  }
}

class CheckoutProductModel extends CheckoutProductEntity {
  CheckoutProductModel({
    required super.productId,
    super.variationId,
    super.selectedAttributeIds,
    super.variationDisplayName,
    required super.quantity,
    required super.price,
    super.itemShippingMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'variation_id': variationId,
      'selected_attribute_ids': selectedAttributeIds ?? [],
      'variation_display_name': variationDisplayName,
      'quantity': quantity,
      'price': price,
      'item_shipping_method': itemShippingMethod,
    };
  }
}
