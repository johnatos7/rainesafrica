import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_event.dart';
import 'package:flutter_riverpod_clean_architecture/core/analytics/analytics_service.dart';

/// Implementation of AnalyticsService using Firebase Analytics
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isEnabled = true;

  @override
  Future<void> init() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    debugPrint('📊 Firebase Analytics initialized');
    _isEnabled = true;
  }

  @override
  void logEvent(AnalyticsEvent event) {
    if (!_isEnabled) return;

    final eventName = event.name.replaceAll(' ', '_');

    // Sanitize parameters: Firebase only accepts String, int, double, bool
    final sanitized = <String, Object>{};
    for (final entry in event.parameters.entries) {
      final value = entry.value;
      if (value is String || value is int || value is double || value is bool) {
        sanitized[entry.key] = value;
      } else if (value != null) {
        sanitized[entry.key] = value.toString();
      }
    }

    if (event is ScreenViewEvent) {
      _analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': event.screenName, ...sanitized},
      );
    } else {
      _analytics.logEvent(name: eventName, parameters: sanitized);
    }
  }

  @override
  void setUserProperties({
    required String userId,
    Map<String, dynamic>? properties,
  }) {
    if (!_isEnabled) return;

    _analytics.setUserId(id: userId);

    if (properties != null) {
      properties.forEach((key, value) {
        _analytics.setUserProperty(name: key, value: value?.toString());
      });
    }
  }

  @override
  void resetUser() {
    if (!_isEnabled) return;
    _analytics.setUserId(id: null);
  }

  @override
  void enable() {
    _isEnabled = true;
    _analytics.setAnalyticsCollectionEnabled(true);
  }

  @override
  void disable() {
    _isEnabled = false;
    _analytics.setAnalyticsCollectionEnabled(false);
  }

  @override
  bool get isEnabled => _isEnabled;
}
