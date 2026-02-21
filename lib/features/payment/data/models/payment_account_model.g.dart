// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentAccountModel _$PaymentAccountModelFromJson(Map<String, dynamic> json) =>
    PaymentAccountModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      bankAccountNo: json['bank_account_no'] as String,
      bankHolderName: json['bank_holder_name'] as String,
      bankName: json['bank_name'] as String,
      paypalEmail: json['paypal_email'] as String,
      swift: json['swift'] as String,
      ifsc: json['ifsc'] as String?,
      isDefault: (json['is_default'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$PaymentAccountModelToJson(
  PaymentAccountModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'bank_account_no': instance.bankAccountNo,
  'bank_holder_name': instance.bankHolderName,
  'bank_name': instance.bankName,
  'paypal_email': instance.paypalEmail,
  'swift': instance.swift,
  'ifsc': instance.ifsc,
  'is_default': instance.isDefault,
  'status': instance.status,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'deleted_at': instance.deletedAt,
};

PaymentAccountRequestModel _$PaymentAccountRequestModelFromJson(
  Map<String, dynamic> json,
) => PaymentAccountRequestModel(
  bankAccountNo: json['bank_account_no'] as String,
  bankHolderName: json['bank_holder_name'] as String,
  bankName: json['bank_name'] as String,
  paypalEmail: json['paypal_email'] as String,
  swift: json['swift'] as String,
  ifsc: json['ifsc'] as String?,
);

Map<String, dynamic> _$PaymentAccountRequestModelToJson(
  PaymentAccountRequestModel instance,
) => <String, dynamic>{
  'bank_account_no': instance.bankAccountNo,
  'bank_holder_name': instance.bankHolderName,
  'bank_name': instance.bankName,
  'paypal_email': instance.paypalEmail,
  'swift': instance.swift,
  'ifsc': instance.ifsc,
};
