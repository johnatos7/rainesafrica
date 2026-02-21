import 'package:flutter/material.dart';

/// Color-coded status badge for layby applications
class LaybyStatusBadge extends StatelessWidget {
  final String status;

  const LaybyStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return (Colors.amber.shade700, 'Pending');
      case 'approved':
        return (Colors.blue, 'Approved');
      case 'active':
        return (Colors.green, 'Active');
      case 'completed':
        return (Colors.teal, 'Completed');
      case 'failed':
        return (Colors.red.shade700, 'Failed');
      case 'success':
      case 'paid':
        return (Colors.green.shade700, 'Paid');
      case 'rejected':
        return (Colors.red, 'Rejected');
      case 'cancelled':
        return (Colors.grey, 'Cancelled');
      default:
        return (Colors.grey, status);
    }
  }
}
