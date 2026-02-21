// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  countryCode: json['country_code'] as String?,
  phone: (json['phone'] as num?)?.toInt(),
  profileImageId: (json['profile_image_id'] as num?)?.toInt(),
  systemReserve: (json['system_reserve'] as num?)?.toInt() ?? 0,
  status: (json['status'] as num?)?.toInt() ?? 1,
  createdById: (json['created_by_id'] as num?)?.toInt(),
  emailVerifiedAt:
      json['email_verified_at'] == null
          ? null
          : DateTime.parse(json['email_verified_at'] as String),
  createdAt:
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
  ordersCount: (json['orders_count'] as num?)?.toInt() ?? 0,
  role:
      json['role'] == null
          ? null
          : UserRole.fromJson(json['role'] as Map<String, dynamic>),
  permission:
      (json['permission'] as List<dynamic>?)
          ?.map((e) => UserPermission.fromJson(e as Map<String, dynamic>))
          .toList(),
  store: json['store'],
  profileImage: json['profile_image'],
  point:
      json['point'] == null
          ? null
          : UserPoint.fromJson(json['point'] as Map<String, dynamic>),
  wallet:
      json['wallet'] == null
          ? null
          : UserWallet.fromJson(json['wallet'] as Map<String, dynamic>),
  address:
      (json['address'] as List<dynamic>?)
          ?.map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  vendorWallet: json['vendor_wallet'],
  paymentAccount: json['payment_account'],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'country_code': instance.countryCode,
  'phone': instance.phone,
  'profile_image_id': instance.profileImageId,
  'system_reserve': instance.systemReserve,
  'status': instance.status,
  'created_by_id': instance.createdById,
  'email_verified_at': instance.emailVerifiedAt?.toIso8601String(),
  'created_at': instance.createdAt?.toIso8601String(),
  'orders_count': instance.ordersCount,
  'role': instance.role,
  'permission': instance.permission,
  'store': instance.store,
  'profile_image': instance.profileImage,
  'point': instance.point,
  'wallet': instance.wallet,
  'address': instance.address,
  'vendor_wallet': instance.vendorWallet,
  'payment_account': instance.paymentAccount,
};

UserRole _$UserRoleFromJson(Map<String, dynamic> json) => UserRole(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  guardName: json['guard_name'] as String,
  systemReserve: (json['system_reserve'] as num).toInt(),
);

Map<String, dynamic> _$UserRoleToJson(UserRole instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'guard_name': instance.guardName,
  'system_reserve': instance.systemReserve,
};

UserPermission _$UserPermissionFromJson(Map<String, dynamic> json) =>
    UserPermission(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      guardName: json['guard_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pivot: UserPermissionPivot.fromJson(
        json['pivot'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UserPermissionToJson(UserPermission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'guard_name': instance.guardName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'pivot': instance.pivot,
    };

UserPermissionPivot _$UserPermissionPivotFromJson(Map<String, dynamic> json) =>
    UserPermissionPivot(
      roleId: (json['role_id'] as num).toInt(),
      permissionId: (json['permission_id'] as num).toInt(),
    );

Map<String, dynamic> _$UserPermissionPivotToJson(
  UserPermissionPivot instance,
) => <String, dynamic>{
  'role_id': instance.roleId,
  'permission_id': instance.permissionId,
};

UserPoint _$UserPointFromJson(Map<String, dynamic> json) => UserPoint(
  id: (json['id'] as num).toInt(),
  consumerId: (json['consumer_id'] as num).toInt(),
  balance: (json['balance'] as num).toDouble(),
);

Map<String, dynamic> _$UserPointToJson(UserPoint instance) => <String, dynamic>{
  'id': instance.id,
  'consumer_id': instance.consumerId,
  'balance': instance.balance,
};

UserWallet _$UserWalletFromJson(Map<String, dynamic> json) => UserWallet(
  id: (json['id'] as num).toInt(),
  consumerId: (json['consumer_id'] as num).toInt(),
  balance: (json['balance'] as num).toDouble(),
);

Map<String, dynamic> _$UserWalletToJson(UserWallet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consumer_id': instance.consumerId,
      'balance': instance.balance,
    };
