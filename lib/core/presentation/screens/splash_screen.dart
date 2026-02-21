import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/usecases/get_settings_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/providers/notification_provider.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    print('🔵 SPLASH SCREEN: _startSplashSequence called');

    // Kick off app data initialization in parallel
    await _initializeAppData();

    // Ensure splash shows for at least N seconds (adjust as desired)
    await Future.delayed(const Duration(seconds: 15));

    if (mounted) {
      // Check auth state before navigating
      final authState = ref.read(authProvider);
      print(
        '🔵 SPLASH SCREEN: Auth state - isAuthenticated: ${authState.isAuthenticated}, isLoading: ${authState.isLoading}',
      );

      // If user is authenticated, let the router handle navigation
      // If not authenticated, navigate to home (which will redirect to login if needed)
      if (authState.isAuthenticated) {
        print('🔵 SPLASH SCREEN: User is authenticated, navigating to home');
        context.go(AppConstants.homeRoute);
      } else {
        print(
          '🔵 SPLASH SCREEN: User not authenticated, navigating to home (router will handle redirect)',
        );
        context.go(AppConstants.homeRoute);
      }
      print('🟢 SPLASH SCREEN: Navigated to home route');
    } else {
      print('🔴 SPLASH SCREEN: Widget not mounted after delay');
    }
  }

  Future<void> _initializeAppData() async {
    try {
      // Initialize currency and settings concurrently
      await Future.wait([
        _initializeCurrency(),
        _initializeSettings(),
        _initializeNotifications(),
      ]);
    } catch (e) {
      // Swallow init errors to avoid blocking app start
      // You can route these to crashlytics if available
      // ignore: avoid_print
      print('⚠️ SPLASH INIT ERROR: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      await ref
          .read(notificationListProvider.notifier)
          .loadNotifications(refresh: true);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Notifications preload failed: $e');
    }
  }

  Future<void> _initializeCurrency() async {
    final notifier = ref.read(currencyProvider.notifier);

    // Try load previously selected currency from local storage
    await notifier.loadSelectedCurrency();

    // If none selected yet, try load cached list and pick default
    if (ref.read(currencyProvider).selectedCurrency == null) {
      await notifier.loadCachedCurrencies();
      await notifier.loadSelectedCurrency();
    }

    // If still none, fetch from network and default inside notifier
    if (ref.read(currencyProvider).selectedCurrency == null) {
      await notifier.loadCurrencies();
      await notifier.loadSelectedCurrency();
    }

    // If still none after data loads, choose based on user's location
    if (ref.read(currencyProvider).selectedCurrency == null) {
      await notifier.setCurrencyBasedOnLocation();
    }
  }

  Future<void> _initializeSettings() async {
    // If settings already cached in Hive, do nothing
    final settingsRepo =
        ref.read(settingsRepositoryProvider)
            as SettingsRepositoryImpl; // access helper methods
    final hasCache = await settingsRepo.hasCachedSettings();
    if (hasCache) return;

    // Otherwise, fetch and cache settings once
    final result = await ref.read(getSettingsUseCaseProvider).execute();
    // ignore: avoid_print
    result.fold(
      (l) => print('⚠️ Settings fetch failed: ${l.message}'),
      (r) => null,
    );
  }

  // Method to determine which splash image to use based on orientation
  String _getSplashImage() {
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;

    return orientation == Orientation.landscape
        ? 'assets/splash/splash-land.png'
        : 'assets/splash/splash.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen splash image
          Image.asset(
            _getSplashImage(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to a solid color if image fails to load
              return Container(
                color: Theme.of(context).colorScheme.primary,
                child: Center(
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            },
          ),

          // Centered loading indicator
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: _buildLoadingIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}
