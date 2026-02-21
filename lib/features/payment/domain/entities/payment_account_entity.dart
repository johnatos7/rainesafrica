import 'package:equatable/equatable.dart';

class PaymentAccountEntity extends Equatable {
  final int id;
  final int userId;
  final String bankAccountNo;
  final String bankHolderName;
  final String bankName;
  final String paypalEmail;
  final String swift;
  final String? ifsc;
  final int isDefault;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const PaymentAccountEntity({
    required this.id,
    required this.userId,
    required this.bankAccountNo,
    required this.bankHolderName,
    required this.bankName,
    required this.paypalEmail,
    required this.swift,
    this.ifsc,
    required this.isDefault,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

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
