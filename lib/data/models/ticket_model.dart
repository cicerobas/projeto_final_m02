import 'package:projeto_final_m02/core/utils/json_parser.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

class TicketModel {
  final int id;
  final String clientCode;
  final String clientName;
  final String reportedCategory;
  final String problemDescription;
  final String clientAddress;
  final String neighborhood;
  final String city;
  final double latitude;
  final double longitude;
  final TicketStatus status;
  final DateTime createdAt;
  final double? distanceKm;

  const TicketModel({
    required this.id,
    required this.clientCode,
    required this.clientName,
    required this.reportedCategory,
    required this.problemDescription,
    required this.clientAddress,
    required this.neighborhood,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.distanceKm,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: JsonParser.toInt(json['id']),
    clientCode: json['codigo_cliente'] as String,
    clientName: json['nome_cliente'] as String,
    reportedCategory: json['categoria_informada'] as String,
    problemDescription: json['descricao_problema'] as String,
    clientAddress: json['endereco_cliente'] as String,
    neighborhood: json['bairro'] as String,
    city: json['cidade'] as String,
    latitude: JsonParser.toDouble(json['latitude']),
    longitude: JsonParser.toDouble(json['longitude']),
    status: TicketStatus.fromApiValue(json['status'] as String),
    createdAt: DateTime.parse(json['criado_em'] as String),
  );

  factory TicketModel.fromMap(Map<String, dynamic> map) => TicketModel(
    id: map['id'] as int,
    clientCode: map['client_code'] as String,
    clientName: map['client_name'] as String,
    reportedCategory: map['reported_category'] as String,
    problemDescription: map['problem_description'] as String,
    clientAddress: map['client_address'] as String,
    neighborhood: map['neighborhood'] as String,
    city: map['city'] as String,
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
    status: TicketStatus.fromApiValue(map['status'] as String),
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  String get fullAddress => '$clientAddress - $neighborhood, $city';

  TicketModel withDistance(double distanceKm) => TicketModel(
    id: id,
    clientCode: clientCode,
    clientName: clientName,
    reportedCategory: reportedCategory,
    problemDescription: problemDescription,
    clientAddress: clientAddress,
    neighborhood: neighborhood,
    city: city,
    latitude: latitude,
    longitude: longitude,
    status: status,
    createdAt: createdAt,
    distanceKm: distanceKm,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'client_code': clientCode,
    'client_name': clientName,
    'reported_category': reportedCategory,
    'problem_description': problemDescription,
    'client_address': clientAddress,
    'neighborhood': neighborhood,
    'city': city,
    'latitude': latitude,
    'longitude': longitude,
    'status': status.apiValue,
    'created_at': createdAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketModel &&
          other.id == id &&
          other.clientCode == clientCode &&
          other.clientName == clientName &&
          other.reportedCategory == reportedCategory &&
          other.problemDescription == problemDescription &&
          other.clientAddress == clientAddress &&
          other.neighborhood == neighborhood &&
          other.city == city &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.status == status &&
          other.createdAt == createdAt &&
          other.distanceKm == distanceKm;

  @override
  int get hashCode => Object.hash(
    id,
    clientCode,
    clientName,
    reportedCategory,
    problemDescription,
    clientAddress,
    neighborhood,
    city,
    latitude,
    longitude,
    status,
    createdAt,
    distanceKm,
  );
}
