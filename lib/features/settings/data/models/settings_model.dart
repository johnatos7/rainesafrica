import 'package:flutter_riverpod_clean_architecture/features/settings/domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  SettingsModel({
    required super.general,
    required super.delivery,
    required super.analytics,
    required super.activation,
    required super.maintenance,
    required super.walletPoints,
    required super.googleRecaptcha,
    required super.paymentMethods,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    final values = json['values'] as Map<String, dynamic>;
    return SettingsModel(
      general: GeneralSettingsModel.fromJson(
        values['general'] as Map<String, dynamic>,
      ),
      delivery: DeliverySettingsModel.fromJson(
        values['delivery'] as Map<String, dynamic>,
      ),
      analytics: AnalyticsSettingsModel.fromJson(
        values['analytics'] as Map<String, dynamic>,
      ),
      activation: ActivationSettingsModel.fromJson(
        values['activation'] as Map<String, dynamic>,
      ),
      maintenance: MaintenanceSettingsModel.fromJson(
        values['maintenance'] as Map<String, dynamic>,
      ),
      walletPoints: WalletPointsSettingsModel.fromJson(
        values['wallet_points'] as Map<String, dynamic>,
      ),
      googleRecaptcha: GoogleRecaptchaSettingsModel.fromJson(
        values['google_reCaptcha'] as Map<String, dynamic>,
      ),
      paymentMethods:
          (values['payment_methods'] as List<dynamic>)
              .map(
                (e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'values': {
        'general': (general as GeneralSettingsModel).toJson(),
        'delivery': (delivery as DeliverySettingsModel).toJson(),
        'analytics': (analytics as AnalyticsSettingsModel).toJson(),
        'activation': (activation as ActivationSettingsModel).toJson(),
        'maintenance': (maintenance as MaintenanceSettingsModel).toJson(),
        'wallet_points': (walletPoints as WalletPointsSettingsModel).toJson(),
        'google_reCaptcha':
            (googleRecaptcha as GoogleRecaptchaSettingsModel).toJson(),
        'payment_methods':
            paymentMethods
                .map((e) => (e as PaymentMethodModel).toJson())
                .toList(),
      },
    };
  }
}

class GeneralSettingsModel extends GeneralSettingsEntity {
  GeneralSettingsModel({
    required super.mode,
    required super.siteUrl,
    required super.copyright,
    required super.siteName,
    required super.siteTitle,
    required super.siteTagline,
    required super.defaultCurrency,
    required super.defaultTimezone,
    super.faviconImageId,
    required super.minOrderAmount,
    super.darkLogoImageId,
    super.faviconImageUuid,
    required super.productSkuPrefix,
    super.tinyLogoImageId,
    required super.defaultCurrencyId,
    super.lightLogoImageId,
    super.darkLogoImageUuid,
    super.tinyLogoImageUuid,
    super.lightLogoImageUuid,
    required super.minOrderFreeShipping,
    required super.adminSiteLanguageDirection,
    super.lightLogoImage,
    super.darkLogoImage,
    super.faviconImage,
    super.tinyLogoImage,
  });

  factory GeneralSettingsModel.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsModel(
      mode: json['mode'] as String,
      siteUrl: json['site_url'] as String,
      copyright: json['copyright'] as String,
      siteName: json['site_name'] as String,
      siteTitle: json['site_title'] as String,
      siteTagline: json['site_tagline'] as String,
      defaultCurrency: CurrencyModel.fromJson(
        json['default_currency'] as Map<String, dynamic>,
      ),
      defaultTimezone: json['default_timezone'] as String,
      faviconImageId: json['favicon_image_id'] as String?,
      minOrderAmount: json['min_order_amount'] as String,
      darkLogoImageId: json['dark_logo_image_id'] as String?,
      faviconImageUuid: json['favicon_image_uuid'] as String?,
      productSkuPrefix: json['product_sku_prefix'] as String,
      tinyLogoImageId: json['tiny_logo_image_id'] as String?,
      defaultCurrencyId: (json['default_currency_id'] as num).toInt(),
      lightLogoImageId: json['light_logo_image_id'] as String?,
      darkLogoImageUuid: json['dark_logo_image_uuid'] as String?,
      tinyLogoImageUuid: json['tiny_logo_image_uuid'] as String?,
      lightLogoImageUuid: json['light_logo_image_uuid'] as String?,
      minOrderFreeShipping: (json['min_order_free_shipping'] as num).toDouble(),
      adminSiteLanguageDirection:
          json['admin_site_language_direction'] as String,
      lightLogoImage:
          json['light_logo_image'] == null
              ? null
              : ImageAssetModel.fromJson(
                json['light_logo_image'] as Map<String, dynamic>,
              ),
      darkLogoImage:
          json['dark_logo_image'] == null
              ? null
              : ImageAssetModel.fromJson(
                json['dark_logo_image'] as Map<String, dynamic>,
              ),
      faviconImage:
          json['favicon_image'] == null
              ? null
              : ImageAssetModel.fromJson(
                json['favicon_image'] as Map<String, dynamic>,
              ),
      tinyLogoImage:
          json['tiny_logo_image'] == null
              ? null
              : ImageAssetModel.fromJson(
                json['tiny_logo_image'] as Map<String, dynamic>,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'site_url': siteUrl,
      'copyright': copyright,
      'site_name': siteName,
      'site_title': siteTitle,
      'site_tagline': siteTagline,
      'default_currency': (defaultCurrency as CurrencyModel).toJson(),
      'default_timezone': defaultTimezone,
      'favicon_image_id': faviconImageId,
      'min_order_amount': minOrderAmount,
      'dark_logo_image_id': darkLogoImageId,
      'favicon_image_uuid': faviconImageUuid,
      'product_sku_prefix': productSkuPrefix,
      'tiny_logo_image_id': tinyLogoImageId,
      'default_currency_id': defaultCurrencyId,
      'light_logo_image_id': lightLogoImageId,
      'dark_logo_image_uuid': darkLogoImageUuid,
      'tiny_logo_image_uuid': tinyLogoImageUuid,
      'light_logo_image_uuid': lightLogoImageUuid,
      'min_order_free_shipping': minOrderFreeShipping,
      'admin_site_language_direction': adminSiteLanguageDirection,
      'light_logo_image':
          lightLogoImage != null
              ? (lightLogoImage as ImageAssetModel).toJson()
              : null,
      'dark_logo_image':
          darkLogoImage != null
              ? (darkLogoImage as ImageAssetModel).toJson()
              : null,
      'favicon_image':
          faviconImage != null
              ? (faviconImage as ImageAssetModel).toJson()
              : null,
      'tiny_logo_image':
          tinyLogoImage != null
              ? (tinyLogoImage as ImageAssetModel).toJson()
              : null,
    };
  }
}

class CurrencyModel extends CurrencyEntity {
  CurrencyModel({
    required super.id,
    required super.code,
    required super.symbol,
    required super.noOfDecimal,
    required super.exchangeRate,
    required super.symbolPosition,
    required super.thousandsSeparator,
    required super.decimalSeparator,
    required super.systemReserve,
    required super.status,
    super.createdById,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      noOfDecimal: (json['no_of_decimal'] as num).toInt(),
      exchangeRate: json['exchange_rate'] as String,
      symbolPosition: json['symbol_position'] as String,
      thousandsSeparator: json['thousands_separator'] as String,
      decimalSeparator: json['decimal_separator'] as String,
      systemReserve: (json['system_reserve'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      createdById:
          json['created_by_id'] != null
              ? (json['created_by_id'] as num).toInt()
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt:
          json['deleted_at'] != null
              ? DateTime.parse(json['deleted_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'symbol': symbol,
      'no_of_decimal': noOfDecimal,
      'exchange_rate': exchangeRate,
      'symbol_position': symbolPosition,
      'thousands_separator': thousandsSeparator,
      'decimal_separator': decimalSeparator,
      'system_reserve': systemReserve,
      'status': status,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}

class ImageAssetModel extends ImageAssetEntity {
  ImageAssetModel({
    required super.id,
    required super.imageUrl,
    required super.uuid,
    required super.name,
    required super.fileName,
    required super.disk,
    required super.createdById,
    required super.createdAt,
    required super.originalUrl,
    super.takealotUrl,
  });

  factory ImageAssetModel.fromJson(Map<String, dynamic> json) {
    return ImageAssetModel(
      id: (json['id'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      uuid: json['uuid'] as String?,
      name: json['name'] as String?,
      fileName: json['file_name'] as String,
      disk: json['disk'] as String,
      createdById: (json['created_by_id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      originalUrl: json['original_url'] as String,
      takealotUrl: json['takealot_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'uuid': uuid,
      'name': name,
      'file_name': fileName,
      'disk': disk,
      'created_by_id': createdById,
      'created_at': createdAt.toIso8601String(),
      'original_url': originalUrl,
      'takealot_url': takealotUrl,
    };
  }
}

class DeliverySettingsModel extends DeliverySettingsEntity {
  DeliverySettingsModel({
    required super.defaultOption,
    required super.sameDay,
    required super.defaultDelivery,
    required super.shippingOptions,
    required super.sameDayDelivery,
    required super.sameDayIntervals,
  });

  factory DeliverySettingsModel.fromJson(Map<String, dynamic> json) {
    return DeliverySettingsModel(
      defaultOption: DeliveryOptionModel.fromJson(
        json['default'] as Map<String, dynamic>,
      ),
      sameDay: DeliveryOptionModel.fromJson(
        json['same_day'] as Map<String, dynamic>,
      ),
      defaultDelivery: (json['default_delivery'] as num).toInt(),
      shippingOptions:
          (json['shipping_options'] as List<dynamic>)
              .map(
                (e) => ShippingOptionModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      sameDayDelivery: json['same_day_delivery'] as bool,
      sameDayIntervals:
          (json['same_day_intervals'] as List<dynamic>)
              .map(
                (e) =>
                    DeliveryIntervalModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default': (defaultOption as DeliveryOptionModel).toJson(),
      'same_day': (sameDay as DeliveryOptionModel).toJson(),
      'default_delivery': defaultDelivery,
      'shipping_options':
          shippingOptions
              .map((e) => (e as ShippingOptionModel).toJson())
              .toList(),
      'same_day_delivery': sameDayDelivery,
      'same_day_intervals':
          sameDayIntervals
              .map((e) => (e as DeliveryIntervalModel).toJson())
              .toList(),
    };
  }
}

class DeliveryOptionModel extends DeliveryOptionEntity {
  DeliveryOptionModel({required super.title, required super.description});

  factory DeliveryOptionModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOptionModel(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}

class ShippingOptionModel extends ShippingOptionEntity {
  ShippingOptionModel({
    required super.price,
    required super.title,
    required super.description,
  });

  factory ShippingOptionModel.fromJson(Map<String, dynamic> json) {
    return ShippingOptionModel(
      price: (json['price'] as num).toDouble(),
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'price': price, 'title': title, 'description': description};
  }
}

class DeliveryIntervalModel extends DeliveryIntervalEntity {
  DeliveryIntervalModel({required super.title, required super.description});

  factory DeliveryIntervalModel.fromJson(Map<String, dynamic> json) {
    return DeliveryIntervalModel(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}

class AnalyticsSettingsModel extends AnalyticsSettingsEntity {
  AnalyticsSettingsModel({
    required super.facebookPixelStatus,
    super.googleMeasurementId,
  });

  factory AnalyticsSettingsModel.fromJson(Map<String, dynamic> json) {
    final fb =
        (json['facebook_pixel'] as Map<String, dynamic>)['status']
            as List<dynamic>;
    final ga = json['google_analytics'] as Map<String, dynamic>;
    return AnalyticsSettingsModel(
      facebookPixelStatus: fb.map((e) => e.toString()).toList(),
      googleMeasurementId: ga['measurement_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'facebook_pixel': {'status': facebookPixelStatus},
      'google_analytics': {'measurement_id': googleMeasurementId},
    };
  }
}

class ActivationSettingsModel extends ActivationSettingsEntity {
  ActivationSettingsModel({
    required super.multivendor,
    required super.pointEnable,
    required super.couponEnable,
    required super.walletEnable,
    required super.stockProductHide,
    required super.storeAutoApprove,
    required super.productAutoApprove,
  });

  factory ActivationSettingsModel.fromJson(Map<String, dynamic> json) {
    return ActivationSettingsModel(
      multivendor: json['multivendor'] as bool,
      pointEnable: json['point_enable'] as bool,
      couponEnable: json['coupon_enable'] as bool,
      walletEnable: json['wallet_enable'] as bool,
      stockProductHide: json['stock_product_hide'] as bool,
      storeAutoApprove: json['store_auto_approve'] as bool,
      productAutoApprove: json['product_auto_approve'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'multivendor': multivendor,
      'point_enable': pointEnable,
      'coupon_enable': couponEnable,
      'wallet_enable': walletEnable,
      'stock_product_hide': stockProductHide,
      'store_auto_approve': storeAutoApprove,
      'product_auto_approve': productAutoApprove,
    };
  }
}

class MaintenanceSettingsModel extends MaintenanceSettingsEntity {
  MaintenanceSettingsModel({
    required super.title,
    required super.description,
    required super.maintenanceMode,
    super.maintenanceImageId,
    super.maintenanceImageUuid,
    super.maintenanceImage,
  });

  factory MaintenanceSettingsModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceSettingsModel(
      title: json['title'] as String,
      description: json['description'] as String,
      maintenanceMode: json['maintenance_mode'] as bool,
      maintenanceImageId: json['maintenance_image_id'] as String?,
      maintenanceImageUuid: json['maintenance_image_uuid'] as String?,
      maintenanceImage:
          json['maintenance_image'] == null
              ? null
              : ImageAssetModel.fromJson(
                json['maintenance_image'] as Map<String, dynamic>,
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'maintenance_mode': maintenanceMode,
      'maintenance_image_id': maintenanceImageId,
      'maintenance_image_uuid': maintenanceImageUuid,
      'maintenance_image':
          maintenanceImage != null
              ? (maintenanceImage as ImageAssetModel).toJson()
              : null,
    };
  }
}

class WalletPointsSettingsModel extends WalletPointsSettingsEntity {
  WalletPointsSettingsModel({
    required super.signupPoints,
    required super.minPerOrderAmount,
    required super.pointCurrencyRatio,
    required super.rewardPerOrderAmount,
  });

  factory WalletPointsSettingsModel.fromJson(Map<String, dynamic> json) {
    return WalletPointsSettingsModel(
      signupPoints: (json['signup_points'] as num).toInt(),
      minPerOrderAmount: json['min_per_order_amount'] as String,
      pointCurrencyRatio: json['point_currency_ratio'] as String,
      rewardPerOrderAmount: (json['reward_per_order_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signup_points': signupPoints,
      'min_per_order_amount': minPerOrderAmount,
      'point_currency_ratio': pointCurrencyRatio,
      'reward_per_order_amount': rewardPerOrderAmount,
    };
  }
}

class GoogleRecaptchaSettingsModel extends GoogleRecaptchaSettingsEntity {
  GoogleRecaptchaSettingsModel({
    required super.secret,
    required super.status,
    required super.siteKey,
  });

  factory GoogleRecaptchaSettingsModel.fromJson(Map<String, dynamic> json) {
    return GoogleRecaptchaSettingsModel(
      secret: json['secret'] as String,
      status: json['status'] as bool,
      siteKey: json['site_key'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'secret': secret, 'status': status, 'site_key': siteKey};
  }
}

class PaymentMethodModel extends PaymentMethodEntity {
  PaymentMethodModel({
    required super.name,
    required super.title,
    required super.status,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      name: json['name'] as String,
      title: json['title'] as String,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'title': title, 'status': status};
  }
}
