import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class TicketLocalDatasource {
  Future<void> saveTickets(List<TicketModel> tickets);

  Future<List<TicketModel>> getActiveTickets();
}

class TicketLocalDatasourceImpl implements TicketLocalDatasource {
  final Database _database;

  const TicketLocalDatasourceImpl(this._database);

  @override
  Future<void> saveTickets(List<TicketModel> tickets) async {
    await _database.transaction((txn) async {
      for (final ticket in tickets) {
        final updatedRows = await txn.update(
          DatabaseHelper.ticketsTable,
          ticket.toMap()
            ..remove('id')
            ..remove('status'),
          where: 'id = ?',
          whereArgs: [ticket.id],
        );

        if (updatedRows == 0) {
          await txn.insert(DatabaseHelper.ticketsTable, ticket.toMap());
        }
      }

      await _deleteMissingActiveTickets(
        txn,
        tickets.map((ticket) => ticket.id).toList(),
      );
    });
  }

  @override
  Future<List<TicketModel>> getActiveTickets() async {
    final rows = await _database.query(
      DatabaseHelper.ticketsTable,
      where: 'status = ?',
      whereArgs: [TicketStatus.active.apiValue],
    );

    return rows.map(TicketModel.fromMap).toList();
  }

  Future<void> _deleteMissingActiveTickets(Transaction txn, List<int> keptIds) {
    return txn.delete(
      DatabaseHelper.ticketsTable,
      where: keptIds.isEmpty
          ? 'status = ?'
          : 'status = ? AND id NOT IN (${DatabaseHelper.placeholders(keptIds.length)})',
      whereArgs: [TicketStatus.active.apiValue, ...keptIds],
    );
  }
}
