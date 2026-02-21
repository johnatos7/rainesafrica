import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_card.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_empty_state.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_loading_shimmer.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/services/notification_background_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  // Local filters
  _NotificationStatusFilter _statusFilter = _NotificationStatusFilter.all;
  String? _typeFilter; // null = all types

  @override
  void initState() {
    super.initState();
    // Load notifications when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(notificationListProvider.notifier)
          .loadNotifications(refresh: true);
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(notificationListProvider.notifier).loadMoreNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationListProvider);
    final theme = Theme.of(context);

    // Build list of types from current notifications
    final types = {
      for (final n in notificationState.notifications)
        (n.data.type.isNotEmpty ? n.data.type : n.type),
    }..removeWhere((e) => e.trim().isEmpty);

    // Apply filters
    final filtered =
        notificationState.notifications.where((n) {
          final matchesStatus =
              _statusFilter == _NotificationStatusFilter.all
                  ? true
                  : _statusFilter == _NotificationStatusFilter.unread
                  ? !n.isRead
                  : n.isRead;
          final typeValue = n.data.type.isNotEmpty ? n.data.type : n.type;
          final matchesType = _typeFilter == null || _typeFilter == typeValue;
          return matchesStatus && matchesType;
        }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.cardColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pushReplacementNamed('home'),
        ),
        actions: [
          if (notificationState.notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.done_all,
                size: 22,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                _showMarkAllAsReadDialog();
              },
            ),
        ],
      ),
      body: _buildBody(notificationState, filtered, types.toList()..sort()),
    );
  }

  Widget _buildBody(
    NotificationListState state,
    List<NotificationEntity> filtered,
    List<String> availableTypes,
  ) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const NotificationLoadingShimmer();
    }

    if (state.errorMessage != null && state.notifications.isEmpty) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.notifications.isEmpty) {
      return const NotificationEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref
            .read(notificationListProvider.notifier)
            .loadNotifications(refresh: true);
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          _buildFilters(availableTypes),
          const SizedBox(height: 8),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  'No notifications match your filters',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ...List.generate(filtered.length, (index) {
              final notification = filtered[index];
              return NotificationCard(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    ref
                        .read(notificationBackgroundServiceProvider)
                        .markNotificationAsRead(notification.id);
                    ref
                        .read(notificationListProvider.notifier)
                        .markNotificationAsRead(notification.id);
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => NotificationDetailsScreen(
                            notificationId: notification.id,
                            notification: notification,
                          ),
                    ),
                  );
                },
                onMarkAsRead: () {
                  ref
                      .read(notificationListProvider.notifier)
                      .markNotificationAsRead(notification.id);
                },
              );
            }),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<String> availableTypes) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _statusFilter == _NotificationStatusFilter.all,
              onSelected:
                  (_) => setState(() {
                    _statusFilter = _NotificationStatusFilter.all;
                  }),
            ),
            ChoiceChip(
              label: const Text('Unread'),
              selected: _statusFilter == _NotificationStatusFilter.unread,
              onSelected:
                  (_) => setState(() {
                    _statusFilter = _NotificationStatusFilter.unread;
                  }),
            ),
            ChoiceChip(
              label: const Text('Read'),
              selected: _statusFilter == _NotificationStatusFilter.read,
              onSelected:
                  (_) => setState(() {
                    _statusFilter = _NotificationStatusFilter.read;
                  }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Type',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String?>(
              value: _typeFilter,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All types'),
                ),
                ...availableTypes.map(
                  (t) => DropdownMenuItem<String?>(value: t, child: Text(t)),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _typeFilter = val;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(notificationListProvider.notifier)
                  .loadNotifications(refresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showMarkAllAsReadDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mark All as Read'),
            content: const Text(
              'Are you sure you want to mark all notifications as read?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Mark all as read in background
                  ref
                      .read(notificationBackgroundServiceProvider)
                      .markAllNotificationsAsRead();
                  ref
                      .read(notificationListProvider.notifier)
                      .markAllNotificationsAsRead();
                },
                child: const Text('Mark All'),
              ),
            ],
          ),
    );
  }
}

enum _NotificationStatusFilter { all, unread, read }
