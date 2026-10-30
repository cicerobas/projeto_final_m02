import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';

class HistoryEntryModel {
  final TicketModel ticket;
  final ServiceReportModel report;

  const HistoryEntryModel({required this.ticket, required this.report});

  factory HistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final ticket = TicketModel.fromJson({
      ...json,
      'id': json['chamado_id'] ?? json['id'],
      'status': json['status_chamado'] ?? json['status'],
      'criado_em': json['chamado_criado_em'] ?? json['criado_em'],
    });

    return HistoryEntryModel(
      ticket: ticket,
      report: ServiceReportModel.fromHistoryJson(
        json['atendimento'] as Map<String, dynamic>,
        ticketId: ticket.id,
      ),
    );
  }
}
