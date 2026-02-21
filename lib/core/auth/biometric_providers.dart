import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/debug_biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/auth/local_biometric_service.dart';
import 'package:flutter_riverpod_clean_architecture/core/feature_flags/feature_flag_providers.dart';

/// Provider for the biometric authentication service
final biometricServiceProvider = Provider<BiometricService>((ref) {
  // Check if we're in debug mode or if a feature flag is set
  final useDebugService =
      kDebugMode &&
      ref.watch(
        featureFlagProvider('use_debug_biometrics', defaultValue: false),
      );

  // Create the appropriate service implementation
  final service =
      useDebugService ? DebugBiometricService() : LocalBiometricService();

  // Return the service directly without analytics to avoid circular dependency
  return service;
});

/// Provider to check if biometric authentication is available
final biometricsAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.isAvailable();
});

/// Provider to get available biometric types
final availableBiometricsProvider = FutureProvider<List<BiometricType>>((
  ref,
) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.getAvailableBiometrics();
});

/// Controller for managing authentication state
class BiometricAuthController extends ChangeNotifier {
  final BiometricService _service;

  bool _isAuthenticated = false;
  BiometricResult? _lastResult;
  DateTime? _lastAuthTime;

  BiometricAuthController(this._service);

  /// Whether the user is currently authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// The result of the last authentication attempt
  BiometricResult? get lastResult => _lastResult;

  /// When the user was last authenticated
  DateTime? get lastAuthTime => _lastAuthTime;

  /// Authenticate the user with biometrics
  Future<BiometricResult> authenticate({
    required String reason,
    AuthReason authReason = AuthReason.appAccess,
    bool sensitiveTransaction = false,
    String? dialogTitle,
    String? cancelButtonText,
  }) async {
    _lastResult = await _service.authenticate(
      localizedReason: reason,
      reason: authReason,
      sensitiveTransaction: sensitiveTransaction,
      dialogTitle: dialogTitle,
      cancelButtonText: cancelButtonText,
    );

    if (_lastResult == BiometricResult.success) {
      _isAuthenticated = true;
      _lastAuthTime = DateTime.now();
    }

    notifyListeners();
    return _lastResult!;
  }

  /// Clear the authenticated state
  void logout() {
    _isAuthenticated = false;
    _lastAuthTime = null;

    notifyListeners();
  }

  /// Check if authentication is needed (based on timeout)
  bool isAuthenticationNeeded({Duration? timeout}) {
    if (!_isAuthenticated) return true;

    if (timeout != null && _lastAuthTime != null) {
      final now = DateTime.now();
      final sessionExpiry = _lastAuthTime!.add(timeout);
      if (now.isAfter(sessionExpiry)) {
        _isAuthenticated = false;
        return true;
      }
    }

    return false;
  }
}

/// Provider for the biometric auth controller
final biometricAuthControllerProvider =
    ChangeNotifierProvider<BiometricAuthController>((ref) {
      final service = ref.watch(biometricServiceProvider);
      return BiometricAuthController(service);
    });
