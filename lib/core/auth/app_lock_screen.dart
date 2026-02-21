import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/app_lock_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Screen shown when the app is locked
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  bool _isAuthenticating = false;

  @override
  Widget build(BuildContext context) {
    final biometricsAvailable = ref.watch(biometricsAvailableProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon/Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.security,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                context.tr('app_locked'),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                context.tr('app_locked_description'),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Biometric Authentication Button
              biometricsAvailable.when(
                data: (available) {
                  if (!available) {
                    return Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('biometrics_not_available'),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isAuthenticating ? null : _authenticate,
                      icon:
                          _isAuthenticating
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.fingerprint),
                      label: Text(
                        _isAuthenticating
                            ? context.tr('authenticating')
                            : context.tr('unlock_with_biometrics'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error:
                    (_, __) => Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.tr('biometrics_not_available'),
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              ),

              const SizedBox(height: 24),

              // Help Text
              Text(
                context.tr('app_lock_help'),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final result = await ref
          .read(appLockProvider.notifier)
          .authenticateAndUnlock(reason: context.tr('unlock_app'));

      if (mounted) {
        switch (result) {
          case BiometricResult.success:
            // App will be unlocked automatically
            break;
          case BiometricResult.failed:
            _showError(context.tr('unlock_failed'));
            break;
          case BiometricResult.cancelled:
            // User cancelled, no error needed
            break;
          case BiometricResult.notEnrolled:
            _showError(context.tr('biometrics_not_enrolled'));
            break;
          case BiometricResult.notAvailable:
            _showError(context.tr('biometrics_not_available'));
            break;
          case BiometricResult.lockedOut:
            _showError(context.tr('biometrics_locked_out'));
            break;
          case BiometricResult.error:
            _showError(context.tr('unlock_failed'));
            break;
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
