import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing selected language code in SharedPreferences
const _languageCodeKey = 'selected_language_code';


/// Provider for persisting and retrieving the user's locale preference
final savedLocaleProvider = FutureProvider<Locale>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final savedLanguageCode = prefs.getString(_languageCodeKey);

  if (savedLanguageCode != null &&
      AppLocalizations.supportedLocales.any(
        (l) => l.languageCode == savedLanguageCode,
      )) {
    return Locale(savedLanguageCode);
  }

  // Default to system locale or English if system locale is not supported
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  if (AppLocalizations.isSupported(systemLocale)) {
    return systemLocale;
  }

  return const Locale('en');
});

/// Provider for initializing and persisting the locale notifier
final persistentLocaleProvider =
    StateNotifierProvider<PersistentLocaleNotifier, Locale>((ref) {
      final prefsAsync = ref.watch(sharedPreferencesProvider);
      final initialLocaleAsync = ref.watch(savedLocaleProvider);

      // Handle async states
      return prefsAsync.when(
        data: (prefs) {
          return initialLocaleAsync.when(
            data: (initialLocale) => PersistentLocaleNotifier(prefs, initialLocale),
            loading: () => PersistentLocaleNotifier(prefs, const Locale('en')),
            error: (error, stack) => PersistentLocaleNotifier(prefs, const Locale('en')),
          );
        },
        loading: () => PersistentLocaleNotifier(null, const Locale('en')),
        error: (error, stack) => PersistentLocaleNotifier(null, const Locale('en')),
      );
    });

/// Notifier for managing the locale state with persistence
class PersistentLocaleNotifier extends StateNotifier<Locale> {
  PersistentLocaleNotifier(this._prefs, Locale initialLocale)
    : super(initialLocale);

  final SharedPreferences? _prefs;

  /// Set a new locale and persist the choice
  Future<void> setLocale(Locale locale) async {
    if (AppLocalizations.isSupported(locale)) {
      if (_prefs != null) {
        await _prefs.setString(_languageCodeKey, locale.languageCode);
      }
      state = locale;
    }
  }

  /// Reset to the system locale
  Future<void> resetToSystemLocale() async {
    if (_prefs != null) {
      await _prefs.remove(_languageCodeKey);
    }
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    if (AppLocalizations.isSupported(systemLocale)) {
      state = systemLocale;
    } else {
      state = const Locale('en');
    }
  }
}
