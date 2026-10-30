import 'package:intl/intl.dart';
import 'package:projeto_final_m02/core/utils/json_parser.dart';

enum SyncStatus { synced, pending, failed }

class ServiceReportModel {
  static final _apiDateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  final int? id;
  final int? remoteId;
  final int ticketId;
  final String technicalCategory;
  final String procedureDescription;
  final DateTime resolvedAt;
  final String? photoPath;
  final String? photoUrl;
  final bool isSynced;
  final String? syncError;
  final DateTime createdAt;

  const ServiceReportModel({
    this.id,
    this.remoteId,
    required this.ticketId,
    required this.technicalCategory,
    required this.procedureDescription,
    required this.resolvedAt,
    this.photoPath,
    this.photoUrl,
    this.isSynced = false,
    this.syncError,
    required this.createdAt,
  });

  factory ServiceReportModel.fromMap(Map<String, dynamic> map) =>
      ServiceReportModel(
        id: map['id'] as int?,
        remoteId: map['remote_id'] as int?,
        ticketId: map['ticket_id'] as int,
        technicalCategory: map['technical_category'] as String,
        procedureDescription: map['procedure_description'] as String,
        resolvedAt: DateTime.parse(map['resolved_at'] as String),
        photoPath: map['photo_path'] as String?,
        photoUrl: map['photo_url'] as String?,
        isSynced: map['is_synced'] == 1,
        syncError: map['sync_error'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  factory ServiceReportModel.fromHistoryJson(
    Map<String, dynamic> json, {
    required int ticketId,
  }) => ServiceReportModel(
    remoteId: JsonParser.toInt(json['id']),
    ticketId: ticketId,
    technicalCategory: json['categoria_tecnico'] as String,
    procedureDescription: json['descricao_procedimento'] as String,
    resolvedAt: DateTime.parse(json['data_resolucao'] as String),
    photoUrl: json['foto_url'] as String?,
    isSynced: true,
    createdAt: DateTime.parse(json['registrado_em'] as String),
  );

  bool get hasPhoto => photoPath != null || photoUrl != null;

  SyncStatus get syncStatus {
    if (isSynced) return SyncStatus.synced;
    return syncError == null ? SyncStatus.pending : SyncStatus.failed;
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'remote_id': remoteId,
    'ticket_id': ticketId,
    'technical_category': technicalCategory,
    'procedure_description': procedureDescription,
    'resolved_at': resolvedAt.toIso8601String(),
    'photo_path': photoPath,
    'photo_url': photoUrl,
    'is_synced': isSynced ? 1 : 0,
    'sync_error': syncError,
    'created_at': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toApiFields() => {
    'chamado_id': ticketId,
    'categoria_tecnico': technicalCategory,
    'descricao_procedimento': procedureDescription,
    'data_resolucao': _apiDateFormat.format(resolvedAt),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceReportModel &&
          other.id == id &&
          other.remoteId == remoteId &&
          other.ticketId == ticketId &&
          other.technicalCategory == technicalCategory &&
          other.procedureDescription == procedureDescription &&
          other.resolvedAt == resolvedAt &&
          other.photoPath == photoPath &&
          other.photoUrl == photoUrl &&
          other.isSynced == isSynced &&
          other.syncError == syncError &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    ticketId,
    technicalCategory,
    procedureDescription,
    resolvedAt,
    photoPath,
    photoUrl,
    isSynced,
    syncError,
    createdAt,
  );
}
