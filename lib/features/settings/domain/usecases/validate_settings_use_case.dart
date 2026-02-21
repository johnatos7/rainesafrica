import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

class ValidateSettingsUseCase {
  ValidationResult validateSettings(SettingsEntity settings) {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate general settings
    _validateGeneralSettings(settings.general, errors, warnings);

    // Validate delivery settings
    _validateDeliverySettings(settings.delivery, errors, warnings);

    // Validate payment methods
    _validatePaymentMethods(settings.paymentMethods, errors, warnings);

    // Validate analytics settings
    _validateAnalyticsSettings(settings.analytics, errors, warnings);

    // Validate activation settings
    _validateActivationSettings(settings.activation, errors, warnings);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  void _validateGeneralSettings(
    GeneralSettingsEntity general,
    List<String> errors,
    List<String> warnings,
  ) {
    if (general.siteName.isEmpty) {
      errors.add('Site name is required');
    }

    if (general.siteTitle.isEmpty) {
      errors.add('Site title is required');
    }

    if (general.siteUrl.isEmpty) {
      errors.add('Site URL is required');
    } else if (!_isValidUrl(general.siteUrl)) {
      errors.add('Site URL is not valid');
    }

    if (general.defaultCurrency.code.isEmpty) {
      errors.add('Default currency code is required');
    }

    if (general.defaultCurrency.symbol.isEmpty) {
      errors.add('Default currency symbol is required');
    }

    if (general.minOrderAmount.isEmpty) {
      warnings.add('Minimum order amount is not set');
    } else {
      final minAmount = double.tryParse(general.minOrderAmount);
      if (minAmount == null || minAmount < 0) {
        errors.add('Minimum order amount must be a valid positive number');
      }
    }

    if (general.minOrderFreeShipping < 0) {
      errors.add('Minimum order for free shipping cannot be negative');
    }
  }

  void _validateDeliverySettings(
    DeliverySettingsEntity delivery,
    List<String> errors,
    List<String> warnings,
  ) {
    if (delivery.shippingOptions.isEmpty) {
      errors.add('At least one shipping option is required');
    }

    for (int i = 0; i < delivery.shippingOptions.length; i++) {
      final option = delivery.shippingOptions[i];
      if (option.title.isEmpty) {
        errors.add('Shipping option ${i + 1} title is required');
      }

      if (option.description.isEmpty) {
        warnings.add('Shipping option ${i + 1} description is missing');
      }

      if (option.price < 0) {
        errors.add('Shipping option ${i + 1} price cannot be negative');
      }
    }

    if (delivery.sameDayDelivery && delivery.sameDayIntervals.isEmpty) {
      warnings.add(
        'Same day delivery is enabled but no intervals are configured',
      );
    }
  }

  void _validatePaymentMethods(
    List<PaymentMethodEntity> paymentMethods,
    List<String> errors,
    List<String> warnings,
  ) {
    if (paymentMethods.isEmpty) {
      errors.add('At least one payment method is required');
    }

    final enabledMethods =
        paymentMethods.where((method) => method.isEnabled).toList();
    if (enabledMethods.isEmpty) {
      errors.add('At least one payment method must be enabled');
    }

    for (int i = 0; i < paymentMethods.length; i++) {
      final method = paymentMethods[i];
      if (method.name.isEmpty) {
        errors.add('Payment method ${i + 1} name is required');
      }

      if (method.title.isEmpty) {
        errors.add('Payment method ${i + 1} title is required');
      }
    }
  }

  void _validateAnalyticsSettings(
    AnalyticsSettingsEntity analytics,
    List<String> errors,
    List<String> warnings,
  ) {
    if (analytics.facebookPixelStatus.isNotEmpty &&
        !analytics.facebookPixelStatus.contains('on')) {
      warnings.add('Facebook Pixel is configured but not enabled');
    }

    if (analytics.googleMeasurementId != null &&
        analytics.googleMeasurementId!.isEmpty) {
      warnings.add('Google Analytics measurement ID is empty');
    }
  }

  void _validateActivationSettings(
    ActivationSettingsEntity activation,
    List<String> errors,
    List<String> warnings,
  ) {
    if (activation.walletEnable && !activation.pointEnable) {
      warnings.add(
        'Wallet is enabled but points are disabled - this may cause issues',
      );
    }

    if (activation.couponEnable && !activation.pointEnable) {
      warnings.add(
        'Coupons are enabled but points are disabled - this may cause issues',
      );
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;

  String get errorSummary => errors.join('\n');
  String get warningSummary => warnings.join('\n');

  String get fullSummary {
    final parts = <String>[];
    if (hasErrors) {
      parts.add('Errors:\n${errorSummary}');
    }
    if (hasWarnings) {
      parts.add('Warnings:\n${warningSummary}');
    }
    return parts.join('\n\n');
  }
}

// Provider
final validateSettingsUseCaseProvider = Provider<ValidateSettingsUseCase>((
  ref,
) {
  return ValidateSettingsUseCase();
});
