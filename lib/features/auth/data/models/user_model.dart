import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/data/models/address_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/address/domain/entities/address_entity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'user_model.g.dart';

// Helper functions for country code conversion
int? _countryCodeFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

dynamic _countryCodeToJson(int? value) => value;

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? countryCode;
  final int? phone;
  final int? profileImageId;
  final int systemReserve;
  final int status;
  final int? createdById;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final int ordersCount;
  final UserRole? role;
  final List<UserPermission>? permission;
  final dynamic store;
  final dynamic profileImage;
  final UserPoint? point;
  final UserWallet? wallet;
  final List<AddressModel> address;
  final dynamic vendorWallet;
  final dynamic paymentAccount;

  const UserModel({
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // LOG USER MODEL CREATION
    print('🔵 USER MODEL: ===== USER MODEL FROM JSON START =====');
    print('🔵 USER MODEL: Input JSON: $json');
    print('🔵 USER MODEL: JSON keys: ${json.keys.toList()}');
    print('🔵 USER MODEL: ID: ${json['id']} (type: ${json['id'].runtimeType})');
    print(
      '🔵 USER MODEL: Name: ${json['name']} (type: ${json['name'].runtimeType})',
    );
    print(
      '🔵 USER MODEL: Email: ${json['email']} (type: ${json['email'].runtimeType})',
    );
    print(
      '🔵 USER MODEL: Role: ${json['role']} (type: ${json['role'].runtimeType})',
    );
    print(
      '🔵 USER MODEL: Permission: ${json['permission']} (type: ${json['permission'].runtimeType})',
    );
    print(
      '🔵 USER MODEL: Address: ${json['address']} (type: ${json['address'].runtimeType})',
    );
    print(
      '🔵 USER MODEL: Point: ${json['point']} (type: ${json['point'].runtimeType})',
    );
    print(
      '🔵 USER MODEL: Wallet: ${json['wallet']} (type: ${json['wallet'].runtimeType})',
    );
    print('🔵 USER MODEL: ===== USER MODEL FROM JSON END =====');

    try {
      final userModel = _$UserModelFromJson(json);
      print('🔵 USER MODEL: UserModel created successfully');
      print('🔵 USER MODEL: UserModel ID: ${userModel.id}');
      print('🔵 USER MODEL: UserModel Name: ${userModel.name}');
      print('🔵 USER MODEL: UserModel Email: ${userModel.email}');
      print(
        '🔵 USER MODEL: UserModel Address Count: ${userModel.address.length}',
      );
      return userModel;
    } catch (e, stackTrace) {
      print('🔴 USER MODEL: Error creating UserModel: $e');
      print('🔴 USER MODEL: Error type: ${e.runtimeType}');
      print('🔴 USER MODEL: Stack trace: $stackTrace');
      print('🔴 USER MODEL: JSON that caused error: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Factory constructor to convert UserEntity to UserModel
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: int.tryParse(entity.id) ?? 0,
      name: entity.name,
      email: entity.email,
      countryCode: entity.countryCode,
      phone: entity.phone != null ? int.tryParse(entity.phone!) : null,
      profileImageId: entity.profileImageId,
      systemReserve: entity.systemReserve,
      status: entity.status,
      createdById: entity.createdById,
      emailVerifiedAt: entity.emailVerifiedAt,
      createdAt: entity.createdAt,
      ordersCount: entity.ordersCount,
      role:
          entity.role != null
              ? UserRole(
                id: entity.role!.id,
                name: entity.role!.name,
                guardName: entity.role!.guardName,
                systemReserve: entity.role!.systemReserve,
              )
              : null,
      permission:
          entity.permission
              ?.map(
                (p) => UserPermission(
                  id: p.id,
                  name: p.name,
                  guardName: p.guardName,
                  createdAt: p.createdAt,
                  updatedAt: p.updatedAt,
                  pivot: UserPermissionPivot(
                    roleId: p.pivot.roleId,
                    permissionId: p.pivot.permissionId,
                  ),
                ),
              )
              .toList(),
      store: entity.store,
      profileImage: entity.profileImage,
      point:
          entity.point != null
              ? UserPoint(
                id: entity.point!.id,
                consumerId: entity.point!.consumerId,
                balance: entity.point!.balance,
              )
              : null,
      wallet:
          entity.wallet != null
              ? UserWallet(
                id: entity.wallet!.id,
                consumerId: entity.wallet!.consumerId,
                balance: entity.wallet!.balance,
              )
              : null,
      address: entity.address.map((addr) => addr as AddressModel).toList(),
      vendorWallet: entity.vendorWallet,
      paymentAccount: entity.paymentAccount,
    );
  }
}

// Extension to convert UserModel to UserEntity
extension UserModelX on UserModel {
  UserEntity toEntity() {
    return UserEntity(
      id: id.toString(),
      name: name,
      email: email,
      countryCode: countryCode,
      phone: phone?.toString(),
      profileImageId: profileImageId,
      systemReserve: systemReserve,
      status: status,
      createdById: createdById,
      emailVerifiedAt: emailVerifiedAt,
      createdAt: createdAt,
      ordersCount: ordersCount,
      role:
          role != null
              ? UserRoleEntity(
                id: role!.id,
                name: role!.name,
                guardName: role!.guardName,
                systemReserve: role!.systemReserve,
              )
              : null,
      permission:
          permission
              ?.map(
                (p) => UserPermissionEntity(
                  id: p.id,
                  name: p.name,
                  guardName: p.guardName,
                  createdAt: p.createdAt,
                  updatedAt: p.updatedAt,
                  pivot: UserPermissionPivotEntity(
                    roleId: p.pivot.roleId,
                    permissionId: p.pivot.permissionId,
                  ),
                ),
              )
              .toList(),
      store: store,
      profileImage: profileImage,
      point:
          point != null
              ? UserPointEntity(
                id: point!.id,
                consumerId: point!.consumerId,
                balance: point!.balance,
              )
              : null,
      wallet:
          wallet != null
              ? UserWalletEntity(
                id: wallet!.id,
                consumerId: wallet!.consumerId,
                balance: wallet!.balance,
              )
              : null,
      address: address.map((addr) => addr as AddressEntity).toList(),
      vendorWallet: vendorWallet,
      paymentAccount: paymentAccount,
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserRole extends Equatable {
  final int id;
  final String name;
  final String guardName;
  final int systemReserve;

  const UserRole({
    required this.id,
    required this.name,
    required this.guardName,
    required this.systemReserve,
  });

  @override
  List<Object?> get props => [id, name, guardName, systemReserve];

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
  Map<String, dynamic> toJson() => _$UserRoleToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserPermission extends Equatable {
  final int id;
  final String name;
  final String guardName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPermissionPivot pivot;

  const UserPermission({
    required this.id,
    required this.name,
    required this.guardName,
    required this.createdAt,
    required this.updatedAt,
    required this.pivot,
  });

  @override
  List<Object?> get props => [id, name, guardName, createdAt, updatedAt, pivot];

  factory UserPermission.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionFromJson(json);
  Map<String, dynamic> toJson() => _$UserPermissionToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserPermissionPivot extends Equatable {
  final int roleId;
  final int permissionId;

  const UserPermissionPivot({required this.roleId, required this.permissionId});

  @override
  List<Object?> get props => [roleId, permissionId];

  factory UserPermissionPivot.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionPivotFromJson(json);
  Map<String, dynamic> toJson() => _$UserPermissionPivotToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserPoint extends Equatable {
  final int id;
  final int consumerId;
  final double balance;

  const UserPoint({
    required this.id,
    required this.consumerId,
    required this.balance,
  });

  @override
  List<Object?> get props => [id, consumerId, balance];

  factory UserPoint.fromJson(Map<String, dynamic> json) =>
      _$UserPointFromJson(json);
  Map<String, dynamic> toJson() => _$UserPointToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UserWallet extends Equatable {
  final int id;
  final int consumerId;
  final double balance;

  const UserWallet({
    required this.id,
    required this.consumerId,
    required this.balance,
  });

  @override
  List<Object?> get props => [id, consumerId, balance];

  factory UserWallet.fromJson(Map<String, dynamic> json) =>
      _$UserWalletFromJson(json);
  Map<String, dynamic> toJson() => _$UserWalletToJson(this);
}
