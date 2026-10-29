import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';

abstract interface class TicketRemoteDatasource {
  Future<List<TicketModel>> getActiveTickets();
}

class TicketRemoteDatasourceImpl implements TicketRemoteDatasource {
  final AppClient _client;

  const TicketRemoteDatasourceImpl(this._client);

  @override
  Future<List<TicketModel>> getActiveTickets() async {
    final json = await _client.get(ApiEndpoints.tickets);
    final items = (json['dados'] as List<dynamic>).cast<Map<String, dynamic>>();

    return items.map(TicketModel.fromJson).toList();
  }
}
