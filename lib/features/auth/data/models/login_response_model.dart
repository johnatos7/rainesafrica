import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel extends Equatable {
  @JsonKey(name: 'access_token')
  final String accessToken;
  final bool success;
  final String? message;

  const LoginResponseModel({
    required this.accessToken,
    required this.success,
    this.message,
  });

  @override
  List<Object?> get props => [accessToken, success, message];

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
