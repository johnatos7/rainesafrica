import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/entities/ticket_entity.dart';

/// Abstract repository interface for ticket operations
abstract class TicketRepository {
  /// List user's tickets with optional filters
  ///
  /// [status] - Filter: open, in_progress, resolved, closed
  /// [priority] - Filter: low, medium, high, urgent
  /// [category] - Filter: general, technical, billing, account, order, other
  /// [search] - Search in ticket number, subject, description
  /// [page] - Page number for pagination
  Future<TicketsResponse> getTickets({
    String? status,
    String? priority,
    String? category,
    String? search,
    int page = 1,
  });

  /// Get detailed ticket information including full message history
  Future<TicketEntity> getTicketDetails(int ticketId);

  /// Create a new support ticket
  Future<TicketEntity> createTicket(CreateTicketRequest request);

  /// Add a message/reply to an existing ticket
  Future<TicketMessage> addMessage(int ticketId, String message);

  /// Close a ticket
  Future<void> closeTicket(int ticketId);

  /// Reopen a previously closed ticket
  Future<void> reopenTicket(int ticketId);
}
