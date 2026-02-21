import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/entities/checkout_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/datasources/checkout_local_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/data/models/checkout_request_model.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource _remoteDataSource;

  CheckoutRepositoryImpl({
    required CheckoutRemoteDataSource remoteDataSource,
    required CheckoutLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Map<String, dynamic>> processCheckout(
    CheckoutRequestEntity request,
  ) async {
    try {
      // Preserve wallet flag if the incoming request is already a model
      final requestModel =
          request is CheckoutRequestModel
              ? request
              : CheckoutRequestModel(
                billingAddressId: request.billingAddressId,
                shippingAddressId: request.shippingAddressId,
                paymentMethod: request.paymentMethod,
                deliveryTitle: request.deliveryTitle,
                deliveryDescription: request.deliveryDescription,
                deliveryPrice: request.deliveryPrice,
                couponCode: request.couponCode,
                pointsAmount: request.pointsAmount,
                note: request.note,
                currency: request.currency,
                currencySymbol: request.currencySymbol,
                returnUrl: request.returnUrl,
                cancelUrl: request.cancelUrl,
                products:
                    request.products
                        .map(
                          (product) => CheckoutProductModel(
                            productId: product.productId,
                            variationId: product.variationId,
                            quantity: product.quantity,
                            price: product.price,
                            itemShippingMethod: product.itemShippingMethod,
                          ),
                        )
                        .toList(),
                shippingTotal: request.shippingTotal,
                taxTotal: request.taxTotal,
                orderTotal: request.orderTotal,
                grandTotal: request.grandTotal,
                subTotal: request.subTotal,
              );

      final response = await _remoteDataSource.processCheckout(requestModel);
      return response;
    } catch (e) {
      throw Exception('Failed to process checkout: $e');
    }
  }
}
