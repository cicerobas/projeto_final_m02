import 'package:projeto_final_m02/data/models/user_model.dart';

class SessionModel {
  final String token;
  final UserModel user;

  const SessionModel({required this.token, required this.user});

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    token: json['token'] as String,
    user: UserModel.fromJson(json['usuario'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {'token': token, 'usuario': user.toJson()};
}
