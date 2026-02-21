import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';

class AuthInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const AuthInitializer({super.key, required this.child});

  @override
  ConsumerState<AuthInitializer> createState() => _AuthInitializerState();
}

class _AuthInitializerState extends ConsumerState<AuthInitializer> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Check auth status when app starts, but only once
    if (!_hasInitialized) {
      _hasInitialized = true;
      Future.microtask(() {
        // Only check auth status if we're not already authenticated
        final currentAuthState = ref.read(authProvider);
        if (!currentAuthState.isAuthenticated && !currentAuthState.isLoading) {
          print('🔵 AUTH INITIALIZER: Checking auth status on app startup');
          ref.read(authProvider.notifier).reloadUser();
        } else {
          print(
            '🔵 AUTH INITIALIZER: Skipping auth check - already authenticated or loading',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
