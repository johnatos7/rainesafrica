import 'package:equatable/equatable.dart';

/// Ticket user (simplified from full user entity)
class TicketUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? roleName;

  const TicketUser({
    required this.id,
    required this.name,
    required this.email,
    this.roleName,
  });

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleName: json['role'] is Map ? json['role']['name'] as String? : null,
    );
  }

  @override
  List<Object?> get props => [id, name, email, roleName];
}

/// A single message within a ticket conversation
class TicketMessage extends Equatable {
  final int id;
  final int ticketId;
  final int userId;
  final String message;
  final bool isInternal;
  final dynamic attachments;
  final String createdAt;
  final String updatedAt;
  final TicketUser? user;

  const TicketMessage({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.isInternal,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      userId: json['user_id'] as int,
      message: json['message'] as String? ?? '',
      isInternal: json['is_internal'] as bool? ?? false,
      attachments: json['attachments'],
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      user:
          json['user'] != null
              ? TicketUser.fromJson(json['user'] as Map<String, dynamic>)
              : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ticketId,
    userId,
    message,
    isInternal,
    createdAt,
  ];
}

/// Main ticket entity
class TicketEntity extends Equatable {
  final int id;
  final String ticketNumber;
  final int userId;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final String category;
  final int? assignedTo;
  final String? resolvedAt;
  final String? closedAt;
  final String createdAt;
  final String updatedAt;
  final int unreadCount;
  final TicketUser? user;
  final TicketMessage? latestMessage;
  final List<TicketMessage> messages;

  const TicketEntity({
    required this.id,
    required this.ticketNumber,
    required this.userId,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.category,
    this.assignedTo,
    this.resolvedAt,
    this.closedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    this.user,
    this.latestMessage,
    this.messages = const [],
  });

  factory TicketEntity.fromJson(Map<String, dynamic> json) {
    return TicketEntity(
      id: json['id'] as int,
      ticketNumber: json['ticket_number'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
      category: json['category'] as String? ?? 'general',
      assignedTo: json['assigned_to'] as int?,
      resolvedAt: json['resolved_at'] as String?,
      closedAt: json['closed_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      unreadCount: json['unread_count'] as int? ?? 0,
      user:
          json['user'] != null
              ? TicketUser.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      latestMessage:
          json['latest_message'] != null
              ? TicketMessage.fromJson(
                json['latest_message'] as Map<String, dynamic>,
              )
              : null,
      messages:
          json['messages'] != null
              ? (json['messages'] as List)
                  .map((m) => TicketMessage.fromJson(m as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }

  @override
  List<Object?> get props => [id, ticketNumber, status, priority, updatedAt];
}

/// Paginated response for ticket listing
class TicketsResponse {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<TicketEntity> data;

  const TicketsResponse({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.data,
  });

  factory TicketsResponse.fromJson(Map<String, dynamic> json) {
    final ticketsData = json['tickets'] as Map<String, dynamic>? ?? json;
    return TicketsResponse(
      currentPage: ticketsData['current_page'] as int? ?? 1,
      lastPage: ticketsData['last_page'] as int? ?? 1,
      total: ticketsData['total'] as int? ?? 0,
      data:
          ticketsData['data'] != null
              ? (ticketsData['data'] as List)
                  .map((t) => TicketEntity.fromJson(t as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }
}

/// Request model for creating a new ticket
class CreateTicketRequest {
  final String subject;
  final String description;
  final String priority;
  final String category;

  const CreateTicketRequest({
    required this.subject,
    required this.description,
    required this.priority,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'description': description,
    'priority': priority,
    'category': category,
  };
}
