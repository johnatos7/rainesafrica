import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/refund_list_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/return_list_entity.dart';

abstract class RefundReturnRepository {
  Future<RefundEntity> requestRefund(RefundRequestEntity request);
  Future<ReturnEntity> requestReturn(ReturnRequestEntity request);
  Future<RefundListResponse> getRefunds({int page = 1});
  Future<ReturnListResponse> getReturns();
}
