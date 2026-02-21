import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_request_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/repayment/domain/entities/repayment_response_entity.dart';

abstract class RepaymentRepository {
  Future<RepaymentResponseEntity> processRepayment(
    RepaymentRequestEntity request,
  );
}
