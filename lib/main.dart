import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod_clean_architecture/core/accessibility/accessibility_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/widgets/auth_initializer.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/theme_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/app_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_theme.dart';
import 'package:flutter_riverpod_clean_architecture/core/updates/update_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/app_localizations_delegate.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod_clean_architecture/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:app_links/app_links.dart';

// Global AppLinks instance for deep link handling
late final AppLinks _appLinks;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize deep link handler
  _appLinks = AppLinks();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize OneSignal for push notifications
  OneSignal.initialize('9f0b49b4-f748-417c-9be1-3374d6cc7a25');
  // Request notification permission (Android 13+ and iOS)
  OneSignal.Notifications.requestPermission(true);

  // Run the app with ProviderScope to enable Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Override the shared preferences provider with the instance
        sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),

        // Override the default locale provider to use our persistent locale
        defaultLocaleProvider.overrideWith(
          (ref) => ref.watch(persistentLocaleProvider),
        ),
      ],
      child: const AuthInitializer(child: MyApp()),
    ),
  );
}

// Legacy provider - now using persistentThemeModeProvider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static bool _oneSignalListenerAttached = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router from provider
    final router = ref.watch(routerProvider);

    // Watch the persistent theme mode
    final themeMode = ref.watch(persistentThemeModeProvider);

    // Watch the persistent locale
    final locale = ref.watch(persistentLocaleProvider);

    // Watch currencyProvider to trigger initialization at app startup
    ref.watch(currencyProvider);

    // Attach OneSignal click listener once app is built and router is ready
    if (!_oneSignalListenerAttached) {
      _oneSignalListenerAttached = true;
      OneSignal.Notifications.addClickListener((event) {
        final title = event.notification.title;
        final message = event.notification.body;
        final uri =
            Uri(
              path: '/notifications/push_message',
              queryParameters: {
                if (title != null && title.isNotEmpty) 'title': title,
                if (message != null && message.isNotEmpty) 'message': message,
              },
            ).toString();
        // Use GoRouter to navigate
        router.go(uri);
      });

      // Listen for incoming deep links and route through GoRouter
      _appLinks.uriLinkStream.listen((Uri uri) {
        print('🔗 [DEEP LINK] Received: $uri');
        if (uri.host == 'raines.africa') {
          final routeUri = Uri(
            path: uri.path.isEmpty ? '/' : uri.path,
            queryParameters:
                uri.queryParameters.isNotEmpty ? uri.queryParameters : null,
          );
          print('🔗 [DEEP LINK] Navigating to: $routeUri');
          router.go(routeUri.toString());
        }
      });

      // Handle initial link (cold start)
      _appLinks.getInitialLink().then((Uri? uri) {
        if (uri != null && uri.host == 'raines.africa') {
          print('🔗 [DEEP LINK] Initial link: $uri');
          final routeUri = Uri(
            path: uri.path.isEmpty ? '/' : uri.path,
            queryParameters: uri.queryParameters,
          );
          router.go(routeUri.toString());
        }
      });
    }

    return AccessibilityWrapper(
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,

        // Localization settings
        locale: locale,
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Temporarily disable UpdateChecker to test if it's causing the issue
        builder: (context, child) {
          return UpdateChecker(
            autoPrompt: false, // Disable automatic update prompts
            enforceCriticalUpdates: true,
            child: child!,
          );
        },
      ),
    );
  }
}
