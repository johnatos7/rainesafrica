import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const AppLoading({super.key, this.message, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const LoadingWidget({super.key, this.message, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return AppLoading(message: message, size: size, color: color);
  }
}
