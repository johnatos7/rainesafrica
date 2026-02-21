import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/entities/ticket_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/providers/ticket_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/widgets/ticket_status_badge.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/widgets/create_ticket_sheet.dart';

/// "My Support Tickets" list screen with status filter tabs
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // null = All, 'open', 'closed'
  static const _tabs = [
    {'label': 'All', 'status': null},
    {'label': 'Open', 'status': 'open'},
    {'label': 'Closed', 'status': 'closed'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _currentStatus {
    final status = _tabs[_tabController.index]['status'];
    return status is String ? status : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final ticketsAsync = ref.watch(ticketsListProvider(_currentStatus));

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(
          'My Support Tickets',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showCreateTicket(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'New Ticket',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurface.withOpacity(0.5),
          indicatorColor: colors.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t['label'] as String)).toList(),
        ),
      ),
      body: ticketsAsync.when(
        data: (response) {
          if (response.data.isEmpty) {
            return _buildEmptyState(colors, theme);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(ticketsListProvider(_currentStatus));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: response.data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder:
                  (context, i) => _buildTicketCard(
                    context,
                    response.data[i],
                    colors,
                    theme,
                  ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load tickets',
                    style: TextStyle(color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        () =>
                            ref.invalidate(ticketsListProvider(_currentStatus)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent_outlined,
            size: 64,
            color: colors.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No tickets found.\nCreate your first support ticket!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colors.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showCreateTicket(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create New Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    TicketEntity ticket,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () => context.push('/tickets/${ticket.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: ticket number + badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    ticket.ticketNumber,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                TicketStatusBadge(label: ticket.priority, isPriority: true),
                const SizedBox(width: 6),
                TicketStatusBadge(label: ticket.status),
              ],
            ),
            const SizedBox(height: 8),

            // Subject
            Text(
              ticket.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),

            // Bottom row: category + date + view action
            Row(
              children: [
                Icon(
                  _categoryIcon(ticket.category),
                  size: 14,
                  color: colors.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  _categoryLabel(ticket.category),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: colors.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(ticket.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
                const Spacer(),
                if (ticket.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${ticket.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colors.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return Icons.build_outlined;
      case 'billing':
        return Icons.payment;
      case 'account':
        return Icons.person_outline;
      case 'order':
        return Icons.local_shipping_outlined;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  String _categoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return 'General';
      case 'technical':
        return 'Technical';
      case 'billing':
        return 'Billing';
      case 'account':
        return 'Account';
      case 'order':
        return 'Order';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final amPm = date.hour >= 12 ? 'PM' : 'AM';
      return '${months[date.month - 1]} ${date.day}, ${date.year}, ${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return dateStr;
    }
  }

  void _showCreateTicket(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => CreateTicketSheet(
            onSubmit: ({
              required String subject,
              required String category,
              required String priority,
              required String description,
            }) async {
              final ticket = await ref
                  .read(ticketNotifierProvider.notifier)
                  .createTicket(
                    CreateTicketRequest(
                      subject: subject,
                      description: description,
                      priority: priority,
                      category: category,
                    ),
                  );
              if (ticket != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticket created successfully!')),
                );
              }
            },
          ),
    );
  }
}
