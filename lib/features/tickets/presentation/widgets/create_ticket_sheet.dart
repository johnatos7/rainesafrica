import 'package:flutter/material.dart';

/// Bottom sheet form for creating a new support ticket
class CreateTicketSheet extends StatefulWidget {
  final Future<void> Function({
    required String subject,
    required String category,
    required String priority,
    required String description,
  })
  onSubmit;

  const CreateTicketSheet({super.key, required this.onSubmit});

  @override
  State<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<CreateTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'general';
  String _priority = 'medium';
  bool _isSubmitting = false;

  static const _categories = [
    {'key': 'general', 'label': 'General Inquiry'},
    {'key': 'technical', 'label': 'Technical Issue'},
    {'key': 'billing', 'label': 'Billing & Payment'},
    {'key': 'account', 'label': 'Account Management'},
    {'key': 'order', 'label': 'Order Related'},
    {'key': 'other', 'label': 'Other'},
  ];

  static const _priorities = [
    {'key': 'low', 'label': 'Low'},
    {'key': 'medium', 'label': 'Medium'},
    {'key': 'high', 'label': 'High'},
    {'key': 'urgent', 'label': 'Urgent'},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create Support Ticket',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Subject
                Text(
                  'Subject *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    hintText: 'Brief description of your issue',
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Subject is required'
                              : null,
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  'Category *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items:
                      _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c['key'],
                              child: Text(c['label']!),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
                const SizedBox(height: 16),

                // Priority
                Text(
                  'Priority *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: InputDecoration(
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items:
                      _priorities
                          .map(
                            (p) => DropdownMenuItem(
                              value: p['key'],
                              child: Text(p['label']!),
                            ),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _priority = v);
                  },
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Please provide detailed information about your issue...',
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator:
                      (v) =>
                          v == null || v.trim().isEmpty
                              ? 'Description is required'
                              : null,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: colors.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Create Ticket',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        subject: _subjectController.text.trim(),
        category: _category,
        priority: _priority,
        description: _descriptionController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
