import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

/// Example of how to use settings in various parts of the app
class SettingsUsageExample extends ConsumerWidget {
  const SettingsUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings Usage Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Site Information Example
            _buildSiteInfoExample(ref),
            const SizedBox(height: 20),

            // Currency Information Example
            _buildCurrencyInfoExample(ref),
            const SizedBox(height: 20),

            // Payment Methods Example
            _buildPaymentMethodsExample(ref),
            const SizedBox(height: 20),

            // Shipping Options Example
            _buildShippingOptionsExample(ref),
            const SizedBox(height: 20),

            // General Settings Example
            _buildGeneralSettingsExample(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteInfoExample(WidgetRef ref) {
    final siteInfo = ref.watch(siteInfoProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Site Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Name: ${siteInfo.name}'),
            Text('Title: ${siteInfo.title}'),
            Text('Tagline: ${siteInfo.tagline}'),
            Text('URL: ${siteInfo.url}'),
            Text('Copyright: ${siteInfo.copyright}'),
            if (siteInfo.logoUrl != null)
              Image.network(
                siteInfo.logoUrl!,
                height: 50,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInfoExample(WidgetRef ref) {
    final currencyInfo = ref.watch(currencyInfoProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Code: ${currencyInfo.code}'),
            Text('Symbol: ${currencyInfo.symbol}'),
            Text('Position: ${currencyInfo.symbolPosition}'),
            Text('Decimal Places: ${currencyInfo.decimalPlaces}'),
            Text('Exchange Rate: ${currencyInfo.exchangeRate}'),
            const SizedBox(height: 8),
            Text(
              'Formatted Price: ${currencyInfo.formatCurrency(99.99)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsExample(WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final enabledPaymentMethodsAsync = ref.watch(enabledPaymentMethodsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            paymentMethodsAsync.when(
              data:
                  (paymentMethods) => Column(
                    children:
                        paymentMethods
                            .map(
                              (method) => ListTile(
                                title: Text(method.title),
                                subtitle: Text('Name: ${method.name}'),
                                trailing:
                                    method.isEnabled
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                        : const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                              ),
                            )
                            .toList(),
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enabled Payment Methods:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            enabledPaymentMethodsAsync.when(
              data:
                  (enabledMethods) => Column(
                    children:
                        enabledMethods
                            .map(
                              (method) => Chip(
                                label: Text(method.title),
                                backgroundColor: Colors.green.shade100,
                              ),
                            )
                            .toList(),
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingOptionsExample(WidgetRef ref) {
    final shippingOptionsAsync = ref.watch(shippingOptionsProvider);
    final freeShippingAsync = ref.watch(freeShippingOptionsProvider);
    final paidShippingAsync = ref.watch(paidShippingOptionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            shippingOptionsAsync.when(
              data:
                  (options) => Column(
                    children:
                        options
                            .map(
                              (option) => Card(
                                child: ListTile(
                                  title: Text(option.title),
                                  subtitle: Text(option.description),
                                  trailing: Text(
                                    option.price == 0
                                        ? 'FREE'
                                        : '\$${option.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          option.price == 0
                                              ? Colors.green
                                              : Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Free Options:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      freeShippingAsync.when(
                        data: (options) => Text('${options.length} options'),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paid Options:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      paidShippingAsync.when(
                        data: (options) => Text('${options.length} options'),
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Error'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSettingsExample(WidgetRef ref) {
    final generalSettingsAsync = ref.watch(generalSettingsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            generalSettingsAsync.when(
              data:
                  (settings) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mode: ${settings.mode}'),
                      Text('Timezone: ${settings.defaultTimezone}'),
                      Text('SKU Prefix: ${settings.productSkuPrefix}'),
                      Text('Min Order Amount: ${settings.minOrderAmount}'),
                      Text(
                        'Free Shipping Threshold: \$${settings.minOrderFreeShipping}',
                      ),
                      Text(
                        'Language Direction: ${settings.adminSiteLanguageDirection}',
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Currency:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('  Code: ${settings.defaultCurrency.code}'),
                      Text('  Symbol: ${settings.defaultCurrency.symbol}'),
                      Text(
                        '  Exchange Rate: ${settings.defaultCurrency.exchangeRate}',
                      ),
                    ],
                  ),
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to use settings in a widget that needs specific settings
class ProductPriceWidget extends ConsumerWidget {
  final double price;

  const ProductPriceWidget({super.key, required this.price});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyInfo = ref.watch(currencyInfoProvider);

    return Text(
      currencyInfo.formatCurrency(price),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }
}

/// Example of how to use settings in a checkout widget
class CheckoutPaymentMethodsWidget extends ConsumerWidget {
  const CheckoutPaymentMethodsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledPaymentMethodsAsync = ref.watch(enabledPaymentMethodsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        enabledPaymentMethodsAsync.when(
          data:
              (paymentMethods) => Column(
                children:
                    paymentMethods
                        .map(
                          (method) => RadioListTile<String>(
                            title: Text(method.title),
                            value: method.name,
                            groupValue:
                                null, // You would manage this with state
                            onChanged: (value) {
                              // Handle payment method selection
                            },
                          ),
                        )
                        .toList(),
              ),
          loading: () => const CircularProgressIndicator(),
          error:
              (error, stack) => Text('Error loading payment methods: $error'),
        ),
      ],
    );
  }
}

/// Example of how to use settings in a shipping widget
class ShippingOptionsWidget extends ConsumerWidget {
  const ShippingOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shippingOptionsAsync = ref.watch(shippingOptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Shipping Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        shippingOptionsAsync.when(
          data:
              (options) => Column(
                children:
                    options
                        .map(
                          (option) => RadioListTile<ShippingOptionEntity>(
                            title: Text(option.title),
                            subtitle: Text(option.description),
                            value: option,
                            groupValue:
                                null, // You would manage this with state
                            onChanged: (value) {
                              // Handle shipping option selection
                            },
                          ),
                        )
                        .toList(),
              ),
          loading: () => const CircularProgressIndicator(),
          error:
              (error, stack) => Text('Error loading shipping options: $error'),
        ),
      ],
    );
  }
}
