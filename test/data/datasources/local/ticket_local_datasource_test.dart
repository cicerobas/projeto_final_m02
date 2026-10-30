import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

import '../../../helpers/model_factories.dart';

void main() {
  late Database database;
  late TicketLocalDatasource datasource;

  Future<void> resolveTicketLocally(int id) => database.update(
    DatabaseHelper.ticketsTable,
    {'status': TicketStatus.resolved.apiValue},
    where: 'id = ?',
    whereArgs: [id],
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    database = await DatabaseHelper.openInMemory();
    datasource = TicketLocalDatasourceImpl(database);
  });

  tearDown(() async => database.close());

  group('TicketLocalDatasource', () {
    test('Salva os chamados e retorna apenas os ativos', () async {
      await datasource.saveTickets([buildTicket(id: 1), buildTicket(id: 2)]);
      await resolveTicketLocally(2);

      final activeTickets = await datasource.getActiveTickets();

      expect(activeTickets.map((ticket) => ticket.id), [1]);
    });

    test(
      'Recarregar os chamados não reativa um chamado resolvido localmente',
      () async {
        await datasource.saveTickets([buildTicket(id: 1)]);
        await resolveTicketLocally(1);

        await datasource.saveTickets([
          buildTicket(id: 1, clientName: 'Nome atualizado'),
        ]);

        final rows = await database.query(DatabaseHelper.ticketsTable);
        expect(rows.single['status'], TicketStatus.resolved.apiValue);
        expect(rows.single['client_name'], 'Nome atualizado');
      },
    );

    test('Remove chamados ativos que não vieram mais da API', () async {
      await datasource.saveTickets([buildTicket(id: 1), buildTicket(id: 2)]);

      await datasource.saveTickets([buildTicket(id: 2)]);

      final activeTickets = await datasource.getActiveTickets();
      expect(activeTickets.map((ticket) => ticket.id), [2]);
    });
  });
}
