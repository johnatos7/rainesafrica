import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/providers/order_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/order_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_empty_state.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/widgets/order_loading_shimmer.dart';
import 'package:go_router/go_router.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedStatus;
  String? _selectedPaymentMethod;
  DateTimeRange? _selectedDateRange;
  String _sortBy = 'createdAt';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load orders when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListProvider.notifier).loadOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(orderListProvider.notifier).loadMoreOrders();
    }
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
    _applyFilters();
  }

  void _applyFilters() {
    ref
        .read(orderListProvider.notifier)
        .applyFilters(
          searchQuery: _searchQuery,
          status: _selectedStatus,
          paymentMethod: _selectedPaymentMethod,
          dateRange: _selectedDateRange,
          sortBy: _sortBy,
          sortAscending: _sortAscending,
        );
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedPaymentMethod = null;
      _selectedDateRange = null;
      _sortBy = 'createdAt';
      _sortAscending = false;
      _searchController.clear();
    });
    _applyFilters();
  }

  void _handleSortSelection(String value) {
    setState(() {
      switch (value) {
        case 'createdAt_desc':
          _sortBy = 'createdAt';
          _sortAscending = false;
          break;
        case 'createdAt_asc':
          _sortBy = 'createdAt';
          _sortAscending = true;
          break;
        case 'total_desc':
          _sortBy = 'total';
          _sortAscending = false;
          break;
        case 'total_asc':
          _sortBy = 'total';
          _sortAscending = true;
          break;
        case 'status_asc':
          _sortBy = 'status';
          _sortAscending = true;
          break;
        case 'status_desc':
          _sortBy = 'status';
          _sortAscending = false;
          break;
      }
      _applyFilters();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            builder:
                (context, scrollController) =>
                    _buildFilterBottomSheet(scrollController),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final orderState = ref.watch(orderListProvider);

    return Scaffold(
      backgroundColor: colors.surfaceVariant,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: colors.onSurface),
          onPressed: () => context.pushReplacementNamed('home'),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, size: 22, color: colors.onSurface),
            onSelected: _handleSortSelection,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'createdAt_desc',
                    child: Text('Newest First'),
                  ),
                  const PopupMenuItem(
                    value: 'createdAt_asc',
                    child: Text('Oldest First'),
                  ),
                  const PopupMenuItem(
                    value: 'total_desc',
                    child: Text('Highest Amount'),
                  ),
                  const PopupMenuItem(
                    value: 'total_asc',
                    child: Text('Lowest Amount'),
                  ),
                  const PopupMenuItem(
                    value: 'status_asc',
                    child: Text('Status A-Z'),
                  ),
                  const PopupMenuItem(
                    value: 'status_desc',
                    child: Text('Status Z-A'),
                  ),
                ],
          ),
          IconButton(
            icon: Icon(Icons.filter_list, size: 22, color: colors.onSurface),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: Icon(Icons.refresh, size: 22, color: colors.onSurface),
            onPressed: () {
              ref.read(orderListProvider.notifier).loadOrders(refresh: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(orderListProvider.notifier).loadOrders(refresh: true);
        },
        child: Column(
          children: [
            _buildSearchAndFilters(colors),
            Expanded(child: _buildBody(orderState, colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OrderListState state, ColorScheme colors) {
    if (state.isLoading && state.orders.isEmpty) {
      return const OrderLoadingShimmer();
    }

    if (state.errorMessage != null && state.orders.isEmpty) {
      return _buildErrorState(state.errorMessage!, colors);
    }

    if (state.orders.isEmpty) {
      return const OrderEmptyState();
    }

    // Use filtered orders if filters are applied, otherwise use all orders
    final ordersToShow =
        state.filteredOrders.isNotEmpty ? state.filteredOrders : state.orders;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < ordersToShow.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      order: ordersToShow[index],
                      onTap: () {
                        // Navigate to order details with the order data
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => OrderDetailsScreen(
                                  orderId: ordersToShow[index].orderNumber,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state.hasMore && state.filteredOrders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              childCount:
                  ordersToShow.length +
                  (state.hasMore && state.filteredOrders.isEmpty ? 1 : 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String errorMessage, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(Icons.error_outline, size: 40, color: colors.error),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(orderListProvider.notifier).loadOrders(refresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(ColorScheme colors) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Search orders by ID, status, or amount...',
              prefixIcon: Icon(
                Icons.search,
                color: colors.onSurface.withOpacity(0.5),
              ),
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colors.onSurface.withOpacity(0.5),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchSubmitted('');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.outline.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: TextStyle(color: colors.onSurface.withOpacity(0.5)),
              fillColor: colors.surfaceVariant,
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          // Active Filters
          _buildActiveFilters(colors),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ColorScheme colors) {
    final hasActiveFilters =
        _searchQuery.isNotEmpty ||
        _selectedStatus != null ||
        _selectedPaymentMethod != null ||
        _selectedDateRange != null ||
        _sortBy != 'createdAt' ||
        _sortAscending != false;

    if (!hasActiveFilters) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Active Filters:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearFilters,
              child: Text(
                'Clear All',
                style: TextStyle(fontSize: 12, color: colors.error),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_searchQuery.isNotEmpty)
              _buildFilterChip(
                label: 'Search: "$_searchQuery"',
                onDeleted: () {
                  _searchController.clear();
                  _onSearchSubmitted('');
                },
                colors: colors,
              ),
            if (_selectedStatus != null)
              _buildFilterChip(
                label: 'Status: $_selectedStatus',
                onDeleted: () {
                  setState(() {
                    _selectedStatus = null;
                  });
                  _applyFilters();
                },
                colors: colors,
              ),
            if (_selectedPaymentMethod != null)
              _buildFilterChip(
                label: 'Payment: $_selectedPaymentMethod',
                onDeleted: () {
                  setState(() {
                    _selectedPaymentMethod = null;
                  });
                  _applyFilters();
                },
                colors: colors,
              ),
            if (_selectedDateRange != null)
              _buildFilterChip(
                label: 'Date: ${_formatDateRange(_selectedDateRange!)}',
                onDeleted: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                  _applyFilters();
                },
                colors: colors,
              ),
            if (_sortBy != 'createdAt' || _sortAscending != false)
              _buildFilterChip(
                label: 'Sort: ${_getSortLabel()}',
                onDeleted: () {
                  setState(() {
                    _sortBy = 'createdAt';
                    _sortAscending = false;
                  });
                  _applyFilters();
                },
                colors: colors,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required ColorScheme colors,
  }) {
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 12, color: colors.primary)),
      deleteIcon: Icon(Icons.close, size: 16, color: colors.primary),
      onDeleted: onDeleted,
      backgroundColor: colors.primary.withOpacity(0.1),
      deleteIconColor: colors.primary,
    );
  }

  String _formatDateRange(DateTimeRange range) {
    final start = '${range.start.day}/${range.start.month}/${range.start.year}';
    final end = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$start - $end';
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'createdAt':
        return _sortAscending ? 'Oldest First' : 'Newest First';
      case 'total':
        return _sortAscending ? 'Lowest Amount' : 'Highest Amount';
      case 'status':
        return _sortAscending ? 'Status A-Z' : 'Status Z-A';
      default:
        return 'Newest First';
    }
  }

  Widget _buildFilterBottomSheet(ScrollController scrollController) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Text(
                  'Filter Orders',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    _clearFilters();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: colors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Filters
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _buildStatusFilter(colors),
                  const SizedBox(height: 20),
                  _buildPaymentMethodFilter(colors),
                  const SizedBox(height: 20),
                  _buildDateRangeFilter(colors),
                  const SizedBox(height: 30),
                  _buildApplyButton(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(ColorScheme colors) {
    final statuses = [
      'All',
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled',
      'Returned',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children:
              statuses.map((status) {
                final isSelected =
                    _selectedStatus == status ||
                    (_selectedStatus == null && status == 'All');
                return FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                  selectedColor: colors.primary.withOpacity(0.2),
                  checkmarkColor: colors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? colors.primary : colors.onSurface,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodFilter(ColorScheme colors) {
    final paymentMethods = [
      'All',
      'Payfast',
      'DPO Zambia',
      'PesePay',
      'Office payment',
      'Bank Transfer',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children:
              paymentMethods.map((method) {
                final isSelected =
                    _selectedPaymentMethod == method ||
                    (_selectedPaymentMethod == null && method == 'All');
                return FilterChip(
                  label: Text(method),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMethod = selected ? method : null;
                    });
                  },
                  selectedColor: colors.primary.withOpacity(0.2),
                  checkmarkColor: colors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? colors.primary : colors.onSurface,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDateRange,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
              color: colors.surfaceVariant,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: colors.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDateRange != null
                        ? _formatDateRange(_selectedDateRange!)
                        : 'Select date range',
                    style: TextStyle(
                      color:
                          _selectedDateRange != null
                              ? colors.onSurface
                              : colors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _applyFilters();
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Apply Filters',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
}
