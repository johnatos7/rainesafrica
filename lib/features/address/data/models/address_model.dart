import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';

// Helper function for phone number conversion
int _phoneFromJson(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is num) return value.toInt();
  return 0;
}

class AddressModel extends AddressEntity {
  AddressModel({
    required super.id,
    required super.title,
    required super.userId,
    required super.street,
    required super.city,
    super.pincode,
    required super.isDefault,
    required super.countryCode,
    required super.phone,
    required super.countryId,
    required super.stateId,
    super.country,
    super.state,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Debug logging to see what the API is returning
    print('=== DEBUG: AddressModel.fromJson ===');
    print('Raw JSON response: $json');
    print('id: ${json['id']} (type: ${json['id'].runtimeType})');
    print('user_id: ${json['user_id']} (type: ${json['user_id'].runtimeType})');
    print(
      'is_default: ${json['is_default']} (type: ${json['is_default'].runtimeType})',
    );
    print(
      'country_id: ${json['country_id']} (type: ${json['country_id'].runtimeType})',
    );
    print(
      'state_id: ${json['state_id']} (type: ${json['state_id'].runtimeType})',
    );
    print('phone: ${json['phone']} (type: ${json['phone'].runtimeType})');
    print('=====================================');

    return AddressModel(
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
              ? CountryModel.fromJson(json['country'] as Map<String, dynamic>)
              : null,
      state:
          json['state'] != null
              ? StateModel.fromJson(json['state'] as Map<String, dynamic>)
              : null,
    );
  }

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
      'country': country != null ? (country as CountryModel).toJson() : null,
      'state': state != null ? (state as StateModel).toJson() : null,
    };
  }
}

class CountryModel extends CountryEntity {
  CountryModel({
    required super.id,
    required super.name,
    super.currency,
    super.currencySymbol,
    super.iso31662,
    super.iso31663,
    super.callingCode,
    super.flag,
    super.states = const [],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final states =
        (json['state'] as List<dynamic>?)
            ?.map((e) => StateModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return CountryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      currency: json['currency'] as String?,
      currencySymbol: json['currency_symbol'] as String?,
      iso31662: json['iso_3166_2'] as String?,
      iso31663: json['iso_3166_3'] as String?,
      callingCode: json['calling_code'] as String?,
      flag: json['flag'] as String?,
      states: states,
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
      'state': states.map((e) => (e as StateModel).toJson()).toList(),
    };
  }
}

class StateModel extends StateEntity {
  StateModel({
    required super.id,
    required super.name,
    required super.countryId,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      countryId: json['country_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'country_id': countryId};
  }
}
