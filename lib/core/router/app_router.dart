import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/main_home_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/screens/cart_screen.dart';
//import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/screens/checkout_steps_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/checkout/presentation/screens/payment_webview_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/orders_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/order_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/screens/notification_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/notifications/presentation/screens/push_message_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/address_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/add_edit_address_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_search_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/wallet/presentation/screens/my_wallet_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/vouchers/presentation/screens/gift_cards_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/points/presentation/screens/points_earnings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/screens/layby_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/screens/layby_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/screens/layby_application_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/screens/ticket_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/tickets/presentation/screens/ticket_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/feedback/presentation/screens/marketing_feedback_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/presentation/screens/layby_payment_webview_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/layby/domain/entities/layby_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/product_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/sku_collection_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/screens/category_products_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/domain/entities/product_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final routerKey = GlobalKey<NavigatorState>(debugLabel: 'routerKey');
  final authStateListenable = ValueNotifier<AuthState>(ref.read(authProvider));

  ref
    ..onDispose(authStateListenable.dispose)
    ..listen(authProvider, (_, next) {
      authStateListenable.value = next;
    });

  // Watch for locale changes - this rebuilds the router when locale changes
  ref.watch(persistentLocaleProvider);

  final router = GoRouter(
    navigatorKey: routerKey,
    initialLocation: '/loading',
    refreshListenable: authStateListenable,
    routes: [
      GoRoute(path: '/loading', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const MainHomeScreen(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (_, __) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit_profile',
                builder: (_, __) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'crop',
                    name: 'crop',
                    builder:
                        (_, state) =>
                            const SettingsScreen(), // Replace with actual CropScreen
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'intro',
            name: 'intro',
            builder:
                (_, __) =>
                    const MainHomeScreen(), // Replace with actual IntroScreen
          ),

          GoRoute(
            path: 'privacy_policy',
            name: 'privacy_policy',
            builder: (context, state) {
              return const MainHomeScreen(); // Replace with actual PrivacyPolicyScreen
            },
          ),
          GoRoute(
            path: 'licenses',
            name: 'licenses',
            builder: (context, state) {
              return const MainHomeScreen(); // Replace with actual LicencesPage
            },
          ),
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (context, state) {
              return const MainHomeScreen(); // Replace with actual AboutScreen
            },
          ),
          GoRoute(
            path: 'password_reset',
            name: 'password_reset',
            builder: (context, state) {
              return const MainHomeScreen(); // Replace with actual PassResetScreen
            },
          ),
          // Cart route
          GoRoute(
            path: 'cart',
            name: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
          // Checkout route
          // GoRoute(
          //   path: 'checkout',
          //   name: 'checkout',
          //   builder: (context, state) => const CheckoutScreen(),
          // ),
          // Checkout steps route
          GoRoute(
            path: 'checkout_steps',
            name: 'checkout_steps',
            builder: (context, state) => const CheckoutStepsScreen(),
          ),
          // Marketing feedback route
          GoRoute(
            path: 'feedback/:orderNumber',
            name: 'marketing_feedback',
            builder: (context, state) {
              final orderNumber = state.pathParameters['orderNumber'] ?? '';
              final feedbackToken = state.uri.queryParameters['token'];
              return MarketingFeedbackScreen(
                orderNumber: orderNumber,
                feedbackToken: feedbackToken,
              );
            },
          ),
          // Payment webview route
          GoRoute(
            path: 'payment_webview',
            name: 'payment_webview',
            builder: (context, state) {
              final url = state.uri.queryParameters['url'];
              final orderNumberParam = state.uri.queryParameters['orderNumber'];
              final successPrefix = state.uri.queryParameters['successPrefix'];
              final orderNumber =
                  orderNumberParam != null
                      ? int.tryParse(orderNumberParam)
                      : null;
              if (url == null || url.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text('Missing payment URL')),
                );
              }
              return PaymentWebViewScreen(
                initialUrl: url,
                orderNumber: orderNumber,
                successPathPrefix: successPrefix,
              );
            },
          ),
          // Orders route
          GoRoute(
            path: 'orders',
            name: 'orders',
            builder: (context, state) => const OrdersScreen(),
            routes: [
              GoRoute(
                path: ':orderId',
                name: 'order_details',
                builder: (context, state) {
                  final orderId = int.parse(state.pathParameters['orderId']!);
                  return OrderDetailsScreen(orderId: orderId);
                },
              ),
            ],
          ),
          // Notifications route
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
            routes: [
              GoRoute(
                path: 'push_message',
                name: 'push_message',
                builder: (context, state) {
                  final title = state.uri.queryParameters['title'];
                  final message = state.uri.queryParameters['message'];
                  return PushMessageScreen(title: title, message: message);
                },
              ),
              GoRoute(
                path: ':notificationId',
                name: 'notification_details',
                builder: (context, state) {
                  final notificationId =
                      state.pathParameters['notificationId']!;
                  return NotificationDetailsScreen(
                    notificationId: notificationId,
                  );
                },
              ),
            ],
          ),
          // Wishlist route
          GoRoute(
            path: 'wishlist',
            name: 'wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),
          // Wallet route
          GoRoute(
            path: 'wallet',
            name: 'wallet',
            builder: (context, state) => const MyWalletScreen(),
          ),
          // Gift cards route
          GoRoute(
            path: 'gift-cards',
            name: 'gift-cards',
            builder: (context, state) => const GiftCardsScreen(),
          ),
          // Points route
          GoRoute(
            path: 'points',
            name: 'points',
            builder: (context, state) => const PointsEarningsScreen(),
          ),
          // Search route
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) => ProductSearchScreen(),
          ),
          // Settings route
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'language',
                name: 'language_settings',
                builder: (context, state) => const LanguageSettingsScreen(),
              ),
            ],
          ),
          // Layby routes
          GoRoute(
            path: 'layby',
            name: 'layby',
            builder: (context, state) => const LaybyListScreen(),
            routes: [
              GoRoute(
                path: 'apply',
                name: 'layby_apply',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  final productId = extra['productId'] as int? ?? 0;
                  final variationId = extra['variationId'] as int?;
                  final eligibility =
                      extra['eligibility'] as LaybyEligibility? ??
                      const LaybyEligibility(
                        eligible: false,
                        depositPercentage: 0,
                        availableDurations: [],
                        minPrice: 0,
                        isSaleProduct: false,
                      );
                  final productPrice =
                      (extra['productPrice'] as num?)?.toDouble() ?? 0.0;
                  return LaybyApplicationScreen(
                    productId: productId,
                    variationId: variationId,
                    eligibility: eligibility,
                    productPrice: productPrice,
                  );
                },
              ),
              GoRoute(
                path: 'payment',
                name: 'layby_payment',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  final url = extra['url'] as String? ?? '';
                  final applicationId = extra['applicationId'] as int? ?? 0;
                  return LaybyPaymentWebViewScreen(
                    initialUrl: url,
                    applicationId: applicationId,
                  );
                },
              ),
              GoRoute(
                path: ':applicationId',
                name: 'layby_details',
                builder: (context, state) {
                  final id =
                      int.tryParse(
                        state.pathParameters['applicationId'] ?? '',
                      ) ??
                      0;
                  return LaybyDetailsScreen(applicationId: id);
                },
              ),
            ],
          ),
          // Ticket routes
          GoRoute(
            path: 'tickets',
            name: 'tickets',
            builder: (context, state) => const TicketListScreen(),
            routes: [
              GoRoute(
                path: ':ticketId',
                name: 'ticket_details',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['ticketId'] ?? '') ?? 0;
                  return TicketDetailsScreen(ticketId: id);
                },
              ),
            ],
          ),
          // Address routes
          GoRoute(
            path: 'addresses',
            name: 'addresses',
            builder: (context, state) => const AddressListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add_address',
                builder: (context, state) {
                  final redirectPath = state.uri.queryParameters['redirect'];
                  return AddEditAddressScreen(redirectPath: redirectPath);
                },
              ),
              GoRoute(
                path: 'edit/:addressId',
                name: 'edit_address',
                builder: (context, state) {
                  // For now, just show the add address screen
                  // In a real app, you'd load the address by ID and pass it
                  final redirectPath = state.uri.queryParameters['redirect'];
                  return AddEditAddressScreen(redirectPath: redirectPath);
                },
              ),
            ],
          ),
        ],
      ),
      // Deep link routes for raines.africa (with /en/ prefix)
      GoRoute(
        path: '/en/product/:slug',
        name: 'deep_link_product',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final product = ProductEntity(
            id: 0,
            name: '',
            slug: slug,
            productGalleries: [],
            price: 0,
          );
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) GoRouter.of(context).go('/');
            },
            child: ProductDetailsScreen(key: ValueKey(slug), product: product),
          );
        },
      ),
      GoRoute(
        path: '/en/collections',
        name: 'deep_link_collections',
        builder: (context, state) {
          final skusParam = state.uri.queryParameters['skus'] ?? '';
          Widget child;
          if (skusParam.isNotEmpty) {
            final skus =
                skusParam
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
            child = SkuCollectionScreen(skus: skus, title: 'Collection');
          } else {
            final category = state.uri.queryParameters['category'] ?? '';
            if (category.isEmpty) {
              child = const MainHomeScreen();
            } else {
              child = CategoryProductsScreen(
                categorySlug: category,
                categoryName: category.replaceAll('-', ' '),
              );
            }
          }
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) GoRouter.of(context).go('/');
            },
            child: child,
          );
        },
      ),
      // Deep link routes without locale prefix (some links omit /en/)
      GoRoute(
        path: '/product/:slug',
        name: 'deep_link_product_no_locale',
        builder: (context, state) {
          final slug = state.pathParameters['slug'] ?? '';
          final product = ProductEntity(
            id: 0,
            name: '',
            slug: slug,
            productGalleries: [],
            price: 0,
          );
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) GoRouter.of(context).go('/');
            },
            child: ProductDetailsScreen(key: ValueKey(slug), product: product),
          );
        },
      ),
      GoRoute(
        path: '/collections',
        name: 'deep_link_collections_no_locale',
        builder: (context, state) {
          final skusParam = state.uri.queryParameters['skus'] ?? '';
          Widget child;
          if (skusParam.isNotEmpty) {
            final skus =
                skusParam
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();
            child = SkuCollectionScreen(skus: skus, title: 'Collection');
          } else {
            final category = state.uri.queryParameters['category'] ?? '';
            if (category.isEmpty) {
              child = const MainHomeScreen();
            } else {
              child = CategoryProductsScreen(
                categorySlug: category,
                categoryName: category.replaceAll('-', ' '),
              );
            }
          }
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) GoRouter.of(context).go('/');
            },
            child: child,
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final redirectPath = state.uri.queryParameters['redirect'];
          return RegisterScreen(redirectPath: redirectPath);
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final redirectPath = state.uri.queryParameters['redirect'];
          return LoginScreen(redirectPath: redirectPath);
        },
      ),
    ],
    redirect: (context, state) async {
      final lMatch = state.matchedLocation;
      final qParams = Map<String, String>.from(state.uri.queryParameters);
      final authState = authStateListenable.value;
      final authStatus = authState.status;
      final prefs = await SharedPreferences.getInstance();
      final isVerifyPollUrl = prefs.getBool('isVerifyPollUrl') ?? true;

      // Don't remove redirect parameter if it matches current location
      // This allows proper redirect after login
      // if (qParams['redirect'] == lMatch) {
      //   qParams.remove('redirect');
      // }

      if (authStatus == AuthStatus.uninitialized) {
        if (lMatch != '/loading') {
          qParams['redirect'] = qParams['redirect'] ?? lMatch;
        }
        return Uri(path: '/loading', queryParameters: qParams).toString();
      }

      final isProtectedRoute =
          lMatch.startsWith('/profile') ||
          lMatch == '/intro' ||
          lMatch == '/checkout' ||
          lMatch == '/checkout_steps' ||
          lMatch.startsWith('/orders') ||
          lMatch.startsWith('/notifications') ||
          lMatch == '/wishlist' ||
          lMatch == '/wallet' ||
          lMatch == '/points' ||
          lMatch.startsWith('/settings') ||
          lMatch.startsWith('/addresses') ||
          lMatch.startsWith('/layby') ||
          lMatch.startsWith('/tickets');

      final isAuthenticated = authStatus == AuthStatus.authenticated;

      if (isProtectedRoute && !isAuthenticated) {
        qParams['redirect'] = qParams['redirect'] ?? lMatch;
        final redirectUrl =
            Uri(path: '/login', queryParameters: qParams).toString();
        print(
          '🔵 ROUTER: Redirecting to login with redirect: ${qParams['redirect']}',
        );
        print('🔵 ROUTER: Full redirect URL: $redirectUrl');
        return redirectUrl;
      }

      if (isProtectedRoute &&
          isAuthenticated &&
          !isVerifyPollUrl &&
          !(lMatch == '/payment_webview')) {
        qParams['redirect'] = qParams['redirect'] ?? lMatch;
        return Uri(
          path: '/payment_status',
          queryParameters: qParams,
        ).toString();
      }

      if ((lMatch == '/login' || lMatch == '/loading') && isAuthenticated) {
        final redirectPath = qParams['redirect'] ?? '/';
        print(
          '🔵 ROUTER: Authenticated user on $lMatch, redirecting to: $redirectPath',
        );
        return redirectPath;
      }
      if (lMatch == '/loading' && !isAuthenticated) {
        return qParams['redirect'] ?? '/';
      }
      return null;
    },
  );
  return router;
});
