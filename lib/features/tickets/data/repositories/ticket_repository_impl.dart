import 'package:flutter_riverpod_clean_architecture/features/tickets/data/datasources/ticket_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/entities/ticket_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/repositories/ticket_repository.dart';

/// Repository implementation that delegates to the remote data source
class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource _remoteDataSource;

  TicketRepositoryImpl(this._remoteDataSource);

  @override
  Future<TicketsResponse> getTickets({
    String? status,
    String? priority,
    String? category,
    String? search,
    int page = 1,
  }) {
    return _remoteDataSource.getTickets(
      status: status,
      priority: priority,
      category: category,
      search: search,
      page: page,
    );
  }

  @override
  Future<TicketEntity> getTicketDetails(int ticketId) {
    return _remoteDataSource.getTicketDetails(ticketId);
  }

  @override
  Future<TicketEntity> createTicket(CreateTicketRequest request) {
    return _remoteDataSource.createTicket(request);
  }

  @override
  Future<TicketMessage> addMessage(int ticketId, String message) {
    return _remoteDataSource.addMessage(ticketId, message);
  }

  @override
  Future<void> closeTicket(int ticketId) {
    return _remoteDataSource.closeTicket(ticketId);
  }

  @override
  Future<void> reopenTicket(int ticketId) {
    return _remoteDataSource.reopenTicket(ticketId);
  }
}
