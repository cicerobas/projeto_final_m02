import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/core/utils/json_parser.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';

abstract interface class ServiceReportRemoteDatasource {
  Future<({int remoteId, String? photoUrl})> submitReport(
    ServiceReportModel report,
  );

  Future<List<HistoryEntryModel>> getHistory();
}

class ServiceReportRemoteDatasourceImpl
    implements ServiceReportRemoteDatasource {
  final AppClient _client;

  const ServiceReportRemoteDatasourceImpl(this._client);

  @override
  Future<({int remoteId, String? photoUrl})> submitReport(
    ServiceReportModel report,
  ) async {
    final photoPath = report.photoPath;

    final json = await _client.postMultipart(
      ApiEndpoints.serviceReport,
      fields: report.toApiFields(),
      files: {'foto': ?photoPath},
    );

    final data = json['dados'] as Map<String, dynamic>;
    return (
      remoteId: JsonParser.toInt(data['atendimento_id']),
      photoUrl: data['foto_url'] as String?,
    );
  }

  @override
  Future<List<HistoryEntryModel>> getHistory() async {
    final json = await _client.get(ApiEndpoints.history);
    final items = (json['dados'] as List<dynamic>).cast<Map<String, dynamic>>();

    return items.map(HistoryEntryModel.fromJson).toList();
  }
}
