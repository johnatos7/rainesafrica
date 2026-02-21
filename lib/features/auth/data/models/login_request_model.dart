import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel extends Equatable {
  final String email;
  final String password;
  final String recaptcha;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.recaptcha = '',
  });

  @override
  List<Object?> get props => [email, password, recaptcha];

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}
