import 'package:flutter/material.dart';

/// Reusable color-coded badge for ticket status and priority
class TicketStatusBadge extends StatelessWidget {
  final String label;
  final bool isPriority;

  const TicketStatusBadge({
    super.key,
    required this.label,
    this.isPriority = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colors.$2,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  (Color bg, Color fg) _getColors() {
    if (isPriority) {
      return _priorityColors();
    }
    return _statusColors();
  }

  (Color bg, Color fg) _statusColors() {
    switch (label.toLowerCase()) {
      case 'open':
        return (const Color(0xFF4CAF50), Colors.white);
      case 'in_progress':
      case 'in progress':
        return (const Color(0xFF2196F3), Colors.white);
      case 'resolved':
        return (const Color(0xFF009688), Colors.white);
      case 'closed':
        return (const Color(0xFF9E9E9E), Colors.white);
      default:
        return (const Color(0xFF9E9E9E), Colors.white);
    }
  }

  (Color bg, Color fg) _priorityColors() {
    switch (label.toLowerCase()) {
      case 'low':
        return (const Color(0xFF9E9E9E), Colors.white);
      case 'medium':
        return (const Color(0xFFFFC107), Colors.white);
      case 'high':
        return (const Color(0xFFFF9800), Colors.white);
      case 'urgent':
        return (const Color(0xFFF44336), Colors.white);
      default:
        return (const Color(0xFF9E9E9E), Colors.white);
    }
  }
}
