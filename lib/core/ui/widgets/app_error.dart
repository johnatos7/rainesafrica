import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? color;

  const AppError({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: color ?? Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: color ?? Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? color;

  const ErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppError(
      message: message,
      onRetry: onRetry,
      icon: icon,
      color: color,
    );
  }
}
