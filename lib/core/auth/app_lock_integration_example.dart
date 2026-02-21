import 'package:flutter/material.dart';

/// Example of how to integrate AppLockWrapper in your main app
///
/// To integrate app lock functionality in your app, wrap your main content
/// with AppLockWrapper. Here's how you would modify your main.dart:
///
/// ```dart
/// import 'package:flutter_riverpod_clean_architecture/core/auth/app_lock_wrapper.dart';
///
/// class MyApp extends ConsumerWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final router = ref.watch(routerProvider);
///     final themeMode = ref.watch(persistentThemeModeProvider);
///     final locale = ref.watch(persistentLocaleProvider);
///
///     return AccessibilityWrapper(
///       child: AppLockWrapper(  // <-- Add this wrapper
///         child: MaterialApp.router(
///           title: AppConstants.appName,
///           theme: AppTheme.lightTheme,
///           darkTheme: AppTheme.darkTheme,
///           themeMode: themeMode,
///           routerConfig: router,
///           debugShowCheckedModeBanner: false,
///           locale: locale,
///           localizationsDelegates: [
///             const AppLocalizationsDelegate(),
///             GlobalMaterialLocalizations.delegate,
///             GlobalWidgetsLocalizations.delegate,
///             GlobalCupertinoLocalizations.delegate,
///           ],
///           supportedLocales: AppLocalizations.supportedLocales,
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// The AppLockWrapper will automatically:
/// 1. Show the lock screen when the app is locked
/// 2. Track when the app goes to background/foreground
/// 3. Lock the app based on the configured timeout
/// 4. Handle biometric authentication
///
/// Users can configure app lock settings in:
/// Settings > App Lock
class AppLockIntegrationExample extends StatelessWidget {
  const AppLockIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'This is an example file showing how to integrate AppLockWrapper',
        ),
      ),
    );
  }
}
