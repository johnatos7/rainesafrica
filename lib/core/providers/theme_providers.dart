import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing theme mode in SharedPreferences
const _themeModeKey = 'theme_mode';

/// Provider for persisting and retrieving the user's theme preference
final savedThemeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final savedThemeModeIndex = prefs.getInt(_themeModeKey);

  if (savedThemeModeIndex != null) {
    return ThemeMode.values[savedThemeModeIndex];
  }

  // Default to system theme
  return ThemeMode.system;
});

/// Provider for initializing and persisting the theme mode notifier
final persistentThemeModeProvider =
    StateNotifierProvider<PersistentThemeModeNotifier, ThemeMode>((ref) {
      final prefsAsync = ref.watch(sharedPreferencesProvider);
      final initialThemeModeAsync = ref.watch(savedThemeModeProvider);

      // Handle async states
      return prefsAsync.when(
        data: (prefs) {
          return initialThemeModeAsync.when(
            data:
                (initialThemeMode) =>
                    PersistentThemeModeNotifier(prefs, initialThemeMode),
            loading: () => PersistentThemeModeNotifier(prefs, ThemeMode.system),
            error:
                (error, stack) =>
                    PersistentThemeModeNotifier(prefs, ThemeMode.system),
          );
        },
        loading: () => PersistentThemeModeNotifier(null, ThemeMode.system),
        error:
            (error, stack) =>
                PersistentThemeModeNotifier(null, ThemeMode.system),
      );
    });

/// Notifier for managing the theme mode state with persistence
class PersistentThemeModeNotifier extends StateNotifier<ThemeMode> {
  PersistentThemeModeNotifier(this._prefs, ThemeMode initialThemeMode)
    : super(initialThemeMode);

  final SharedPreferences? _prefs;

  /// Set a new theme mode and persist the choice
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_prefs != null) {
      await _prefs.setInt(_themeModeKey, themeMode.index);
    }
    state = themeMode;
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newThemeMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newThemeMode);
  }

  /// Reset to system theme
  Future<void> resetToSystemTheme() async {
    if (_prefs != null) {
      await _prefs.remove(_themeModeKey);
    }
    state = ThemeMode.system;
  }

  /// Check if current theme is dark
  bool get isDark {
    return state == ThemeMode.dark;
  }

  /// Check if current theme is light
  bool get isLight {
    return state == ThemeMode.light;
  }

  /// Check if current theme is system
  bool get isSystem {
    return state == ThemeMode.system;
  }
}

/// Provider for getting the current theme mode as a string for display
final themeModeStringProvider = Provider<String>((ref) {
  final themeMode = ref.watch(persistentThemeModeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
  }
});

/// Provider for getting the current theme mode icon
final themeModeIconProvider = Provider<IconData>((ref) {
  final themeMode = ref.watch(persistentThemeModeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return Icons.light_mode;
    case ThemeMode.dark:
      return Icons.dark_mode;
    case ThemeMode.system:
      return Icons.brightness_auto;
  }
});
