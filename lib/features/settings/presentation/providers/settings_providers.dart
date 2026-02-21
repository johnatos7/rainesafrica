import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/usecases/get_settings_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/usecases/get_general_settings_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/usecases/get_payment_methods_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/usecases/get_delivery_settings_use_case.dart';

// Main settings provider
final settingsProvider = FutureProvider<SettingsEntity>((ref) async {
  final getSettingsUseCase = ref.watch(getSettingsUseCaseProvider);
  final result = await getSettingsUseCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (settings) => settings,
  );
});

// General settings provider
final generalSettingsProvider = FutureProvider<GeneralSettingsEntity>((
  ref,
) async {
  final getGeneralSettingsUseCase = ref.watch(
    getGeneralSettingsUseCaseProvider,
  );
  final result = await getGeneralSettingsUseCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (settings) => settings,
  );
});

// Payment methods provider
final paymentMethodsProvider = FutureProvider<List<PaymentMethodEntity>>((
  ref,
) async {
  final getPaymentMethodsUseCase = ref.watch(getPaymentMethodsUseCaseProvider);
  final result = await getPaymentMethodsUseCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (paymentMethods) => paymentMethods,
  );
});

// Enabled payment methods provider
final enabledPaymentMethodsProvider = FutureProvider<List<PaymentMethodEntity>>(
  (ref) async {
    final getPaymentMethodsUseCase = ref.watch(
      getPaymentMethodsUseCaseProvider,
    );
    final result = await getPaymentMethodsUseCase.getEnabledPaymentMethods();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (paymentMethods) => paymentMethods,
    );
  },
);

// Delivery settings provider
final deliverySettingsProvider = FutureProvider<DeliverySettingsEntity>((
  ref,
) async {
  final getDeliverySettingsUseCase = ref.watch(
    getDeliverySettingsUseCaseProvider,
  );
  final result = await getDeliverySettingsUseCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (settings) => settings,
  );
});

// Shipping options provider
final shippingOptionsProvider = FutureProvider<List<ShippingOptionEntity>>((
  ref,
) async {
  final getDeliverySettingsUseCase = ref.watch(
    getDeliverySettingsUseCaseProvider,
  );
  final result = await getDeliverySettingsUseCase.getShippingOptions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (shippingOptions) => shippingOptions,
  );
});

// Free shipping options provider
final freeShippingOptionsProvider = FutureProvider<List<ShippingOptionEntity>>((
  ref,
) async {
  final getDeliverySettingsUseCase = ref.watch(
    getDeliverySettingsUseCaseProvider,
  );
  final result = await getDeliverySettingsUseCase.getFreeShippingOptions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (shippingOptions) => shippingOptions,
  );
});

// Paid shipping options provider
final paidShippingOptionsProvider = FutureProvider<List<ShippingOptionEntity>>((
  ref,
) async {
  final getDeliverySettingsUseCase = ref.watch(
    getDeliverySettingsUseCaseProvider,
  );
  final result = await getDeliverySettingsUseCase.getPaidShippingOptions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (shippingOptions) => shippingOptions,
  );
});

// Site information provider (extracted from general settings)
final siteInfoProvider = Provider<SiteInfo>((ref) {
  final generalSettingsAsync = ref.watch(generalSettingsProvider);
  return generalSettingsAsync.when(
    data:
        (settings) => SiteInfo(
          name: settings.siteName,
          title: settings.siteTitle,
          tagline: settings.siteTagline,
          url: settings.siteUrl,
          copyright: settings.copyright,
          logoUrl: settings.lightLogoImage?.imageUrl,
          darkLogoUrl: settings.darkLogoImage?.imageUrl,
          faviconUrl: settings.faviconImage?.imageUrl,
        ),
    loading: () => SiteInfo.empty(),
    error: (_, __) => SiteInfo.empty(),
  );
});

// Currency information provider
final currencyInfoProvider = Provider<CurrencyInfo>((ref) {
  final generalSettingsAsync = ref.watch(generalSettingsProvider);
  return generalSettingsAsync.when(
    data:
        (settings) => CurrencyInfo(
          code: settings.defaultCurrency.code,
          symbol: settings.defaultCurrency.symbol,
          symbolPosition: settings.defaultCurrency.symbolPosition,
          decimalPlaces: settings.defaultCurrency.noOfDecimal,
          exchangeRate:
              double.tryParse(settings.defaultCurrency.exchangeRate) ?? 1.0,
        ),
    loading: () => CurrencyInfo.empty(),
    error: (_, __) => CurrencyInfo.empty(),
  );
});

// Helper classes for easier access to specific settings
class SiteInfo {
  final String name;
  final String title;
  final String tagline;
  final String url;
  final String copyright;
  final String? logoUrl;
  final String? darkLogoUrl;
  final String? faviconUrl;

  const SiteInfo({
    required this.name,
    required this.title,
    required this.tagline,
    required this.url,
    required this.copyright,
    this.logoUrl,
    this.darkLogoUrl,
    this.faviconUrl,
  });

  factory SiteInfo.empty() {
    return const SiteInfo(
      name: '',
      title: '',
      tagline: '',
      url: '',
      copyright: '',
    );
  }

  bool get isEmpty => name.isEmpty && title.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String symbolPosition;
  final int decimalPlaces;
  final double exchangeRate;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.symbolPosition,
    required this.decimalPlaces,
    required this.exchangeRate,
  });

  factory CurrencyInfo.empty() {
    return const CurrencyInfo(
      code: 'USD',
      symbol: '\$',
      symbolPosition: 'before_price',
      decimalPlaces: 2,
      exchangeRate: 1.0,
    );
  }

  bool get isEmpty => code.isEmpty && symbol.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Helper method to format currency
  String formatCurrency(double amount) {
    final formattedAmount = amount.toStringAsFixed(decimalPlaces);
    if (symbolPosition == 'before_price') {
      return '$symbol$formattedAmount';
    } else {
      return '$formattedAmount$symbol';
    }
  }
}
