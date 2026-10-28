import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

import '../../../helpers/model_factories.dart';

void main() {
  late Database database;
  late ServiceReportLocalDatasource datasource;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await DatabaseHelper.openInMemory();
    datasource = ServiceReportLocalDatasourceImpl(database);
    await database.insert(
      DatabaseHelper.ticketsTable,
      buildTicket(id: 1).toMap(),
    );
  });

  tearDown(() async => database.close());

  group('ServiceReportLocalDatasource', () {
    test('salva o atendimento e marca o chamado como resolvido', () async {
      await datasource.saveCompletedReport(buildServiceReport(ticketId: 1));

      final ticketRows = await database.query(DatabaseHelper.ticketsTable);
      expect(ticketRows.single['status'], TicketStatus.resolved.apiValue);
      expect(await datasource.getPendingReports(), hasLength(1));
    });

    test('atendimento sincronizado deixa de ser pendente', () async {
      final id = await datasource.saveCompletedReport(
        buildServiceReport(ticketId: 1),
      );

      await datasource.markAsSynced(
        id,
        remoteId: 14,
        photoUrl: 'https://exemplo.com/foto.jpg',
      );

      expect(await datasource.getPendingReports(), isEmpty);
      final history = await datasource.getHistory();
      expect(history.single.report.remoteId, 14);
      expect(history.single.report.isSynced, isTrue);
    });

    test(
      'mescla o histórico da API sem duplicar o atendimento local',
      () async {
        await datasource.saveCompletedReport(buildServiceReport(ticketId: 1));

        await datasource.saveHistory([
          HistoryEntryModel(
            ticket: buildTicket(id: 1, status: TicketStatus.resolved),
            report: buildServiceReport(
              ticketId: 1,
              remoteId: 14,
              isSynced: true,
            ),
          ),
          HistoryEntryModel(
            ticket: buildTicket(id: 2, status: TicketStatus.resolved),
            report: buildServiceReport(
              ticketId: 2,
              remoteId: 15,
              isSynced: true,
            ),
          ),
        ]);

        final history = await datasource.getHistory();
        expect(history, hasLength(2));
        expect(history.every((entry) => entry.report.isSynced), isTrue);
      },
    );
  });
}
