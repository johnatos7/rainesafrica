import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/entities/checkout_entity.dart';

abstract class CheckoutRepository {
  Future<Map<String, dynamic>> processCheckout(CheckoutRequestEntity request);
}
