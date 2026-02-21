class AppConstants {
  // API constants
  // Base URL used by ApiClient and all remote data sources
  static const String apiBaseUrl = 'https://api.raines.africa';

  // Storage constants
  static const String tokenKey = 'authToken';
  static const String userDataKey = 'userData';
  static const String refreshTokenKey = 'refreshToken';

  // App constants
  static const String appName = 'Flutter Riverpod Clean Architecture';
  static const String appVersion = '1.0.0';
  static const String packageName =
      'com.example.flutter_riverpod_clean_architecture';
  static const String iOSAppId = '123456789';
  static const String appcastUrl = 'https://your-appcast-url.com/appcast.xml';

  // Timeout durations
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Route constants
  static const String initialRoute = '/';
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String languageSettingsRoute = '/settings/language';
  static const String cartRoute = '/cart';
  static const String checkoutRoute = '/checkout';
  static const String wishlistRoute = '/wishlist';
  static const String walletRoute = '/wallet';
  static const String pointsRoute = '/points';
  static const String ordersRoute = '/orders';
  static const String orderDetailsRoute = '/orders/:orderId';
  static const String notificationsRoute = '/notifications';
  static const String notificationDetailsRoute =
      '/notifications/:notificationId';
  static const String searchRoute = '/search';
  static const String localizationDemoRoute = '/demo/localization';
  static const String localizationAssetsDemoRoute = '/demo/localization/assets';

  // Layby routes
  static const String laybyRoute = '/layby';
  static const String laybyDetailsRoute = '/layby/:applicationId';
  static const String laybyApplyRoute = '/layby/apply';
  static const String laybyPaymentRoute = '/layby/payment';

  // Ticket routes
  static const String ticketsRoute = '/tickets';
  static const String ticketDetailsRoute = '/tickets/:ticketId';

  // Gift cards / vouchers
  static const String giftCardsRoute = '/gift-cards';

  // Layby configuration
  static const double laybyEligibilityThreshold = 100.0;

  // Hive box names
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String offlineSyncBox = 'offlineSync';
  static const String cartBox = 'cart';
  static const String wishlistBox = 'wishlists';
  static const String productsBox = 'products';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Accessibility
  static const Duration accessibilityTooltipDuration = Duration(seconds: 5);
  static const double accessibilityTouchTargetMinSize = 48.0;

  // App Review
  static const int minSessionsBeforeReview = 5;
  static const int minDaysBeforeReview = 7;
  static const int minActionsBeforeReview = 10;
}
