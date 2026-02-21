import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? countryCode;
  final String? phone;
  final int? profileImageId;
  final int systemReserve;
  final int status;
  final int? createdById;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final int ordersCount;
  final UserRoleEntity? role;
  final List<UserPermissionEntity>? permission;
  final dynamic store;
  final dynamic profileImage;
  final UserPointEntity? point;
  final UserWalletEntity? wallet;
  final List<AddressEntity> address;
  final dynamic vendorWallet;
  final dynamic paymentAccount;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.countryCode,
    this.phone,
    this.profileImageId,
    this.systemReserve = 0,
    this.status = 1,
    this.createdById,
    this.emailVerifiedAt,
    this.createdAt,
    this.ordersCount = 0,
    this.role,
    this.permission,
    this.store,
    this.profileImage,
    this.point,
    this.wallet,
    this.address = const [],
    this.vendorWallet,
    this.paymentAccount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    countryCode,
    phone,
    profileImageId,
    systemReserve,
    status,
    createdById,
    emailVerifiedAt,
    createdAt,
    ordersCount,
    role,
    permission,
    store,
    profileImage,
    point,
    wallet,
    address,
    vendorWallet,
    paymentAccount,
  ];

  // Factory constructor to create an empty user
  factory UserEntity.empty() {
    return const UserEntity(id: '', name: '', email: '');
  }

  // CopyWith method for creating a new instance with some updated properties
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? countryCode,
    String? phone,
    int? profileImageId,
    int? systemReserve,
    int? status,
    int? createdById,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
    int? ordersCount,
    UserRoleEntity? role,
    List<UserPermissionEntity>? permission,
    dynamic store,
    dynamic profileImage,
    UserPointEntity? point,
    UserWalletEntity? wallet,
    List<AddressEntity>? address,
    dynamic vendorWallet,
    dynamic paymentAccount,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      phone: phone ?? this.phone,
      profileImageId: profileImageId ?? this.profileImageId,
      systemReserve: systemReserve ?? this.systemReserve,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      ordersCount: ordersCount ?? this.ordersCount,
      role: role ?? this.role,
      permission: permission ?? this.permission,
      store: store ?? this.store,
      profileImage: profileImage ?? this.profileImage,
      point: point ?? this.point,
      wallet: wallet ?? this.wallet,
      address: address ?? this.address,
      vendorWallet: vendorWallet ?? this.vendorWallet,
      paymentAccount: paymentAccount ?? this.paymentAccount,
    );
  }

  // Method to check if user is empty
  bool get isEmpty => id.isEmpty && name.isEmpty && email.isEmpty;
  bool get isNotEmpty => !isEmpty;

  // Factory constructor to create a UserEntity from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    // LOG USER ENTITY CREATION
    print('🔵 USER ENTITY: ===== USER ENTITY FROM JSON START =====');
    print('🔵 USER ENTITY: Input JSON: $json');
    print('🔵 USER ENTITY: JSON keys: ${json.keys.toList()}');
    print(
      '🔵 USER ENTITY: ID: ${json['id']} (type: ${json['id'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Name: ${json['name']} (type: ${json['name'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Email: ${json['email']} (type: ${json['email'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Role: ${json['role']} (type: ${json['role'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Permission: ${json['permission']} (type: ${json['permission'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Address: ${json['address']} (type: ${json['address'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Point: ${json['point']} (type: ${json['point'].runtimeType})',
    );
    print(
      '🔵 USER ENTITY: Wallet: ${json['wallet']} (type: ${json['wallet'].runtimeType})',
    );
    print('🔵 USER ENTITY: ===== USER ENTITY FROM JSON END =====');

    try {
      return UserEntity(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        countryCode: json['country_code']?.toString() ?? '',
        phone: json['phone']?.toString(),
        profileImageId:
            json['profile_image_id'] != null
                ? int.parse(json['profile_image_id'].toString())
                : null,
        systemReserve:
            json['system_reserve'] != null
                ? int.parse(json['system_reserve'].toString())
                : 0,
        status:
            json['status'] != null ? int.parse(json['status'].toString()) : 1,
        createdById:
            json['created_by_id'] != null
                ? int.parse(json['created_by_id'].toString())
                : null,
        emailVerifiedAt:
            json['email_verified_at'] != null
                ? DateTime.parse(json['email_verified_at'].toString())
                : null,
        createdAt:
            json['created_at'] != null
                ? DateTime.parse(json['created_at'].toString())
                : null,
        ordersCount:
            json['orders_count'] != null
                ? int.parse(json['orders_count'].toString())
                : 0,
        role:
            json['role'] != null
                ? UserRoleEntity(
                  id: int.parse(json['role']['id'].toString()),
                  name: json['role']['name'].toString(),
                  guardName: json['role']['guard_name'].toString(),
                  systemReserve: int.parse(
                    json['role']['system_reserve'].toString(),
                  ),
                )
                : null,
        permission:
            json['permission'] != null
                ? (json['permission'] as List)
                    .map(
                      (p) => UserPermissionEntity(
                        id: int.parse(p['id'].toString()),
                        name: p['name'].toString(),
                        guardName: p['guard_name'].toString(),
                        createdAt: DateTime.parse(p['created_at'].toString()),
                        updatedAt: DateTime.parse(p['updated_at'].toString()),
                        pivot: UserPermissionPivotEntity(
                          roleId: int.parse(p['pivot']['role_id'].toString()),
                          permissionId: int.parse(
                            p['pivot']['permission_id'].toString(),
                          ),
                        ),
                      ),
                    )
                    .toList()
                : null,
        store: json['store'],
        profileImage: json['profile_image'],
        point:
            json['point'] != null
                ? UserPointEntity(
                  id: int.parse(json['point']['id'].toString()),
                  consumerId: int.parse(
                    json['point']['consumer_id'].toString(),
                  ),
                  balance: double.parse(json['point']['balance'].toString()),
                )
                : null,
        wallet:
            json['wallet'] != null
                ? UserWalletEntity(
                  id: int.parse(json['wallet']['id'].toString()),
                  consumerId: int.parse(
                    json['wallet']['consumer_id'].toString(),
                  ),
                  balance: double.parse(json['wallet']['balance'].toString()),
                )
                : null,
        address:
            (json['address'] as List<dynamic>?)
                ?.map((e) => AddressEntity.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        vendorWallet: json['vendor_wallet'],
        paymentAccount: json['payment_account'],
      );
    } catch (e) {
      print('🔴 USER ENTITY: Error creating UserEntity: $e');
      print('🔴 USER ENTITY: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Convert UserEntity to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'country_code': countryCode,
      'phone': phone,
      'profile_image_id': profileImageId,
      'system_reserve': systemReserve,
      'status': status,
      'created_by_id': createdById,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'orders_count': ordersCount,
      'role':
          role != null
              ? {
                'id': role!.id,
                'name': role!.name,
                'guard_name': role!.guardName,
                'system_reserve': role!.systemReserve,
              }
              : null,
      'permission':
          permission
              ?.map(
                (p) => {
                  'id': p.id,
                  'name': p.name,
                  'guard_name': p.guardName,
                  'created_at': p.createdAt.toIso8601String(),
                  'updated_at': p.updatedAt.toIso8601String(),
                  'pivot': {
                    'role_id': p.pivot.roleId,
                    'permission_id': p.pivot.permissionId,
                  },
                },
              )
              .toList(),
      'store': store,
      'profile_image': profileImage,
      'point':
          point != null
              ? {
                'id': point!.id,
                'consumer_id': point!.consumerId,
                'balance': point!.balance,
              }
              : null,
      'wallet':
          wallet != null
              ? {
                'id': wallet!.id,
                'consumer_id': wallet!.consumerId,
                'balance': wallet!.balance,
              }
              : null,
      'address': address,
      'vendor_wallet': vendorWallet,
      'payment_account': paymentAccount,
    };
  }
}

class UserRoleEntity extends Equatable {
  final int id;
  final String name;
  final String guardName;
  final int systemReserve;

  const UserRoleEntity({
    required this.id,
    required this.name,
    required this.guardName,
    required this.systemReserve,
  });

  @override
  List<Object?> get props => [id, name, guardName, systemReserve];
}

class UserPermissionEntity extends Equatable {
  final int id;
  final String name;
  final String guardName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPermissionPivotEntity pivot;

  const UserPermissionEntity({
    required this.id,
    required this.name,
    required this.guardName,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  @override
  List<Object?> get props => [id, name, guardName, createdAt, updatedAt, pivot];
}

class UserPermissionPivotEntity extends Equatable {
  final int roleId;
  final int permissionId;

  const UserPermissionPivotEntity({
    required this.roleId,
    required this.permissionId,
  });

  @override
  List<Object?> get props => [roleId, permissionId];
}

class UserPointEntity extends Equatable {
  final int id;
  final int consumerId;
  final double balance;

  const UserPointEntity({
    required this.id,
    required this.consumerId,
    required this.balance,
  });

  @override
  List<Object?> get props => [id, consumerId, balance];
}

class UserWalletEntity extends Equatable {
  final int id;
  final int consumerId;
  final double balance;

  const UserWalletEntity({
    required this.id,
    required this.consumerId,
    required this.balance,
  });

  @override
  List<Object?> get props => [id, consumerId, balance];
}
