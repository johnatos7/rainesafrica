import 'package:equatable/equatable.dart';

class VoucherEntity extends Equatable {
  final int id;
  final String code;
  final double amount;
  final String currencyCode;
  final String status; // active, redeemed, expired
  final DateTime? redeemedAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final VoucherProductEntity? product;

  const VoucherEntity({
    required this.id,
    required this.code,
    required this.amount,
    required this.currencyCode,
    required this.status,
    this.redeemedAt,
    this.expiresAt,
    this.createdAt,
    this.product,
  });

  factory VoucherEntity.fromJson(Map<String, dynamic> json) {
    return VoucherEntity(
      id: _safeParseInt(json['id']),
      code: json['code'] as String? ?? '',
      amount: _safeParseDouble(json['amount']),
      currencyCode: json['currency_code'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'active',
      redeemedAt:
          json['redeemed_at'] != null
              ? DateTime.tryParse(json['redeemed_at'].toString())
              : null,
      expiresAt:
          json['expires_at'] != null
              ? DateTime.tryParse(json['expires_at'].toString())
              : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
      product:
          json['product'] is Map<String, dynamic>
              ? VoucherProductEntity.fromJson(
                json['product'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isRedeemed => status == 'redeemed';
  bool get isExpired =>
      status == 'expired' ||
      (expiresAt != null && expiresAt!.isBefore(DateTime.now()));

  static double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    code,
    amount,
    currencyCode,
    status,
    redeemedAt,
    expiresAt,
    createdAt,
    product,
  ];
}

class VoucherProductEntity extends Equatable {
  final int id;
  final String name;
  final double price;
  final bool isGiftCard;

  const VoucherProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.isGiftCard,
  });

  factory VoucherProductEntity.fromJson(Map<String, dynamic> json) {
    return VoucherProductEntity(
      id: VoucherEntity._safeParseInt(json['id']),
      name: json['name'] as String? ?? '',
      price: VoucherEntity._safeParseDouble(json['price']),
      isGiftCard: json['is_gift_card'] == true || json['is_gift_card'] == 1,
    );
  }

  @override
  List<Object?> get props => [id, name, price, isGiftCard];
}

/// Response wrapper for check/redeem operations.
class VoucherActionResult {
  final bool success;
  final String message;
  final VoucherEntity? voucher;
  final double? walletBalance;

  const VoucherActionResult({
    required this.success,
    required this.message,
    this.voucher,
    this.walletBalance,
  });

  factory VoucherActionResult.fromJson(Map<String, dynamic> json) {
    final data =
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : null;
    return VoucherActionResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      voucher:
          data != null && data['voucher'] is Map<String, dynamic>
              ? VoucherEntity.fromJson(data['voucher'] as Map<String, dynamic>)
              : null,
      walletBalance:
          data?['wallet_balance'] != null
              ? VoucherEntity._safeParseDouble(data!['wallet_balance'])
              : null,
    );
  }
}
