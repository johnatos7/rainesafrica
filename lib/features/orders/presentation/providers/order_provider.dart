import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/providers/order_use_case_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/usecases/get_orders_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/usecases/get_order_by_id_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/domain/usecases/get_order_statuses_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';

// Order list state
class OrderListState {
  final bool isLoading;
  final List<OrderEntity> orders;
  final List<OrderEntity> filteredOrders;
  final int currentPage;
  final int totalPages;
  final int totalOrders;
  final String? errorMessage;
  final bool hasMore;
  final String searchQuery;
  final String? selectedStatus;
  final String? selectedPaymentMethod;
  final DateTimeRange? selectedDateRange;

  const OrderListState({
    this.isLoading = false,
    this.orders = const [],
    this.filteredOrders = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalOrders = 0,
    this.errorMessage,
    this.hasMore = true,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedPaymentMethod,
    this.selectedDateRange,
  });

  OrderListState copyWith({
    bool? isLoading,
    List<OrderEntity>? orders,
    List<OrderEntity>? filteredOrders,
    int? currentPage,
    int? totalPages,
    int? totalOrders,
    String? errorMessage,
    bool? hasMore,
    String? searchQuery,
    String? selectedStatus,
    String? selectedPaymentMethod,
    DateTimeRange? selectedDateRange,
  }) {
    return OrderListState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalOrders: totalOrders ?? this.totalOrders,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
    );
  }
}

// Order list notifier
class OrderListNotifier extends StateNotifier<OrderListState> {
  final GetOrdersUseCase _getOrdersUseCase;

  OrderListNotifier({required GetOrdersUseCase getOrdersUseCase})
    : _getOrdersUseCase = getOrdersUseCase,
      super(const OrderListState());

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        orders: [],
        currentPage: 1,
      );
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final result = await _getOrdersUseCase(
        GetOrdersParams(page: refresh ? 1 : state.currentPage),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (orderResponse) {
          final newOrders =
              refresh
                  ? orderResponse.data
                  : [...state.orders, ...orderResponse.data];

          state = state.copyWith(
            isLoading: false,
            orders: newOrders,
            filteredOrders: newOrders,
            currentPage: orderResponse.currentPage,
            totalPages: orderResponse.lastPage,
            totalOrders: orderResponse.total,
            hasMore: orderResponse.nextPageUrl != null,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMoreOrders() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getOrdersUseCase(GetOrdersParams(page: nextPage));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (orderResponse) {
          final allOrders = [...state.orders, ...orderResponse.data];

          state = state.copyWith(
            isLoading: false,
            orders: allOrders,
            filteredOrders: allOrders,
            currentPage: orderResponse.currentPage,
            totalPages: orderResponse.lastPage,
            totalOrders: orderResponse.total,
            hasMore: orderResponse.nextPageUrl != null,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void applyFilters({
    required String searchQuery,
    String? status,
    String? paymentMethod,
    DateTimeRange? dateRange,
    String? sortBy,
    bool? sortAscending,
  }) {
    List<OrderEntity> filtered = List.from(state.orders);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((order) {
            return order.id.toString().contains(searchQuery.toLowerCase()) ||
                order.orderStatus.name.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                order.total.toString().contains(searchQuery.toLowerCase()) ||
                order.paymentMethod.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Apply status filter
    if (status != null && status != 'All') {
      filtered =
          filtered.where((order) {
            return order.orderStatus.name.toLowerCase() == status.toLowerCase();
          }).toList();
    }

    // Apply payment method filter
    if (paymentMethod != null && paymentMethod != 'All') {
      filtered =
          filtered.where((order) {
            return order.paymentMethod.toLowerCase() ==
                paymentMethod.toLowerCase();
          }).toList();
    }

    // Apply date range filter
    if (dateRange != null) {
      filtered =
          filtered.where((order) {
            return order.createdAt.isAfter(
                  dateRange.start.subtract(const Duration(days: 1)),
                ) &&
                order.createdAt.isBefore(
                  dateRange.end.add(const Duration(days: 1)),
                );
          }).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      filtered.sort((a, b) {
        int comparison = 0;

        switch (sortBy) {
          case 'createdAt':
            comparison = a.createdAt.compareTo(b.createdAt);
            break;
          case 'total':
            comparison = a.total.compareTo(b.total);
            break;
          case 'status':
            comparison = a.orderStatus.name.compareTo(b.orderStatus.name);
            break;
          default:
            comparison = a.createdAt.compareTo(b.createdAt);
        }

        return (sortAscending ?? false) ? comparison : -comparison;
      });
    }

    state = state.copyWith(
      searchQuery: searchQuery,
      selectedStatus: status,
      selectedPaymentMethod: paymentMethod,
      selectedDateRange: dateRange,
      filteredOrders: filtered,
    );
  }
}

// Order list provider
final orderListProvider =
    StateNotifierProvider<OrderListNotifier, OrderListState>((ref) {
      final getOrdersUseCase = ref.watch(getOrdersUseCaseProvider);
      return OrderListNotifier(getOrdersUseCase: getOrdersUseCase);
    });

// Order details state
class OrderDetailsState {
  final bool isLoading;
  final OrderEntity? order;
  final String? errorMessage;

  const OrderDetailsState({
    this.isLoading = false,
    this.order,
    this.errorMessage,
  });

  OrderDetailsState copyWith({
    bool? isLoading,
    OrderEntity? order,
    String? errorMessage,
  }) {
    return OrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      errorMessage: errorMessage,
    );
  }
}

// Order details notifier
class OrderDetailsNotifier extends StateNotifier<OrderDetailsState> {
  final GetOrderByIdUseCase _getOrderByIdUseCase;

  OrderDetailsNotifier({required GetOrderByIdUseCase getOrderByIdUseCase})
    : _getOrderByIdUseCase = getOrderByIdUseCase,
      super(const OrderDetailsState());

  Future<void> loadOrderDetails(int orderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getOrderByIdUseCase(
        GetOrderByIdParams(orderId: orderId),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (order) {
          state = state.copyWith(
            isLoading: false,
            order: order,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Refresh order details without showing loading state
  // This is used for pull-to-refresh to keep content visible
  Future<void> refreshOrderDetails(int orderId) async {
    // Don't set isLoading to true - keep current content visible
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _getOrderByIdUseCase(
        GetOrderByIdParams(orderId: orderId),
      );

      result.fold(
        (failure) {
          // On error during refresh, keep current data and just clear error
          // The RefreshIndicator will show its own error feedback
        },
        (order) {
          state = state.copyWith(order: order, errorMessage: null);
        },
      );
    } catch (e) {
      // On exception during refresh, keep current data
      // The RefreshIndicator will show its own error feedback
    }
  }

  void setOrder(OrderEntity order) {
    state = state.copyWith(isLoading: false, order: order, errorMessage: null);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Order details provider
final orderDetailsProvider =
    StateNotifierProvider<OrderDetailsNotifier, OrderDetailsState>((ref) {
      final getOrderByIdUseCase = ref.watch(getOrderByIdUseCaseProvider);
      return OrderDetailsNotifier(getOrderByIdUseCase: getOrderByIdUseCase);
    });

// Order statuses state
class OrderStatusesState {
  final bool isLoading;
  final List<OrderStatusEntity> orderStatuses;
  final String? errorMessage;

  const OrderStatusesState({
    this.isLoading = false,
    this.orderStatuses = const [],
    this.errorMessage,
  });

  OrderStatusesState copyWith({
    bool? isLoading,
    List<OrderStatusEntity>? orderStatuses,
    String? errorMessage,
  }) {
    return OrderStatusesState(
      isLoading: isLoading ?? this.isLoading,
      orderStatuses: orderStatuses ?? this.orderStatuses,
      errorMessage: errorMessage,
    );
  }
}

// Order statuses notifier
class OrderStatusesNotifier extends StateNotifier<OrderStatusesState> {
  final GetOrderStatusesUseCase _getOrderStatusesUseCase;

  OrderStatusesNotifier({
    required GetOrderStatusesUseCase getOrderStatusesUseCase,
  }) : _getOrderStatusesUseCase = getOrderStatusesUseCase,
       super(const OrderStatusesState());

  Future<void> loadOrderStatuses() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _getOrderStatusesUseCase(NoParams());

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (orderStatusesResponse) {
          state = state.copyWith(
            isLoading: false,
            orderStatuses: orderStatusesResponse.data,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Order statuses provider
final orderStatusesProvider =
    StateNotifierProvider<OrderStatusesNotifier, OrderStatusesState>((ref) {
      final getOrderStatusesUseCase = ref.watch(
        getOrderStatusesUseCaseProvider,
      );
      return OrderStatusesNotifier(
        getOrderStatusesUseCase: getOrderStatusesUseCase,
      );
    });
