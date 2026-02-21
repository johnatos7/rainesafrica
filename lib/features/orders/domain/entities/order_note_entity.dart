class OrderNoteEntity {
  final int id;
  final int orderId;
  final String note;
  final String privacy;
  final int createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const OrderNoteEntity({
    required this.id,
    required this.orderId,
    required this.note,
    required this.privacy,
    required this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory OrderNoteEntity.fromJson(Map<String, dynamic> json) {
    return OrderNoteEntity(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      note: json['note'] as String? ?? '',
      privacy: json['privacy'] as String? ?? 'public',
      createdById: json['created_by_id'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.tryParse(json['deleted_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'note': note,
      'privacy': privacy,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
