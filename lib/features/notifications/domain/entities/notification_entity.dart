class NotificationEntity {
  final String id;
  final String type;
  final String notifiableType;
  final int notifiableId;
  final NotificationData data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isRead => readAt != null;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: (json['id'] ?? '').toString(),
      type: json['type'] as String? ?? '',
      notifiableType: json['notifiable_type'] as String? ?? '',
      notifiableId: json['notifiable_id'] as int? ?? 0,
      data: NotificationData.fromJson(
        (json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      readAt:
          json['read_at'] != null
              ? DateTime.parse(json['read_at'] as String)
              : null,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'notifiable_type': notifiableType,
      'notifiable_id': notifiableId,
      'data': data.toJson(),
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationEntity copyWith({
    String? id,
    String? type,
    String? notifiableType,
    int? notifiableId,
    NotificationData? data,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      notifiableType: notifiableType ?? this.notifiableType,
      notifiableId: notifiableId ?? this.notifiableId,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationData {
  final String title;
  final String message;
  final String type;

  const NotificationData({
    required this.title,
    required this.message,
    required this.type,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'message': message, 'type': type};
  }
}

class NotificationListResponse {
  final int currentPage;
  final List<NotificationEntity> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<NotificationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  const NotificationListResponse({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      currentPage: json['current_page'] as int? ?? 1,
      data:
          (json['data'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((item) => NotificationEntity.fromJson(item))
              .toList() ??
          <NotificationEntity>[],
      firstPageUrl: json['first_page_url'] as String? ?? '',
      from: json['from'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
      lastPageUrl: json['last_page_url'] as String? ?? '',
      links:
          (json['links'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((item) => NotificationLink.fromJson(item))
              .toList() ??
          <NotificationLink>[],
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String? ?? '',
      perPage: json['per_page'] as int? ?? 10,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class NotificationLink {
  final String? url;
  final String label;
  final bool active;

  const NotificationLink({this.url, required this.label, required this.active});

  factory NotificationLink.fromJson(Map<String, dynamic> json) {
    return NotificationLink(
      url: json['url'] as String?,
      label: json['label'] as String? ?? '',
      active: json['active'] as bool? ?? false,
    );
  }
}
