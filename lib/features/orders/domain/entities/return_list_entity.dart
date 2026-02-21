class ReturnListItemEntity {
  final int id;
  final int orderId;
  final int productId;
  final int userId;
  final String returnReason;
  final String status;
  final String preferredOutcome;
  final DateTime createdAt;

  const ReturnListItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.userId,
    required this.returnReason,
    required this.status,
    required this.preferredOutcome,
    required this.createdAt,
  });

  factory ReturnListItemEntity.fromJson(Map<String, dynamic> json) {
    return ReturnListItemEntity(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      userId: json['user_id'] as int,
      returnReason: json['return_reason'] as String,
      status: json['status'] as String,
      preferredOutcome: json['preferred_outcome'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'user_id': userId,
      'return_reason': returnReason,
      'status': status,
      'preferred_outcome': preferredOutcome,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class ReturnListResponse {
  final List<ReturnListItemEntity> data;

  const ReturnListResponse({required this.data});

  factory ReturnListResponse.fromJson(Map<String, dynamic> json) {
    return ReturnListResponse(
      data:
          (json['data'] as List<dynamic>)
              .map(
                (item) =>
                    ReturnListItemEntity.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}
