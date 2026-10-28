import 'package:sqflite/sqflite.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

abstract interface class ServiceReportLocalDatasource {
  Future<int> saveCompletedReport(ServiceReportModel report);

  Future<List<ServiceReportModel>> getPendingReports();

  Future<void> markAsSynced(int id, {required int remoteId, String? photoUrl});

  Future<void> markAsFailed(int id, String error);

  Future<void> saveHistory(List<HistoryEntryModel> entries);

  Future<List<HistoryEntryModel>> getHistory();
}

class ServiceReportLocalDatasourceImpl implements ServiceReportLocalDatasource {
  final Database _database;

  const ServiceReportLocalDatasourceImpl(this._database);

  @override
  Future<int> saveCompletedReport(ServiceReportModel report) {
    return _database.transaction((txn) async {
      final id = await txn.insert(
        DatabaseHelper.serviceReportsTable,
        report.toMap(),
      );

      await txn.update(
        DatabaseHelper.ticketsTable,
        {'status': TicketStatus.resolved.apiValue},
        where: 'id = ?',
        whereArgs: [report.ticketId],
      );

      return id;
    });
  }

  @override
  Future<List<ServiceReportModel>> getPendingReports() async {
    final rows = await _database.query(
      DatabaseHelper.serviceReportsTable,
      where: 'is_synced = 0 AND sync_error IS NULL',
      orderBy: 'created_at',
    );

    return rows.map(ServiceReportModel.fromMap).toList();
  }

  @override
  Future<void> markAsSynced(int id, {required int remoteId, String? photoUrl}) {
    return _database.update(
      DatabaseHelper.serviceReportsTable,
      {
        'remote_id': remoteId,
        'photo_url': photoUrl,
        'is_synced': 1,
        'sync_error': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markAsFailed(int id, String error) {
    return _database.update(
      DatabaseHelper.serviceReportsTable,
      {'sync_error': error},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> saveHistory(List<HistoryEntryModel> entries) async {
    await _database.transaction((txn) async {
      for (final entry in entries) {
        final updatedTickets = await txn.update(
          DatabaseHelper.ticketsTable,
          entry.ticket.toMap()..remove('id'),
          where: 'id = ?',
          whereArgs: [entry.ticket.id],
        );

        if (updatedTickets == 0) {
          await txn.insert(DatabaseHelper.ticketsTable, entry.ticket.toMap());
        }

        final updatedReports = await txn.update(
          DatabaseHelper.serviceReportsTable,
          {
            'remote_id': entry.report.remoteId,
            'photo_url': entry.report.photoUrl,
            'is_synced': 1,
            'sync_error': null,
          },
          where: 'ticket_id = ?',
          whereArgs: [entry.ticket.id],
        );

        if (updatedReports == 0) {
          await txn.insert(
            DatabaseHelper.serviceReportsTable,
            entry.report.toMap(),
          );
        }
      }
    });
  }

  @override
  Future<List<HistoryEntryModel>> getHistory() async {
    final reportRows = await _database.query(
      DatabaseHelper.serviceReportsTable,
      orderBy: 'resolved_at DESC',
    );

    if (reportRows.isEmpty) return [];

    final reports = reportRows.map(ServiceReportModel.fromMap).toList();
    final ticketIds = reports.map((report) => report.ticketId).toList();

    final ticketRows = await _database.query(
      DatabaseHelper.ticketsTable,
      where: 'id IN (${DatabaseHelper.placeholders(ticketIds.length)})',
      whereArgs: ticketIds,
    );

    final ticketsById = {
      for (final row in ticketRows) row['id'] as int: TicketModel.fromMap(row),
    };

    return reports
        .map(
          (report) => HistoryEntryModel(
            ticket: ticketsById[report.ticketId]!,
            report: report,
          ),
        )
        .toList();
  }
}
