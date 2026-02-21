import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod_clean_architecture/features/payment/domain/entities/payment_account_entity.dart';

part 'payment_account_model.g.dart';

@JsonSerializable()
class PaymentAccountModel extends Equatable {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'bank_account_no')
  final String bankAccountNo;
  @JsonKey(name: 'bank_holder_name')
  final String bankHolderName;
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'paypal_email')
  final String paypalEmail;
  final String swift;
  final String? ifsc;
  @JsonKey(name: 'is_default')
  final int isDefault;
  final int status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  const PaymentAccountModel({
    required this.id,
    required this.userId,
    required this.bankAccountNo,
    required this.bankHolderName,
    required this.bankName,
    required this.paypalEmail,
    required this.swift,
    this.ifsc,
    this.isDefault = 0,
    this.status = 1,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory PaymentAccountModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentAccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAccountModelToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    bankAccountNo,
    bankHolderName,
    bankName,
    paypalEmail,
    swift,
    ifsc,
    isDefault,
    status,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

extension PaymentAccountModelExtension on PaymentAccountModel {
  PaymentAccountEntity toEntity() {
    return PaymentAccountEntity(
      id: id,
      userId: userId,
      bankAccountNo: bankAccountNo,
      bankHolderName: bankHolderName,
      bankName: bankName,
      paypalEmail: paypalEmail,
      swift: swift,
      ifsc: ifsc,
      isDefault: isDefault,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

@JsonSerializable()
class PaymentAccountRequestModel extends Equatable {
  @JsonKey(name: 'bank_account_no')
  final String bankAccountNo;
  @JsonKey(name: 'bank_holder_name')
  final String bankHolderName;
  @JsonKey(name: 'bank_name')
  final String bankName;
  @JsonKey(name: 'paypal_email')
  final String paypalEmail;
  final String swift;
  final String? ifsc;

  const PaymentAccountRequestModel({
    required this.bankAccountNo,
    required this.bankHolderName,
    required this.bankName,
    required this.paypalEmail,
    required this.swift,
    this.ifsc,
  });

  factory PaymentAccountRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentAccountRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAccountRequestModelToJson(this);

  @override
  List<Object?> get props => [
    bankAccountNo,
    bankHolderName,
    bankName,
    paypalEmail,
    swift,
    ifsc,
  ];
}
