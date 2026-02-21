import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_providers.dart';

/// Keys for storing app lock settings
const String _appLockEnabledKey = 'app_lock_enabled';
const String _appLockTimeoutKey = 'app_lock_timeout';
const String _lastAppBackgroundTimeKey = 'last_app_background_time';

/// App lock timeout options
enum AppLockTimeout {
  immediate('Immediate', Duration.zero),
  thirtySeconds('30 seconds', Duration(seconds: 30)),
  oneMinute('1 minute', Duration(minutes: 1)),
  fiveMinutes('5 minutes', Duration(minutes: 5)),
  fifteenMinutes('15 minutes', Duration(minutes: 15)),
  thirtyMinutes('30 minutes', Duration(minutes: 30)),
  oneHour('1 hour', Duration(hours: 1));

  const AppLockTimeout(this.displayName, this.duration);
  final String displayName;
  final Duration duration;
}

/// State for app lock functionality
class AppLockState {
  final bool isEnabled;
  final bool isLocked;
  final AppLockTimeout timeout;
  final bool biometricsAvailable;
  final DateTime? lastBackgroundTime;

  const AppLockState({
    required this.isEnabled,
    required this.isLocked,
    required this.timeout,
    required this.biometricsAvailable,
    this.lastBackgroundTime,
  });

  AppLockState copyWith({
    bool? isEnabled,
    bool? isLocked,
    AppLockTimeout? timeout,
    bool? biometricsAvailable,
    DateTime? lastBackgroundTime,
  }) {
    return AppLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLocked: isLocked ?? this.isLocked,
      timeout: timeout ?? this.timeout,
      biometricsAvailable: biometricsAvailable ?? this.biometricsAvailable,
      lastBackgroundTime: lastBackgroundTime ?? this.lastBackgroundTime,
    );
  }
}

/// Notifier for managing app lock state
class AppLockNotifier extends StateNotifier<AppLockState> {
  AppLockNotifier(this._prefs, this._biometricService)
    : super(
        const AppLockState(
          isEnabled: false,
          isLocked: false,
          timeout: AppLockTimeout.immediate,
          biometricsAvailable: false,
        ),
      );

  final SharedPreferences? _prefs;
  final BiometricService _biometricService;

  /// Initialize the app lock state from storage
  Future<void> initialize() async {
    try {
      final isEnabled = _prefs?.getBool(_appLockEnabledKey) ?? false;
      final timeoutIndex = _prefs?.getInt(_appLockTimeoutKey) ?? 0;
      final timeout = AppLockTimeout.values[timeoutIndex];
      final lastBackgroundTime = _prefs?.getInt(_lastAppBackgroundTimeKey);

      final biometricsAvailable = await _biometricService.isAvailable();

      // Check if app should be locked based on timeout
      bool shouldBeLocked = false;
      if (isEnabled && lastBackgroundTime != null) {
        final backgroundTime = DateTime.fromMillisecondsSinceEpoch(
          lastBackgroundTime,
        );
        final timeSinceBackground = DateTime.now().difference(backgroundTime);
        shouldBeLocked = timeSinceBackground > timeout.duration;
      }

      state = state.copyWith(
        isEnabled: isEnabled,
        timeout: timeout,
        biometricsAvailable: biometricsAvailable,
        lastBackgroundTime:
            lastBackgroundTime != null
                ? DateTime.fromMillisecondsSinceEpoch(lastBackgroundTime)
                : null,
        isLocked: shouldBeLocked,
      );
    } catch (e) {
      debugPrint('Error initializing app lock: $e');
      // Set default state on error
      state = state.copyWith(
        isEnabled: false,
        isLocked: false,
        biometricsAvailable: false,
      );
    }
  }

  /// Enable app lock
  Future<void> enableAppLock() async {
    try {
      if (!state.biometricsAvailable) return;

      await _prefs?.setBool(_appLockEnabledKey, true);
      state = state.copyWith(isEnabled: true);
    } catch (e) {
      debugPrint('Error enabling app lock: $e');
    }
  }

  /// Disable app lock
  Future<void> disableAppLock() async {
    try {
      await _prefs?.setBool(_appLockEnabledKey, false);
      state = state.copyWith(isEnabled: false, isLocked: false);
    } catch (e) {
      debugPrint('Error disabling app lock: $e');
    }
  }

  /// Set app lock timeout
  Future<void> setLockTimeout(AppLockTimeout timeout) async {
    try {
      await _prefs?.setInt(_appLockTimeoutKey, timeout.index);
      state = state.copyWith(timeout: timeout);
    } catch (e) {
      debugPrint('Error setting lock timeout: $e');
    }
  }

  /// Lock the app
  void lockApp() {
    if (state.isEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  /// Unlock the app
  void unlockApp() {
    state = state.copyWith(isLocked: false);
  }

  /// Record when app goes to background
  Future<void> recordAppBackground() async {
    final now = DateTime.now();
    await _prefs?.setInt(_lastAppBackgroundTimeKey, now.millisecondsSinceEpoch);
    state = state.copyWith(lastBackgroundTime: now);
  }

  /// Check if app should be locked and lock if necessary
  Future<void> checkAndLockIfNeeded() async {
    if (!state.isEnabled) return;

    final now = DateTime.now();
    final lastBackground = state.lastBackgroundTime;

    if (lastBackground != null) {
      final timeSinceBackground = now.difference(lastBackground);
      if (timeSinceBackground > state.timeout.duration) {
        lockApp();
      }
    }
  }

  /// Authenticate and unlock the app
  Future<BiometricResult> authenticateAndUnlock({
    required String reason,
  }) async {
    if (!state.biometricsAvailable) {
      return BiometricResult.notAvailable;
    }

    final result = await _biometricService.authenticate(
      localizedReason: reason,
      reason: AuthReason.appAccess,
    );

    if (result == BiometricResult.success) {
      unlockApp();
    }

    return result;
  }
}

/// Provider for app lock notifier
final appLockProvider = StateNotifierProvider<AppLockNotifier, AppLockState>((
  ref,
) {
  try {
    final prefsAsync = ref.watch(sharedPreferencesProvider);
    final biometricService = ref.watch(biometricServiceProvider);

    return prefsAsync.when(
      data: (prefs) => AppLockNotifier(prefs, biometricService),
      loading: () => AppLockNotifier(null, biometricService),
      error: (_, __) => AppLockNotifier(null, biometricService),
    );
  } catch (e) {
    debugPrint('Error creating app lock provider: $e');
    // Return a default notifier with null prefs
    final biometricService = ref.watch(biometricServiceProvider);
    return AppLockNotifier(null, biometricService);
  }
});

/// Provider to check if app is currently locked
final isAppLockedProvider = Provider<bool>((ref) {
  return ref.watch(appLockProvider).isLocked;
});

/// Provider to check if app lock is enabled
final isAppLockEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appLockProvider).isEnabled;
});

/// Provider to get available biometric types for app lock
final appLockBiometricsProvider = FutureProvider<List<BiometricType>>((
  ref,
) async {
  final biometricService = ref.watch(biometricServiceProvider);
  return await biometricService.getAvailableBiometrics();
});
