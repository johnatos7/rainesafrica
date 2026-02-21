import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/entities/ticket_entity.dart';

/// Abstract interface for ticket remote data operations
abstract class TicketRemoteDataSource {
  Future<TicketsResponse> getTickets({
    String? status,
    String? priority,
    String? category,
    String? search,
    int page = 1,
  });
  Future<TicketEntity> getTicketDetails(int ticketId);
  Future<TicketEntity> createTicket(CreateTicketRequest request);
  Future<TicketMessage> addMessage(int ticketId, String message);
  Future<void> closeTicket(int ticketId);
  Future<void> reopenTicket(int ticketId);
}

/// Implementation using ApiClient
class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  final ApiClient _apiClient;

  TicketRemoteDataSourceImpl(this._apiClient);

  @override
  Future<TicketsResponse> getTickets({
    String? status,
    String? priority,
    String? category,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (priority != null && priority.isNotEmpty)
      queryParams['priority'] = priority;
    if (category != null && category.isNotEmpty)
      queryParams['category'] = category;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final data = await _apiClient.get(
      '/api/tickets',
      queryParameters: queryParams,
    );
    return TicketsResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<TicketEntity> getTicketDetails(int ticketId) async {
    final data = await _apiClient.get('/api/tickets/$ticketId');
    return TicketEntity.fromJson(
      (data as Map<String, dynamic>)['ticket'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TicketEntity> createTicket(CreateTicketRequest request) async {
    final data = await _apiClient.post('/api/tickets', data: request.toJson());
    return TicketEntity.fromJson(
      (data as Map<String, dynamic>)['ticket'] as Map<String, dynamic>,
    );
  }

  @override
  Future<TicketMessage> addMessage(int ticketId, String message) async {
    final data = await _apiClient.post(
      '/api/tickets/$ticketId/messages',
      data: {'message': message},
    );
    return TicketMessage.fromJson(
      (data as Map<String, dynamic>)['ticket_message'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> closeTicket(int ticketId) async {
    await _apiClient.post('/api/tickets/$ticketId/close');
  }

  @override
  Future<void> reopenTicket(int ticketId) async {
    await _apiClient.post('/api/tickets/$ticketId/reopen');
  }
}
