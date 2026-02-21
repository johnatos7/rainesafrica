class RefundListItemEntity {
  final int id;
  final int consumerId;
  final int orderId;
  final int productId;
  final double amount;
  final String status;
  final String paymentType;
  final String reason;
  final DateTime createdAt;

  const RefundListItemEntity({
    required this.id,
    required this.consumerId,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.status,
    required this.paymentType,
    required this.reason,
    required this.createdAt,
  });

  factory RefundListItemEntity.fromJson(Map<String, dynamic> json) {
    return RefundListItemEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      consumerId: (json['consumer_id'] as num?)?.toInt() ?? 0,
      orderId: (json['order_id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      amount:
          (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      status: json['status'] as String? ?? '',
      paymentType: json['payment_type'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'order_id': orderId,
      'product_id': productId,
      'amount': amount,
      'status': status,
      'payment_type': paymentType,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class RefundListResponse {
  final List<RefundListItemEntity> data;
  final int currentPage;
  final int lastPage;

  const RefundListResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
  });

  factory RefundListResponse.fromJson(Map<String, dynamic> json) {
    return RefundListResponse(
      data:
          (json['data'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((item) => RefundListItemEntity.fromJson(item))
              .toList() ??
          <RefundListItemEntity>[],
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
      'current_page': currentPage,
      'last_page': lastPage,
    };
  }
}
