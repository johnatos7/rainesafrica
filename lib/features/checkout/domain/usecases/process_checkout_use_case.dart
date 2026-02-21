import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/entities/checkout_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/domain/repositories/checkout_repository.dart';

class ProcessCheckoutUseCase {
  final CheckoutRepository _repository;

  ProcessCheckoutUseCase(this._repository);

  Future<Map<String, dynamic>> call(CheckoutRequestEntity request) async {
    return await _repository.processCheckout(request);
  }
}
