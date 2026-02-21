import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/providers/notification_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_details_header.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_details_content.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/widgets/notification_details_loading.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/data/services/notification_background_service.dart';

class NotificationDetailsScreen extends ConsumerStatefulWidget {
  final String notificationId;
  final NotificationEntity?
  notification; // Optional notification data from list

  const NotificationDetailsScreen({
    super.key,
    required this.notificationId,
    this.notification,
  });

  @override
  ConsumerState<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState
    extends ConsumerState<NotificationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notification details when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.notification != null) {
        // Use the passed notification data directly
        ref
            .read(notificationDetailsProvider.notifier)
            .setNotification(widget.notification!);
        // Mark as read if not already read
        if (!widget.notification!.isRead) {
          _markAsReadInBackground();
        }
      } else {
        // Load from API
        ref
            .read(notificationDetailsProvider.notifier)
            .loadNotificationDetails(widget.notificationId);
      }
    });
  }

  void _markAsReadInBackground() {
    // Mark as read in the background without waiting for the result
    ref
        .read(notificationBackgroundServiceProvider)
        .markNotificationAsRead(widget.notificationId);

    // Also update the local state immediately for better UX
    ref
        .read(notificationDetailsProvider.notifier)
        .markAsRead(widget.notificationId);
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationDetailsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notification Details',
          style: TextStyle(
            fontSize: 18,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      body: _buildBody(notificationState),
    );
  }

  Widget _buildBody(NotificationDetailsState state) {
    if (state.isLoading) {
      return const NotificationDetailsLoading();
    }

    if (state.errorMessage != null) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.notification == null) {
      return const Center(child: Text('Notification not found'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          NotificationDetailsHeader(notification: state.notification!),
          const SizedBox(height: 16),
          NotificationDetailsContent(notification: state.notification!),
        ],
      ),
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
            'Failed to load notification',
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
                  .read(notificationDetailsProvider.notifier)
                  .loadNotificationDetails(widget.notificationId);
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
}
