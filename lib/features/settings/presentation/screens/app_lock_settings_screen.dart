import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/app_lock_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Screen for configuring app lock settings
class AppLockSettingsScreen extends ConsumerStatefulWidget {
  const AppLockSettingsScreen({super.key});

  @override
  ConsumerState<AppLockSettingsScreen> createState() =>
      _AppLockSettingsScreenState();
}

class _AppLockSettingsScreenState extends ConsumerState<AppLockSettingsScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize app lock state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppLock();
    });
  }

  Future<void> _initializeAppLock() async {
    try {
      await ref.read(appLockProvider.notifier).initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app lock: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLockState = ref.watch(appLockProvider);
    final biometricsAvailable = ref.watch(biometricsAvailableProvider);

    // Show loading state while initializing
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('app_lock_settings'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('app_lock_settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Lock Toggle
          Card(
            child: SwitchListTile(
              title: Text(context.tr('enable_app_lock')),
              subtitle: Text(context.tr('app_lock_description')),
              value: appLockState.isEnabled,
              onChanged: biometricsAvailable.when(
                data:
                    (available) =>
                        available ? (value) => _toggleAppLock() : null,
                loading: () => null,
                error: (_, __) => null,
              ),
              secondary: const Icon(Icons.security),
            ),
          ),

          const SizedBox(height: 16),

          // Lock Timeout Settings (only show if app lock is enabled)
          if (appLockState.isEnabled) ...[
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('lock_timeout'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('lock_timeout_description'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ...AppLockTimeout.values.map((timeout) {
                    return RadioListTile<AppLockTimeout>(
                      title: Text(timeout.displayName),
                      value: timeout,
                      groupValue: appLockState.timeout,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(appLockProvider.notifier)
                              .setLockTimeout(value);
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Biometric Status
          Card(
            child: ListTile(
              leading: const Icon(Icons.fingerprint),
              title: Text(context.tr('biometrics_status')),
              subtitle: biometricsAvailable.when(
                data:
                    (available) => Text(
                      available
                          ? context.tr('biometrics_available')
                          : context.tr('biometrics_not_available'),
                    ),
                loading: () => Text(context.tr('loading')),
                error: (_, __) => Text(context.tr('biometrics_not_available')),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Test Lock Button (only show if app lock is enabled)
          if (appLockState.isEnabled) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _testAppLock(),
                icon: const Icon(Icons.lock),
                label: Text(context.tr('test_app_lock')),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleAppLock() async {
    try {
      final appLockNotifier = ref.read(appLockProvider.notifier);
      final appLockState = ref.read(appLockProvider);

      if (appLockState.isEnabled) {
        // Disable app lock
        await appLockNotifier.disableAppLock();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('app_lock_disabled'))),
          );
        }
      } else {
        // Enable app lock
        await appLockNotifier.enableAppLock();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.tr('app_lock_enabled'))),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling app lock: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _testAppLock() async {
    try {
      final appLockNotifier = ref.read(appLockProvider.notifier);

      // Lock the app
      appLockNotifier.lockApp();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.tr('app_locked_test'))));
      }
    } catch (e) {
      debugPrint('Error testing app lock: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
