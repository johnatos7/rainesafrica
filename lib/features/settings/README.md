# Settings Feature

This feature provides comprehensive app settings management following clean architecture principles. It handles all app configuration data from the API and provides easy access throughout the application.

## Features

- ✅ **Complete Settings Model**: Handles all settings data from the API
- ✅ **Clean Architecture**: Domain entities, use cases, and data models
- ✅ **Local Caching**: Offline support with 24-hour cache validity
- ✅ **Error Handling**: Comprehensive error handling and validation
- ✅ **State Management**: Riverpod providers for reactive state management
- ✅ **Type Safety**: Strongly typed entities and models
- ✅ **Validation**: Settings validation with detailed error reporting

## API Endpoint

```
GET https://api.raines.africa/api/settings
```

## Architecture

```
lib/features/settings/
├── data/
│   ├── datasources/
│   │   ├── settings_remote_data_source.dart
│   │   └── settings_local_data_source.dart
│   ├── models/
│   │   └── settings_model.dart
│   └── repositories/
│       └── settings_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── settings_entity.dart
│   ├── repositories/
│   │   └── settings_repository.dart
│   └── usecases/
│       ├── get_settings_use_case.dart
│       ├── get_general_settings_use_case.dart
│       ├── get_payment_methods_use_case.dart
│       ├── get_delivery_settings_use_case.dart
│       └── validate_settings_use_case.dart
├── presentation/
│   └── providers/
│       └── settings_providers.dart
└── examples/
    └── settings_usage_example.dart
```

## Usage Examples

### Basic Settings Access

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    
    return settingsAsync.when(
      data: (settings) => Text('Site: ${settings.general.siteName}'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Site Information

```dart
class SiteHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteInfo = ref.watch(siteInfoProvider);
    
    return Column(
      children: [
        Text(siteInfo.name),
        if (siteInfo.logoUrl != null)
          Image.network(siteInfo.logoUrl!),
      ],
    );
  }
}
```

### Currency Formatting

```dart
class PriceWidget extends ConsumerWidget {
  final double price;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyInfo = ref.watch(currencyInfoProvider);
    
    return Text(currencyInfo.formatCurrency(price));
  }
}
```

### Payment Methods

```dart
class PaymentMethodsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethodsAsync = ref.watch(enabledPaymentMethodsProvider);
    
    return paymentMethodsAsync.when(
      data: (methods) => Column(
        children: methods.map((method) => 
          PaymentMethodCard(method: method)
        ).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Shipping Options

```dart
class ShippingOptionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shippingOptionsAsync = ref.watch(shippingOptionsProvider);
    
    return shippingOptionsAsync.when(
      data: (options) => Column(
        children: options.map((option) => 
          ShippingOptionCard(option: option)
        ).toList(),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## Available Providers

### Main Providers
- `settingsProvider` - Complete settings data
- `generalSettingsProvider` - General settings only
- `paymentMethodsProvider` - All payment methods
- `enabledPaymentMethodsProvider` - Only enabled payment methods
- `deliverySettingsProvider` - Delivery settings
- `shippingOptionsProvider` - All shipping options
- `freeShippingOptionsProvider` - Free shipping options only
- `paidShippingOptionsProvider` - Paid shipping options only

### Helper Providers
- `siteInfoProvider` - Extracted site information
- `currencyInfoProvider` - Currency formatting utilities

## Settings Structure

### General Settings
- Site information (name, title, tagline, URL)
- Currency configuration
- Logo and favicon URLs
- Order settings (minimum amount, free shipping threshold)
- Timezone and language settings

### Delivery Settings
- Default delivery options
- Same-day delivery configuration
- Shipping options with pricing
- Delivery time intervals

### Payment Methods
- Available payment methods
- Method status (enabled/disabled)
- Method configuration

### Analytics Settings
- Facebook Pixel configuration
- Google Analytics settings

### Activation Settings
- Feature toggles (multivendor, points, coupons, wallet)
- Auto-approval settings

### Maintenance Settings
- Maintenance mode configuration
- Maintenance page content

### Wallet & Points Settings
- Points configuration
- Reward settings
- Currency conversion ratios

## Caching Strategy

- **Cache Duration**: 24 hours
- **Cache Key**: `cached_settings`
- **Fallback**: Uses cached data when network fails
- **Refresh**: Force refresh available via repository

## Error Handling

The settings feature includes comprehensive error handling:

- **Network Errors**: Falls back to cached data
- **Validation Errors**: Detailed validation with error reporting
- **Cache Errors**: Graceful degradation
- **API Errors**: Proper error propagation

## Validation

Settings validation includes:

- Required field validation
- URL format validation
- Numeric value validation
- Business logic validation
- Warning generation for potential issues

## Best Practices

1. **Use Specific Providers**: Use specific providers (e.g., `siteInfoProvider`) instead of the main `settingsProvider` when you only need specific data
2. **Handle Loading States**: Always handle loading and error states
3. **Cache Awareness**: Be aware that settings might be cached data
4. **Validation**: Use the validation use case for settings integrity checks
5. **Error Handling**: Implement proper error handling for network failures

## Dependencies

- `flutter_riverpod` - State management
- `dartz` - Functional programming (Either type)
- `equatable` - Value equality
- Core dependencies (NetworkInfo, LocalStorageService, ApiClient)

## Testing

The settings feature is designed to be easily testable:

- Repository can be mocked for unit tests
- Use cases can be tested independently
- Providers can be overridden in tests
- Local data source can be mocked for offline testing

## Future Enhancements

- Settings update functionality
- Real-time settings updates
- Settings synchronization
- Advanced caching strategies
- Settings backup and restore
