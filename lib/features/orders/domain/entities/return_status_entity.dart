class ReturnStatusEntity {
  final int id;
  final int userId;
  final int orderId;
  final int productId;
  final String returnReason;
  final String subReason;
  final String description;
  final bool productNotUsed;
  final bool inOriginalPackaging;
  final bool includeAllAccessories;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String preferredOutcome;
  final String? rejectionReason;

  const ReturnStatusEntity({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.productId,
    required this.returnReason,
    required this.subReason,
    required this.description,
    required this.productNotUsed,
    required this.inOriginalPackaging,
    required this.includeAllAccessories,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.preferredOutcome,
    this.rejectionReason,
  });

  factory ReturnStatusEntity.fromJson(Map<String, dynamic> json) {
    return ReturnStatusEntity(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      returnReason: json['return_reason'] as String,
      subReason: json['sub_reason'] as String,
      description: json['description'] as String,
      productNotUsed: json['product_not_used'] as bool,
      inOriginalPackaging: json['in_original_packaging'] as bool,
      includeAllAccessories: json['include_all_accessories'] as bool,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      preferredOutcome: json['preferred_outcome'] as String,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_id': orderId,
      'product_id': productId,
      'return_reason': returnReason,
      'sub_reason': subReason,
      'description': description,
      'product_not_used': productNotUsed,
      'in_original_packaging': inOriginalPackaging,
      'include_all_accessories': includeAllAccessories,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'preferred_outcome': preferredOutcome,
      'rejection_reason': rejectionReason,
    };
  }
}
