import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

TicketModel buildTicket({
  int id = 1,
  TicketStatus status = TicketStatus.active,
  String clientName = 'Mariana Silveira Ramos',
  double latitude = -27.100412,
  double longitude = -52.615234,
}) => TicketModel(
  id: id,
  clientCode: 'CLI-$id',
  clientName: clientName,
  reportedCategory: 'Lentidão na navegação',
  problemDescription: 'Vídeos não carregam.',
  clientAddress: 'Rua Fernando Machado, 450',
  neighborhood: 'Centro',
  city: 'Chapecó',
  latitude: latitude,
  longitude: longitude,
  status: status,
  createdAt: DateTime(2026, 9, 28, 14, 20),
);

ServiceReportModel buildServiceReport({int ticketId = 1, int? remoteId, bool isSynced = false, String? photoPath}) =>
    ServiceReportModel(
      ticketId: ticketId,
      remoteId: remoteId,
      technicalCategory: 'Conector danificado',
      procedureDescription: 'Feita nova conectorização da fibra.',
      resolvedAt: DateTime(2026, 10, 28, 9),
      photoPath: photoPath,
      isSynced: isSynced,
      createdAt: DateTime(2026, 10, 28, 9),
    );
