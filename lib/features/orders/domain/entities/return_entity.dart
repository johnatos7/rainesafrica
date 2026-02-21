class ReturnEntity {
  final int id;
  final int orderId;
  final int productId;
  final String returnReason;
  final String subReason;
  final String description;
  final String preferredOutcome;
  final bool productNotUsed;
  final bool inOriginalPackaging;
  final bool includeAllAccessories;
  final int userId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ReturnEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.returnReason,
    required this.subReason,
    required this.description,
    required this.preferredOutcome,
    required this.productNotUsed,
    required this.inOriginalPackaging,
    required this.includeAllAccessories,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReturnEntity.fromJson(Map<String, dynamic> json) {
    return ReturnEntity(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      returnReason: json['return_reason'] as String,
      subReason: json['sub_reason'] as String,
      description: json['description'] as String,
      preferredOutcome: json['preferred_outcome'] as String,
      productNotUsed: json['product_not_used'] as bool,
      inOriginalPackaging: json['in_original_packaging'] as bool,
      includeAllAccessories: json['include_all_accessories'] as bool,
      userId: json['user_id'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'return_reason': returnReason,
      'sub_reason': subReason,
      'description': description,
      'preferred_outcome': preferredOutcome,
      'product_not_used': productNotUsed,
      'in_original_packaging': inOriginalPackaging,
      'include_all_accessories': includeAllAccessories,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ReturnRequestEntity {
  final int orderId;
  final int productId;
  final String returnReason;
  final String subReason;
  final String description;
  final String preferredOutcome;
  final bool productNotUsed;
  final bool inOriginalPackaging;
  final bool includeAllAccessories;

  const ReturnRequestEntity({
    required this.orderId,
    required this.productId,
    required this.returnReason,
    required this.subReason,
    required this.description,
    required this.preferredOutcome,
    required this.productNotUsed,
    required this.inOriginalPackaging,
    required this.includeAllAccessories,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'return_reason': returnReason,
      'sub_reason': subReason,
      'description': description,
      'preferred_outcome': preferredOutcome,
      'product_not_used': productNotUsed,
      'in_original_packaging': inOriginalPackaging,
      'include_all_accessories': includeAllAccessories,
    };
  }
}
