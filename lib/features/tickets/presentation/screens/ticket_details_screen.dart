import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/domain/entities/ticket_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/providers/ticket_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/widgets/ticket_status_badge.dart';

/// Ticket detail screen with conversation thread and reply box
class TicketDetailsScreen extends ConsumerStatefulWidget {
  final int ticketId;

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailsScreen> createState() =>
      _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends ConsumerState<TicketDetailsScreen> {
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final detailsAsync = ref.watch(ticketDetailsProvider(widget.ticketId));
    final notifierState = ref.watch(ticketNotifierProvider);

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text(
          'Ticket Details',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed:
                () => ref.invalidate(ticketDetailsProvider(widget.ticketId)),
            icon: const Icon(Icons.refresh, size: 22),
            tooltip: 'Refresh',
          ),
          detailsAsync.whenOrNull(
                data: (ticket) {
                  final isClosed = ticket.status.toLowerCase() == 'closed';
                  return IconButton(
                    onPressed:
                        notifierState.isLoading
                            ? null
                            : () => _toggleTicketStatus(ticket),
                    icon: Icon(
                      isClosed ? Icons.lock_open : Icons.close,
                      size: 22,
                    ),
                    tooltip: isClosed ? 'Reopen Ticket' : 'Close Ticket',
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: detailsAsync.when(
        data: (ticket) => _buildBody(context, ticket, colors, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load ticket',
                    style: TextStyle(color: colors.onSurface),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed:
                        () => ref.invalidate(
                          ticketDetailsProvider(widget.ticketId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TicketEntity ticket,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final isClosed = ticket.status.toLowerCase() == 'closed';

    return Column(
      children: [
        // Header section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            border: Border(
              bottom: BorderSide(color: colors.outline.withOpacity(0.1)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject
              Text(
                ticket.subject,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Ticket # + badges
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Ticket #: ${ticket.ticketNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withOpacity(0.6),
                      fontFamily: 'monospace',
                    ),
                  ),
                  TicketStatusBadge(label: ticket.status),
                  TicketStatusBadge(label: ticket.priority, isPriority: true),
                  TicketStatusBadge(label: _categoryLabel(ticket.category)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Created: ${_formatDate(ticket.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),

        // Messages / Conversation
        Expanded(
          child:
              ticket.messages.isEmpty
                  ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: colors.onSurface.withOpacity(0.4),
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ticket.messages.length,
                    itemBuilder:
                        (context, i) => _buildMessage(
                          ticket.messages[i],
                          colors,
                          theme,
                          ticket,
                        ),
                  ),
        ),

        // Reply section (only if not closed)
        if (!isClosed) _buildReplyBox(colors, theme),
      ],
    );
  }

  Widget _buildMessage(
    TicketMessage msg,
    ColorScheme colors,
    ThemeData theme,
    TicketEntity ticket,
  ) {
    final isCurrentUser = msg.userId == ticket.userId;
    final senderName = msg.user?.name ?? 'Support';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            isCurrentUser
                ? colors.surfaceContainerLow
                : colors.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrentUser
                  ? colors.outline.withOpacity(0.1)
                  : colors.primary.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        isCurrentUser
                            ? colors.primary.withOpacity(0.15)
                            : colors.tertiary.withOpacity(0.15),
                    child: Icon(
                      isCurrentUser ? Icons.person : Icons.support_agent,
                      size: 16,
                      color: isCurrentUser ? colors.primary : colors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    senderName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDate(msg.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg.message,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurface.withOpacity(0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBox(ColorScheme colors, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(top: BorderSide(color: colors.outline.withOpacity(0.1))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Reply',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: colors.outline.withOpacity(0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isSending ? null : _sendMessage,
              icon:
                  _isSending
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send, size: 18),
              label: const Text(
                'Send Message',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final msg = await ref
          .read(ticketNotifierProvider.notifier)
          .addMessage(widget.ticketId, text);
      if (msg != null && mounted) {
        _messageController.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Message sent!')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _toggleTicketStatus(TicketEntity ticket) async {
    final isClosed = ticket.status.toLowerCase() == 'closed';
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(isClosed ? 'Reopen Ticket?' : 'Close Ticket?'),
            content: Text(
              isClosed
                  ? 'This will reopen the ticket for further conversation.'
                  : 'Are you sure you want to close this ticket?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(isClosed ? 'Reopen' : 'Close'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success =
          isClosed
              ? await ref
                  .read(ticketNotifierProvider.notifier)
                  .reopenTicket(widget.ticketId)
              : await ref
                  .read(ticketNotifierProvider.notifier)
                  .closeTicket(widget.ticketId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isClosed
                  ? 'Ticket reopened successfully'
                  : 'Ticket closed successfully',
            ),
          ),
        );
      }
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
}
