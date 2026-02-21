import 'package:flutter/material.dart';

class PushMessageScreen extends StatelessWidget {
  final String? title;
  final String? message;

  const PushMessageScreen({super.key, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title?.isNotEmpty == true ? title! : 'Notification',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null && title!.isNotEmpty)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              message?.isNotEmpty == true ? message! : 'No message provided',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
