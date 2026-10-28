import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database database;

  final ticket = TicketModel(
    id: 1,
    clientCode: 'CLI-84920',
    clientName: 'Mariana Silveira Ramos',
    reportedCategory: 'Lentidão na navegação',
    problemDescription: 'Vídeos não carregam.',
    clientAddress: 'Rua Fernando Machado, 450',
    neighborhood: 'Centro',
    city: 'Chapecó',
    latitude: -27.100412,
    longitude: -52.615234,
    status: TicketStatus.active,
    createdAt: DateTime(2026, 9, 28, 14, 20),
  );

  ServiceReportModel reportFor(int ticketId) => ServiceReportModel(
    ticketId: ticketId,
    technicalCategory: 'Conector danificado',
    procedureDescription: 'Feita nova conectorização da fibra.',
    resolvedAt: DateTime(2026, 10, 28, 9),
    createdAt: DateTime(2026, 10, 28, 9),
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async => database = await DatabaseHelper.openInMemory());

  tearDown(() async => database.close());

  group('DatabaseHelper', () {
    test('Impede dois atendimentos para o mesmo chamado', () async {
      await database.insert(DatabaseHelper.ticketsTable, ticket.toMap());
      await database.insert(
        DatabaseHelper.serviceReportsTable,
        reportFor(ticket.id).toMap(),
      );

      expect(
        () => database.insert(
          DatabaseHelper.serviceReportsTable,
          reportFor(ticket.id).toMap(),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Impede atendimento de chamado inexistente', () async {
      expect(
        () => database.insert(
          DatabaseHelper.serviceReportsTable,
          reportFor(999).toMap(),
        ),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
