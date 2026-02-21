import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/app_lock_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/app_lock_screen.dart';

/// Wrapper widget that shows app lock screen when app is locked
class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize app lock state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLockProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App is going to background, record the time
        ref.read(appLockProvider.notifier).recordAppBackground();
        break;
      case AppLifecycleState.resumed:
        // App is coming back to foreground, check if it should be locked
        ref.read(appLockProvider.notifier).checkAndLockIfNeeded();
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.hidden:
        // App is hidden (iOS specific)
        ref.read(appLockProvider.notifier).recordAppBackground();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLockState = ref.watch(appLockProvider);

    // If app is locked, show the lock screen
    if (appLockState.isLocked) {
      return const AppLockScreen();
    }

    // Otherwise, show the normal app content
    return widget.child;
  }
}
