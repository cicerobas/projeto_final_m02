import 'package:projeto_final_m02/core/utils/json_parser.dart';

class UserModel {
  final int id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: JsonParser.toInt(json['id']), name: json['nome'] as String, email: json['email'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'nome': name, 'email': email};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.id == id && other.name == name && other.email == email;

  @override
  int get hashCode => Object.hash(id, name, email);
}
