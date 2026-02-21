import 'package:equatable/equatable.dart';

// Helper function for phone number conversion
int _phoneFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

class AddressEntity extends Equatable {
  final int id;
  final String title;
  final int userId;
  final String street;
  final String city;
  final String? pincode;
  final int isDefault;
  final String countryCode;
  final int phone;
  final int countryId;
  final int stateId;
  final CountryEntity? country;
  final StateEntity? state;

  const AddressEntity({
    required this.id,
    required this.title,
    required this.userId,
    required this.street,
    required this.city,
    this.pincode,
    required this.isDefault,
    required this.countryCode,
    required this.phone,
    required this.countryId,
    required this.stateId,
    this.country,
    this.state,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    userId,
    street,
    city,
    pincode,
    isDefault,
    countryCode,
    phone,
    countryId,
    stateId,
    country,
    state,
  ];

  // Helper methods
  bool get isDefaultAddress => isDefault == 1;

  String get fullAddress {
    final parts = <String>[];
    parts.add(street);
    parts.add(city);
    if (pincode != null && pincode!.isNotEmpty) {
      parts.add(pincode!);
    }
    if (state != null) {
      parts.add(state!.name);
    }
    if (country != null) {
      parts.add(country!.name);
    }
    return parts.join(', ');
  }

  String get shortAddress {
    final parts = <String>[];
    parts.add(city);
    if (state != null) {
      parts.add(state!.name);
    }
    return parts.join(', ');
  }

  // Factory constructor to create an empty address
  factory AddressEntity.empty() {
    return const AddressEntity(
      id: 0,
      title: '',
      userId: 0,
      street: '',
      city: '',
      isDefault: 0,
      countryCode: '',
      phone: 0,
      countryId: 0,
      stateId: 0,
    );
  }

  // Factory constructor from JSON
  factory AddressEntity.fromJson(Map<String, dynamic> json) {
    return AddressEntity(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      userId: json['user_id'] as int? ?? 0,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      pincode: json['pincode'] as String?,
      isDefault: json['is_default'] as int? ?? 0,
      countryCode: json['country_code'] as String? ?? '',
      phone: _phoneFromJson(json['phone']),
      countryId: json['country_id'] as int? ?? 0,
      stateId: json['state_id'] as int? ?? 0,
      country:
          json['country'] != null
              ? CountryEntity.fromJson(json['country'] as Map<String, dynamic>)
              : null,
      state:
          json['state'] != null
              ? StateEntity.fromJson(json['state'] as Map<String, dynamic>)
              : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'street': street,
      'city': city,
      'pincode': pincode,
      'is_default': isDefault,
      'country_code': countryCode,
      'phone': phone,
      'country_id': countryId,
      'state_id': stateId,
      'country': country?.toJson(),
      'state': state?.toJson(),
    };
  }

  // CopyWith method for creating a new instance with some updated properties
  AddressEntity copyWith({
    int? id,
    String? title,
    int? userId,
    String? street,
    String? city,
    String? pincode,
    int? isDefault,
    String? countryCode,
    int? phone,
    int? countryId,
    int? stateId,
    CountryEntity? country,
    StateEntity? state,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      country: country ?? this.country,
      state: state ?? this.state,
    );
  }
}

class CountryEntity extends Equatable {
  final int id;
  final String name;
  final String? currency;
  final String? currencySymbol;
  final String? iso31662;
  final String? iso31663;
  final String? callingCode;
  final String? flag;
  final List<StateEntity> states;

  const CountryEntity({
    required this.id,
    required this.name,
    this.currency,
    this.currencySymbol,
    this.iso31662,
    this.iso31663,
    this.callingCode,
    this.flag,
    this.states = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    currency,
    currencySymbol,
    iso31662,
    iso31663,
    callingCode,
    flag,
    states,
  ];

  factory CountryEntity.empty() {
    return const CountryEntity(id: 0, name: '');
  }

  factory CountryEntity.fromJson(Map<String, dynamic> json) {
    return CountryEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      currency: json['currency'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      iso31662: json['iso_3166_2'] as String?,
      iso31663: json['iso_3166_3'] as String?,
      callingCode: json['calling_code'] as String?,
      flag: json['flag'] as String?,
      states:
          (json['state'] as List<dynamic>?)
              ?.map((e) => StateEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'iso_3166_2': iso31662,
      'iso_3166_3': iso31663,
      'calling_code': callingCode,
      'flag': flag,
      'state': states.map((state) => state.toJson()).toList(),
    };
  }

  bool get isEmpty => name.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class StateEntity extends Equatable {
  final int id;
  final String name;
  final int countryId;

  const StateEntity({
    required this.id,
    required this.name,
    required this.countryId,
  });

  @override
  List<Object?> get props => [id, name, countryId];

  factory StateEntity.empty() {
    return const StateEntity(id: 0, name: '', countryId: 0);
  }

  factory StateEntity.fromJson(Map<String, dynamic> json) {
    return StateEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      countryId: json['country_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'country_id': countryId};
  }

  bool get isEmpty => name.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

// Address form data for creating/updating addresses
class AddressFormData extends Equatable {
  final String title;
  final String street;
  final String city;
  final String? pincode;
  final String countryCode;
  final String phone;
  final int countryId;
  final int stateId;
  final int? type; // Optional type field

  const AddressFormData({
    required this.title,
    required this.street,
    required this.city,
    this.pincode,
    required this.countryCode,
    required this.phone,
    required this.countryId,
    required this.stateId,
    this.type,
  });

  @override
  List<Object?> get props => [
    title,
    street,
    city,
    pincode,
    countryCode,
    phone,
    countryId,
    stateId,
    type,
  ];

  factory AddressFormData.empty() {
    return const AddressFormData(
      title: '',
      street: '',
      city: '',
      countryCode: '',
      phone: '',
      countryId: 0,
      stateId: 0,
    );
  }

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'street': street,
      'city': city,
      'pincode': pincode,
      'country_id': countryId,
      'state_id': stateId,
      'phone': phone,
      'type': type,
      'country_code': countryCode,
    };
  }

  // Create from existing address
  factory AddressFormData.fromAddress(AddressEntity address) {
    return AddressFormData(
      title: address.title,
      street: address.street,
      city: address.city,
      pincode: address.pincode,
      countryCode: address.countryCode,
      phone: address.phone.toString(),
      countryId: address.countryId,
      stateId: address.stateId,
    );
  }

  // CopyWith method for creating a new instance with some updated properties
  AddressFormData copyWith({
    String? title,
    String? street,
    String? city,
    String? pincode,
    String? countryCode,
    String? phone,
    int? countryId,
    int? stateId,
    int? type,
  }) {
    return AddressFormData(
      title: title ?? this.title,
      street: street ?? this.street,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      countryId: countryId ?? this.countryId,
      stateId: stateId ?? this.stateId,
      type: type ?? this.type,
    );
  }

  // Validation
  bool get isValid {
    return title.isNotEmpty &&
        street.isNotEmpty &&
        city.isNotEmpty &&
        countryCode.isNotEmpty &&
        phone.isNotEmpty &&
        countryId > 0 &&
        stateId > 0;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    if (title.isEmpty) errors.add('Title is required');
    if (street.isEmpty) errors.add('Street address is required');
    if (city.isEmpty) errors.add('City is required');
    if (countryCode.isEmpty) errors.add('Country code is required');
    if (phone.isEmpty) errors.add('Phone number is required');
    if (countryId <= 0) errors.add('Country must be selected');
    if (stateId <= 0) errors.add('State must be selected');
    return errors;
  }
}
