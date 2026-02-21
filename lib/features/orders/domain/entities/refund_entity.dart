class RefundEntity {
  final int id;
  final int consumerId;
  final double amount;
  final String status;

  const RefundEntity({
    required this.id,
    required this.consumerId,
    required this.amount,
    required this.status,
  });

  factory RefundEntity.fromJson(Map<String, dynamic> json) {
    return RefundEntity(
      id: json['id'] as int,
      consumerId: json['consumer_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'amount': amount,
      'status': status,
    };
  }
}

class RefundRequestEntity {
  final int consumerId;
  final int orderId;
  final int productId;
  final double amount;
  final int quantity;
  final String reason;
  final String paymentType;

  const RefundRequestEntity({
    required this.consumerId,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.quantity,
    required this.reason,
    required this.paymentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'consumer_id': consumerId,
      'order_id': orderId,
      'product_id': productId,
      'amount': amount,
      'quantity': quantity,
      'reason': reason,
      'payment_type': paymentType,
    };
  }
}

class RefundErrorEntity {
  final String message;
  final bool success;

  const RefundErrorEntity({required this.message, required this.success});

  factory RefundErrorEntity.fromJson(Map<String, dynamic> json) {
    return RefundErrorEntity(
      message: json['message'] as String,
      success: json['success'] as bool,
    );
  }
}
