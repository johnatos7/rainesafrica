import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final GeneralSettingsEntity general;
  final DeliverySettingsEntity delivery;
  final AnalyticsSettingsEntity analytics;
  final ActivationSettingsEntity activation;
  final MaintenanceSettingsEntity maintenance;
  final WalletPointsSettingsEntity walletPoints;
  final GoogleRecaptchaSettingsEntity googleRecaptcha;
  final List<PaymentMethodEntity> paymentMethods;

  const SettingsEntity({
    required this.general,
    required this.delivery,
    required this.analytics,
    required this.activation,
    required this.maintenance,
    required this.walletPoints,
    required this.googleRecaptcha,
    required this.paymentMethods,
  });

  @override
  List<Object?> get props => [
    general,
    delivery,
    analytics,
    activation,
    maintenance,
    walletPoints,
    googleRecaptcha,
    paymentMethods,
  ];

  // Factory constructor to create an empty settings
  factory SettingsEntity.empty() {
    return SettingsEntity(
      general: GeneralSettingsEntity.empty(),
      delivery: DeliverySettingsEntity.empty(),
      analytics: AnalyticsSettingsEntity.empty(),
      activation: ActivationSettingsEntity.empty(),
      maintenance: MaintenanceSettingsEntity.empty(),
      walletPoints: WalletPointsSettingsEntity.empty(),
      googleRecaptcha: GoogleRecaptchaSettingsEntity.empty(),
      paymentMethods: [],
    );
  }

  // CopyWith method for creating a new instance with some updated properties
  SettingsEntity copyWith({
    GeneralSettingsEntity? general,
    DeliverySettingsEntity? delivery,
    AnalyticsSettingsEntity? analytics,
    ActivationSettingsEntity? activation,
    MaintenanceSettingsEntity? maintenance,
    WalletPointsSettingsEntity? walletPoints,
    GoogleRecaptchaSettingsEntity? googleRecaptcha,
    List<PaymentMethodEntity>? paymentMethods,
  }) {
    return SettingsEntity(
      general: general ?? this.general,
      delivery: delivery ?? this.delivery,
      analytics: analytics ?? this.analytics,
      activation: activation ?? this.activation,
      maintenance: maintenance ?? this.maintenance,
      walletPoints: walletPoints ?? this.walletPoints,
      googleRecaptcha: googleRecaptcha ?? this.googleRecaptcha,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }

  // Method to check if settings is empty
  bool get isEmpty => general.isEmpty && delivery.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class GeneralSettingsEntity extends Equatable {
  final String mode;
  final String siteUrl;
  final String copyright;
  final String siteName;
  final String siteTitle;
  final String siteTagline;
  final CurrencyEntity defaultCurrency;
  final String defaultTimezone;
  final String? faviconImageId;
  final String minOrderAmount;
  final String? darkLogoImageId;
  final String? faviconImageUuid;
  final String productSkuPrefix;
  final String? tinyLogoImageId;
  final int defaultCurrencyId;
  final String? lightLogoImageId;
  final String? darkLogoImageUuid;
  final String? tinyLogoImageUuid;
  final String? lightLogoImageUuid;
  final double minOrderFreeShipping;
  final String adminSiteLanguageDirection;
  final ImageAssetEntity? lightLogoImage;
  final ImageAssetEntity? darkLogoImage;
  final ImageAssetEntity? faviconImage;
  final ImageAssetEntity? tinyLogoImage;

  const GeneralSettingsEntity({
    required this.mode,
    required this.siteUrl,
    required this.copyright,
    required this.siteName,
    required this.siteTitle,
    required this.siteTagline,
    required this.defaultCurrency,
    required this.defaultTimezone,
    this.faviconImageId,
    required this.minOrderAmount,
    this.darkLogoImageId,
    this.faviconImageUuid,
    required this.productSkuPrefix,
    this.tinyLogoImageId,
    required this.defaultCurrencyId,
    this.lightLogoImageId,
    this.darkLogoImageUuid,
    this.tinyLogoImageUuid,
    this.lightLogoImageUuid,
    required this.minOrderFreeShipping,
    required this.adminSiteLanguageDirection,
    this.lightLogoImage,
    this.darkLogoImage,
    this.faviconImage,
    this.tinyLogoImage,
  });

  @override
  List<Object?> get props => [
    mode,
    siteUrl,
    copyright,
    siteName,
    siteTitle,
    siteTagline,
    defaultCurrency,
    defaultTimezone,
    faviconImageId,
    minOrderAmount,
    darkLogoImageId,
    faviconImageUuid,
    productSkuPrefix,
    tinyLogoImageId,
    defaultCurrencyId,
    lightLogoImageId,
    darkLogoImageUuid,
    tinyLogoImageUuid,
    lightLogoImageUuid,
    minOrderFreeShipping,
    adminSiteLanguageDirection,
    lightLogoImage,
    darkLogoImage,
    faviconImage,
    tinyLogoImage,
  ];

  factory GeneralSettingsEntity.empty() {
    return GeneralSettingsEntity(
      mode: '',
      siteUrl: '',
      copyright: '',
      siteName: '',
      siteTitle: '',
      siteTagline: '',
      defaultCurrency: CurrencyEntity.empty(),
      defaultTimezone: '',
      minOrderAmount: '',
      productSkuPrefix: '',
      defaultCurrencyId: 0,
      minOrderFreeShipping: 0.0,
      adminSiteLanguageDirection: '',
    );
  }

  bool get isEmpty => siteName.isEmpty && siteTitle.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class CurrencyEntity extends Equatable {
  final int id;
  final String code;
  final String symbol;
  final int noOfDecimal;
  final String exchangeRate;
  final String symbolPosition;
  final String thousandsSeparator;
  final String decimalSeparator;
  final int systemReserve;
  final int status;
  final int? createdById;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const CurrencyEntity({
    required this.id,
    required this.code,
    required this.symbol,
    required this.noOfDecimal,
    required this.exchangeRate,
    required this.symbolPosition,
    required this.thousandsSeparator,
    required this.decimalSeparator,
    required this.systemReserve,
    required this.status,
    this.createdById,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    symbol,
    noOfDecimal,
    exchangeRate,
    symbolPosition,
    thousandsSeparator,
    decimalSeparator,
    systemReserve,
    status,
    createdById,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  factory CurrencyEntity.empty() {
    return CurrencyEntity(
      id: 0,
      code: '',
      symbol: '',
      noOfDecimal: 0,
      exchangeRate: '',
      symbolPosition: '',
      thousandsSeparator: '',
      decimalSeparator: '',
      systemReserve: 0,
      status: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  bool get isEmpty => code.isEmpty && symbol.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class ImageAssetEntity extends Equatable {
  final int id;
  final String imageUrl;
  final String? uuid;
  final String? name;
  final String fileName;
  final String disk;
  final int createdById;
  final DateTime createdAt;
  final String originalUrl;
  final String? takealotUrl;

  const ImageAssetEntity({
    required this.id,
    required this.imageUrl,
    required this.uuid,
    required this.name,
    required this.fileName,
    required this.disk,
    required this.createdById,
    required this.createdAt,
    required this.originalUrl,
    this.takealotUrl,
  });

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    uuid,
    name,
    fileName,
    disk,
    createdById,
    createdAt,
    originalUrl,
    takealotUrl,
  ];

  factory ImageAssetEntity.empty() {
    return ImageAssetEntity(
      id: 0,
      imageUrl: '',
      uuid: null,
      name: null,
      fileName: '',
      disk: '',
      createdById: 0,
      createdAt: DateTime.now(),
      originalUrl: '',
    );
  }

  bool get isEmpty => imageUrl.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class DeliverySettingsEntity extends Equatable {
  final DeliveryOptionEntity defaultOption;
  final DeliveryOptionEntity sameDay;
  final int defaultDelivery;
  final List<ShippingOptionEntity> shippingOptions;
  final bool sameDayDelivery;
  final List<DeliveryIntervalEntity> sameDayIntervals;

  const DeliverySettingsEntity({
    required this.defaultOption,
    required this.sameDay,
    required this.defaultDelivery,
    required this.shippingOptions,
    required this.sameDayDelivery,
    required this.sameDayIntervals,
  });

  @override
  List<Object?> get props => [
    defaultOption,
    sameDay,
    defaultDelivery,
    shippingOptions,
    sameDayDelivery,
    sameDayIntervals,
  ];

  factory DeliverySettingsEntity.empty() {
    return DeliverySettingsEntity(
      defaultOption: DeliveryOptionEntity.empty(),
      sameDay: DeliveryOptionEntity.empty(),
      defaultDelivery: 0,
      shippingOptions: [],
      sameDayDelivery: false,
      sameDayIntervals: [],
    );
  }

  bool get isEmpty => shippingOptions.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class DeliveryOptionEntity extends Equatable {
  final String title;
  final String description;

  const DeliveryOptionEntity({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];

  factory DeliveryOptionEntity.empty() {
    return DeliveryOptionEntity(title: '', description: '');
  }

  bool get isEmpty => title.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class ShippingOptionEntity extends Equatable {
  final double price;
  final String title;
  final String description;

  const ShippingOptionEntity({
    required this.price,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [price, title, description];

  factory ShippingOptionEntity.empty() {
    return ShippingOptionEntity(price: 0.0, title: '', description: '');
  }

  bool get isEmpty => title.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class DeliveryIntervalEntity extends Equatable {
  final String title;
  final String description;

  const DeliveryIntervalEntity({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];

  factory DeliveryIntervalEntity.empty() {
    return DeliveryIntervalEntity(title: '', description: '');
  }

  bool get isEmpty => title.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class AnalyticsSettingsEntity extends Equatable {
  final List<String> facebookPixelStatus;
  final String? googleMeasurementId;

  const AnalyticsSettingsEntity({
    required this.facebookPixelStatus,
    this.googleMeasurementId,
  });

  @override
  List<Object?> get props => [facebookPixelStatus, googleMeasurementId];

  factory AnalyticsSettingsEntity.empty() {
    return AnalyticsSettingsEntity(facebookPixelStatus: []);
  }

  bool get isEmpty =>
      facebookPixelStatus.isEmpty && googleMeasurementId == null;
  bool get isNotEmpty => !isEmpty;
}

class ActivationSettingsEntity extends Equatable {
  final bool multivendor;
  final bool pointEnable;
  final bool couponEnable;
  final bool walletEnable;
  final bool stockProductHide;
  final bool storeAutoApprove;
  final bool productAutoApprove;

  const ActivationSettingsEntity({
    required this.multivendor,
    required this.pointEnable,
    required this.couponEnable,
    required this.walletEnable,
    required this.stockProductHide,
    required this.storeAutoApprove,
    required this.productAutoApprove,
  });

  @override
  List<Object?> get props => [
    multivendor,
    pointEnable,
    couponEnable,
    walletEnable,
    stockProductHide,
    storeAutoApprove,
    productAutoApprove,
  ];

  factory ActivationSettingsEntity.empty() {
    return const ActivationSettingsEntity(
      multivendor: false,
      pointEnable: false,
      couponEnable: false,
      walletEnable: false,
      stockProductHide: false,
      storeAutoApprove: false,
      productAutoApprove: false,
    );
  }

  bool get isEmpty => !multivendor && !pointEnable && !couponEnable;
  bool get isNotEmpty => !isEmpty;
}

class MaintenanceSettingsEntity extends Equatable {
  final String title;
  final String description;
  final bool maintenanceMode;
  final String? maintenanceImageId;
  final String? maintenanceImageUuid;
  final ImageAssetEntity? maintenanceImage;

  const MaintenanceSettingsEntity({
    required this.title,
    required this.description,
    required this.maintenanceMode,
    this.maintenanceImageId,
    this.maintenanceImageUuid,
    this.maintenanceImage,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    maintenanceMode,
    maintenanceImageId,
    maintenanceImageUuid,
    maintenanceImage,
  ];

  factory MaintenanceSettingsEntity.empty() {
    return const MaintenanceSettingsEntity(
      title: '',
      description: '',
      maintenanceMode: false,
    );
  }

  bool get isEmpty => title.isEmpty && description.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class WalletPointsSettingsEntity extends Equatable {
  final int signupPoints;
  final String minPerOrderAmount;
  final String pointCurrencyRatio;
  final double rewardPerOrderAmount;

  const WalletPointsSettingsEntity({
    required this.signupPoints,
    required this.minPerOrderAmount,
    required this.pointCurrencyRatio,
    required this.rewardPerOrderAmount,
  });

  @override
  List<Object?> get props => [
    signupPoints,
    minPerOrderAmount,
    pointCurrencyRatio,
    rewardPerOrderAmount,
  ];

  factory WalletPointsSettingsEntity.empty() {
    return const WalletPointsSettingsEntity(
      signupPoints: 0,
      minPerOrderAmount: '',
      pointCurrencyRatio: '',
      rewardPerOrderAmount: 0.0,
    );
  }

  bool get isEmpty => signupPoints == 0 && minPerOrderAmount.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class GoogleRecaptchaSettingsEntity extends Equatable {
  final String secret;
  final bool status;
  final String siteKey;

  const GoogleRecaptchaSettingsEntity({
    required this.secret,
    required this.status,
    required this.siteKey,
  });

  @override
  List<Object?> get props => [secret, status, siteKey];

  factory GoogleRecaptchaSettingsEntity.empty() {
    return const GoogleRecaptchaSettingsEntity(
      secret: '',
      status: false,
      siteKey: '',
    );
  }

  bool get isEmpty => secret.isEmpty && siteKey.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class PaymentMethodEntity extends Equatable {
  final String name;
  final String title;
  final dynamic status; // can be bool or List<String>

  const PaymentMethodEntity({
    required this.name,
    required this.title,
    required this.status,
  });

  @override
  List<Object?> get props => [name, title, status];

  factory PaymentMethodEntity.empty() {
    return PaymentMethodEntity(name: '', title: '', status: false);
  }

  bool get isEmpty => name.isEmpty && title.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Helper method to check if payment method is enabled
  bool get isEnabled {
    if (status is bool) {
      return status as bool;
    } else if (status is List) {
      return (status as List).contains('on');
    }
    return false;
  }
}
