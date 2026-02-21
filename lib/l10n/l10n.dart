import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'app_localizations_delegate.dart';

/// Main class for handling localizations in the app
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'), // English only
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.contains(Locale(locale.languageCode));
  }

  /// Get a localized string by key
  String translate(String key) {
    final languageMap = localizedValues[locale.languageCode];
    if (languageMap == null) {
      return localizedValues['en']?[key] ?? key;
    }
    return languageMap[key] ?? localizedValues['en']?[key] ?? key;
  }

  /// Get a localized string with parameter substitution
  String translateWithParams(String key, Map<String, String> params) {
    String value = translate(key);
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }

  // Format methods for various data types

  /// Format currency with the current locale
  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: locale.toString(),
      symbol: getCurrencySymbol(),
    ).format(amount);
  }

  /// Format date with the current locale
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  /// Format time with the current locale
  String formatTime(DateTime time) {
    return DateFormat.Hm(locale.toString()).format(time);
  }

  /// Get appropriate currency symbol based on locale
  String getCurrencySymbol() {
    // English only - using dollar symbol
    return '\$';
  }
}

// Simple translations map - English only
final Map<String, Map<String, String>> localizedValues = {
  'en': {
    'app_title': 'Flutter Riverpod Clean Architecture',
    'welcome_message': 'Welcome to Flutter Riverpod Clean Architecture',
    'home': 'Home',
    'settings': 'Settings',
    'profile': 'Profile',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'system_mode': 'System Mode',
    'language': 'Language',
    'logout': 'Logout',
    'login': 'Login',
    'email': 'Email',
    'password': 'Password',
    'sign_in': 'Sign In',
    'register': 'Register',
    'forgot_password': 'Forgot Password?',
    'error_occurred': 'An error occurred',
    'try_again': 'Try Again',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'no_data': 'No data available',
    'loading': 'Loading...',
    'cache_expired': 'Cache has expired',
    'cache_updated': 'Cache updated successfully',
    'language_settings': 'Language Settings',
    'select_your_language': 'Select Your Language',
    'language_explanation':
        'Choose your preferred language for the app interface.',
    'app_lock': 'App Lock',
    'app_lock_settings': 'App Lock Settings',
    'enable_app_lock': 'Enable App Lock',
    'app_lock_description': 'Secure your app with biometric authentication',
    'lock_timeout': 'Lock Timeout',
    'lock_timeout_description': 'How long to wait before locking the app',
    'unlock_app': 'Unlock App',
    'unlock_with_biometrics': 'Unlock with Biometrics',
    'biometrics_not_available': 'Biometrics not available',
    'biometrics_not_enrolled': 'No biometrics enrolled',
    'unlock_failed': 'Unlock failed',
    'unlock_cancelled': 'Unlock cancelled',
    'change_language': 'Change Language',
    'notifications': 'Notifications',
    'notification_settings': 'Notification Settings',
    'biometrics_status': 'Biometrics Status',
    'biometrics_available': 'Biometrics available',
    'app_lock_disabled': 'App lock disabled',
    'app_lock_enabled': 'App lock enabled',
    'app_locked_test': 'App locked for testing',
    'test_app_lock': 'Test App Lock',
    'app_locked': 'App Locked',
    'app_locked_description':
        'Your app is locked for security. Use biometric authentication to unlock.',
    'authenticating': 'Authenticating...',
    'app_lock_help':
        'Use your fingerprint, face, or other biometric method to unlock the app.',
    'biometrics_locked_out': 'Biometrics locked out. Please try again later.',
    'about_raines_africa': 'About Raines Africa',
    'legal_documents': 'Legal Documents',
    'terms_and_conditions': 'Terms and Conditions',
    'return_policy': 'Return Policy',
    'shipping_policy': 'Shipping Policy',
    'privacy_policy': 'Privacy Policy',
    'legal_document': 'Legal Document',
    'terms_description': 'Read our terms and conditions for using our services',
    'return_policy_description': 'Learn about our return and refund policy',
    'shipping_policy_description': 'Information about shipping and delivery',
    'privacy_policy_description':
        'How we protect and use your personal information',
    'legal_document_description': 'Important legal information',
    'today': 'Today',
    'yesterday': 'Yesterday',
    'days_ago': 'days ago',
    'error_loading_documents': 'Error Loading Documents',
    'no_documents_available': 'No Documents Available',
    'share': 'Share',
    'share_functionality_coming_soon': 'Share functionality coming soon',
    'last_updated': 'Last Updated',
    'document_content': 'Document Content',
    'document_info': 'Document Information',
    'document_id': 'Document ID',
    'created_date': 'Created Date',
    'created_by': 'Created By',
  },
};

/// Extension on BuildContext for easier access to localization methods
extension LocalizationExtension on BuildContext {
  /// Get the AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Translate a key to the current language
  String tr(String key) => l10n.translate(key);

  /// Translate a key with parameter substitution
  String trParams(String key, Map<String, String> params) =>
      l10n.translateWithParams(key, params);

  /// Format currency according to the current locale
  String currency(double amount) => l10n.formatCurrency(amount);

  /// Format date according to the current locale
  String formatDate(DateTime date) => l10n.formatDate(date);

  /// Format time according to the current locale
  String formatTime(DateTime time) => l10n.formatTime(time);
}
