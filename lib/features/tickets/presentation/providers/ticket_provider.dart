import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/network_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/data/datasources/ticket_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/data/repositories/ticket_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/entities/ticket_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/repositories/ticket_repository.dart';

// --- Infrastructure providers ---

final ticketDataSourceProvider = Provider<TicketRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TicketRemoteDataSourceImpl(apiClient);
});

final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final dataSource = ref.watch(ticketDataSourceProvider);
  return TicketRepositoryImpl(dataSource);
});

// --- Data providers ---

/// Paginated ticket list, keyed by status filter (null = all)
final ticketsListProvider = FutureProvider.family<TicketsResponse, String?>((
  ref,
  status,
) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTickets(status: status);
});

/// Full ticket details with message history
final ticketDetailsProvider = FutureProvider.family<TicketEntity, int>((
  ref,
  ticketId,
) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.getTicketDetails(ticketId);
});

// --- State management ---

class TicketNotifierState {
  final bool isLoading;
  final String? error;
  final TicketEntity? lastCreatedTicket;

  const TicketNotifierState({
    this.isLoading = false,
    this.error,
    this.lastCreatedTicket,
  });

  TicketNotifierState copyWith({
    bool? isLoading,
    String? error,
    TicketEntity? lastCreatedTicket,
  }) {
    return TicketNotifierState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCreatedTicket: lastCreatedTicket ?? this.lastCreatedTicket,
    );
  }
}

class TicketNotifier extends StateNotifier<TicketNotifierState> {
  final TicketRepository _repository;
  final Ref _ref;

  TicketNotifier(this._repository, this._ref)
    : super(const TicketNotifierState());

  /// Create a new support ticket
  Future<TicketEntity?> createTicket(CreateTicketRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ticket = await _repository.createTicket(request);
      state = state.copyWith(isLoading: false, lastCreatedTicket: ticket);
      // Invalidate list to refresh
      _ref.invalidate(ticketsListProvider);
      return ticket;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Add a message to a ticket
  Future<TicketMessage?> addMessage(int ticketId, String message) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final msg = await _repository.addMessage(ticketId, message);
      state = state.copyWith(isLoading: false);
      // Refresh ticket details
      _ref.invalidate(ticketDetailsProvider(ticketId));
      return msg;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Close a ticket
  Future<bool> closeTicket(int ticketId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.closeTicket(ticketId);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(ticketDetailsProvider(ticketId));
      _ref.invalidate(ticketsListProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reopen a ticket
  Future<bool> reopenTicket(int ticketId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.reopenTicket(ticketId);
      state = state.copyWith(isLoading: false);
      _ref.invalidate(ticketDetailsProvider(ticketId));
      _ref.invalidate(ticketsListProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final ticketNotifierProvider =
    StateNotifierProvider<TicketNotifier, TicketNotifierState>((ref) {
      final repo = ref.watch(ticketRepositoryProvider);
      return TicketNotifier(repo, ref);
    });
