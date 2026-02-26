import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/network_info.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/domain/entities/voucher_entity.dart';

abstract class VoucherRemoteDataSource {
  Future<List<VoucherEntity>> getMyVouchers({String? status});
  Future<List<VoucherEntity>> getRedeemedVouchers();
  Future<VoucherActionResult> checkVoucher(String code);
  Future<VoucherActionResult> redeemVoucher(String code);
  Future<String> resendVoucherEmail(int voucherId);
}

class VoucherRemoteDataSourceImpl implements VoucherRemoteDataSource {
  final ApiClient client;
  final NetworkInfo networkInfo;

  VoucherRemoteDataSourceImpl({
    required this.client,
    required this.networkInfo,
  });

  Future<void> _ensureConnected() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException(message: 'No internet connection');
    }
  }

  @override
  Future<List<VoucherEntity>> getMyVouchers({String? status}) async {
    await _ensureConnected();
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }
      final response = await client.get(
        '/api/vouchers/my-vouchers',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final responseMap =
          response is Map<String, dynamic> ? response : <String, dynamic>{};
      final data =
          responseMap['data'] is Map<String, dynamic>
              ? responseMap['data'] as Map<String, dynamic>
              : <String, dynamic>{};
      final vouchers =
          (data['vouchers'] is List ? data['vouchers'] as List : [])
              .where((e) => e is Map<String, dynamic>)
              .map((e) => VoucherEntity.fromJson(e as Map<String, dynamic>))
              .toList();
      return vouchers;
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<List<VoucherEntity>> getRedeemedVouchers() async {
    await _ensureConnected();
    try {
      final response = await client.get('/api/vouchers/redeemed');
      final responseMap =
          response is Map<String, dynamic> ? response : <String, dynamic>{};
      final data =
          responseMap['data'] is Map<String, dynamic>
              ? responseMap['data'] as Map<String, dynamic>
              : <String, dynamic>{};
      final vouchers =
          (data['vouchers'] is List ? data['vouchers'] as List : [])
              .where((e) => e is Map<String, dynamic>)
              .map((e) => VoucherEntity.fromJson(e as Map<String, dynamic>))
              .toList();
      return vouchers;
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<VoucherActionResult> checkVoucher(String code) async {
    await _ensureConnected();
    try {
      final response = await client.post(
        '/api/vouchers/check',
        data: {'code': code},
      );
      if (response is Map<String, dynamic>) {
        return VoucherActionResult.fromJson(response);
      }
      return VoucherActionResult.fromJson({});
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<VoucherActionResult> redeemVoucher(String code) async {
    await _ensureConnected();
    try {
      final response = await client.post(
        '/api/vouchers/redeem',
        data: {'code': code},
      );
      if (response is Map<String, dynamic>) {
        return VoucherActionResult.fromJson(response);
      }
      return VoucherActionResult.fromJson({});
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<String> resendVoucherEmail(int voucherId) async {
    await _ensureConnected();
    try {
      final response = await client.post(
        '/api/vouchers/$voucherId/resend-email',
      );
      if (response is Map<String, dynamic>) {
        return response['message']?.toString() ?? 'Email sent successfully';
      }
      return 'Email sent successfully';
    } catch (e) {
      if (e is ServerException ||
          e is NetworkException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Unexpected error: $e');
    }
  }
}
