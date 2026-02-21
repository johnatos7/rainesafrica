import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/currency/presentation/providers/currency_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/products/presentation/widgets/product_search_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/features/cart/presentation/widgets/cart_icon_widget.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/presentation/screens/address_management_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/refund_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/orders/presentation/screens/return_list_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/presentation/screens/banking_details_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/about_screen.dart';
import 'package:flutter_riverpod_clean_architecture/core/presentation/widgets/theme_toggle_widget.dart';

class AccountTabScreen extends ConsumerWidget {
  const AccountTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          authState.isAuthenticated && authState.user?.name.isNotEmpty == true
              ? 'Welcome, ${authState.user!.name}!'
              : 'My Account',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        backgroundColor: colors.surface,
        elevation: 1,
        iconTheme: IconThemeData(color: colors.onSurface),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colors.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductSearchScreen()),
              );
            },
          ),
          const ThemeToggleButton(),
          CartIconWidget(
            iconColor: colors.onSurface,
            badgeColor: colors.primary,
            iconSize: 24,
          ),
          // NotificationIconWidget(
          //   iconColor: colors.onSurface,
          //   badgeColor: colors.primary,
          //   iconSize: 24,
          // ),
          const SizedBox(width: 8),
        ],
      ),
      body:
          authState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        // Account Section
                        _buildSectionHeader('Account', theme),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildAccountListItem(
                              context,
                              Icons.shopping_bag_outlined,
                              'Orders',
                              'Track your orders',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.ordersRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.ordersRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.notifications_outlined,
                              'Notifications',
                              'Manage your alerts',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.notificationsRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.notificationsRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.person_outline,
                              'Update Profile',
                              'Edit your account information',
                              () {
                                if (authState.isAuthenticated) {
                                  _showUpdateProfileDialog(context, ref);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.settingsRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.money_off_outlined,
                              'My Refunds',
                              'View your refund requests',
                              () {
                                if (authState.isAuthenticated) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const RefundListScreen(),
                                    ),
                                  );
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=/refunds',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.keyboard_return_outlined,
                              'My Returns',
                              'View your return requests',
                              () {
                                if (authState.isAuthenticated) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const ReturnListScreen(),
                                    ),
                                  );
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=/returns',
                                  );
                                }
                              },
                            ),
                          ]),
                        ),

                        // Personalization Section
                        _buildSectionHeader('Personalization', theme),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildAccountListItem(
                              context,
                              Icons.location_on_outlined,
                              'Address Book',
                              'Manage your addresses',
                              () {
                                if (authState.isAuthenticated) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const AddressManagementScreen(),
                                    ),
                                  );
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=/addresses',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.account_balance_wallet_outlined,
                              'My Wallet',
                              'Balance and payment methods',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.walletRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.walletRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.card_giftcard_outlined,
                              'Gift Cards & Vouchers',
                              'Redeem and manage gift cards',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.giftCardsRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.giftCardsRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.calendar_today_outlined,
                              'My Laybys',
                              'Buy now, pay later applications',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.laybyRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.laybyRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.stars_outlined,
                              'Points Earnings',
                              'Track your reward points',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.pointsRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.pointsRoute}',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.account_balance_outlined,
                              'Banking Details',
                              'Manage your payment accounts',
                              () {
                                if (authState.isAuthenticated) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const BankingDetailsScreen(),
                                    ),
                                  );
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=/banking-details',
                                  );
                                }
                              },
                            ),
                            _buildAccountListItem(
                              context,
                              Icons.support_agent_outlined,
                              'Support Tickets',
                              'Get help from our team',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.ticketsRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.ticketsRoute}',
                                  );
                                }
                              },
                            ),
                          ]),
                        ),

                        // About Section
                        _buildSectionHeader('About', theme),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildAccountListItem(
                              context,
                              Icons.info_outline,
                              'About Raines Africa',
                              'Company information, contact details, and policies',
                              () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AboutScreen(),
                                  ),
                                );
                              },
                            ),
                          ]),
                        ),

                        // Settings Section
                        _buildSectionHeader('Settings', theme),
                        SliverList(
                          delegate: SliverChildListDelegate([
                            _buildAccountListItem(
                              context,
                              Icons.settings_outlined,
                              'Account Settings',
                              'Manage your account preferences',
                              () {
                                if (authState.isAuthenticated) {
                                  context.push(AppConstants.settingsRoute);
                                } else {
                                  context.push(
                                    '${AppConstants.loginRoute}?redirect=${AppConstants.settingsRoute}',
                                  );
                                }
                              },
                            ),
                            // _buildAccountListItem(
                            //   context,
                            //   Icons.smartphone_outlined,
                            //   'App Settings',
                            //   'Customize app experience',
                            //   () {
                            //     // Navigate to app settings
                            //   },
                            // ),
                            _buildAccountListItem(
                              context,
                              Icons.currency_exchange_outlined,
                              'Currency',
                              currencyState.selectedCurrency != null
                                  ? '${currencyState.selectedCurrency!.code} (${currencyState.selectedCurrency!.symbol})'
                                  : 'Select your preferred currency',
                              () => _showCurrencySelectionDialog(context, ref),
                            ),
                          ]),
                        ),

                        // Authentication Section
                        SliverPadding(
                          padding: const EdgeInsets.all(24),
                          sliver: SliverToBoxAdapter(
                            child:
                                authState.isAuthenticated
                                    ? _buildSignOutButton(context, ref, colors)
                                    : _buildAuthButtons(context, colors),
                          ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  SliverPadding _buildSectionHeader(String title, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountListItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outline.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurface.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colors,
  ) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            await ref.read(authProvider.notifier).deleteSession();
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20),
              SizedBox(width: 8),
              Text(
                'Sign Out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context, ColorScheme colors) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          onPressed: () => context.push(AppConstants.loginRoute),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 20),
              SizedBox(width: 8),
              Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: colors.primary),
          ),
          onPressed: () => context.push(AppConstants.registerRoute),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add, size: 20),
              SizedBox(width: 8),
              Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCurrencySelectionDialog(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // If currencies haven't been loaded yet, load them now
    if (currencyState.currencies.isEmpty && !currencyState.isLoading) {
      ref.read(currencyProvider.notifier).reloadCurrencies();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder:
                  (context, scrollController) => Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.onSurface.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Icon(
                              Icons.currency_exchange,
                              color: colors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Select Currency',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: colors.onSurface.withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            final currentCurrencyState = ref.watch(
                              currencyProvider,
                            );
                            return currentCurrencyState.isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : currentCurrencyState.currencies.isEmpty
                                ? _buildEmptyState(context, ref)
                                : ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount:
                                      currentCurrencyState.currencies.length,
                                  itemBuilder: (context, index) {
                                    final currency =
                                        currentCurrencyState.currencies[index];
                                    final isSelected =
                                        currentCurrencyState
                                            .selectedCurrency
                                            ?.id ==
                                        currency.id;
                                    return _buildCurrencyItem(
                                      context,
                                      ref,
                                      currency,
                                      isSelected,
                                    );
                                  },
                                );
                          },
                        ),
                      ),
                    ],
                  ),
            ),
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No currencies available',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(currencyProvider.notifier).reloadCurrencies();
              },
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(
    BuildContext context,
    WidgetRef ref,
    dynamic currency,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary.withOpacity(0.1) : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? colors.primary : colors.outline.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(currencyProvider.notifier).setSelectedCurrency(currency);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? colors.primary : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        currency.symbol,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.code,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? colors.primary : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exchange Rate: ${currency.exchangeRate}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: colors.primary, size: 24)
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.outline, width: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showUpdateProfileDialog(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Form controllers
    final nameController = TextEditingController(
      text: authState.user?.name ?? '',
    );
    final emailController = TextEditingController(
      text: authState.user?.email ?? '',
    );
    final countryCodeController = TextEditingController(
      text: authState.user?.countryCode ?? '',
    );
    final phoneController = TextEditingController(
      text: authState.user?.phone ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Update Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: colors.primary,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: countryCodeController,
                    decoration: InputDecoration(
                      labelText: 'Country Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.flag_outlined,
                        color: colors.primary,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                        color: colors.primary,
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authProvider);
                  return ElevatedButton(
                    onPressed:
                        authState.isLoading
                            ? null
                            : () async {
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  countryCodeController.text.isEmpty ||
                                  phoneController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Please fill in all fields'),
                                    backgroundColor: colors.error,
                                  ),
                                );
                                return;
                              }

                              final phoneNumber = int.tryParse(
                                phoneController.text,
                              );
                              if (phoneNumber == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please enter a valid phone number',
                                    ),
                                    backgroundColor: colors.error,
                                  ),
                                );
                                return;
                              }

                              final authNotifier = ref.read(
                                authProvider.notifier,
                              );
                              final result = await authNotifier.updateProfile(
                                name: nameController.text,
                                email: emailController.text,
                                countryCode: countryCodeController.text,
                                phone: phoneNumber,
                              );

                              if (result != null) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Profile updated successfully!',
                                    ),
                                    backgroundColor: colors.primary,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      authState.errorMessage ??
                                          'Failed to update profile',
                                    ),
                                    backgroundColor: colors.error,
                                  ),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        authState.isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.onPrimary,
                                ),
                              ),
                            )
                            : Text('Update'),
                  );
                },
              ),
            ],
          ),
    );
  }
}
