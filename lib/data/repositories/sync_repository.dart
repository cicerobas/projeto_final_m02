import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/models/sync_summary.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';
import 'package:projeto_final_m02/data/repositories/ticket_repository.dart';

abstract interface class SyncRepository {
  Future<Result<SyncSummary>> syncAll();
}

class SyncRepositoryImpl implements SyncRepository {
  final ServiceReportRepository _serviceReportRepository;
  final TicketRepository _ticketRepository;

  SyncRepositoryImpl({
    required this._serviceReportRepository,
    required this._ticketRepository,
  });

  Future<Result<SyncSummary>>? _currentSync;

  @override
  Future<Result<SyncSummary>> syncAll() =>
      _currentSync ??= _runSync().whenComplete(() => _currentSync = null);

  Future<Result<SyncSummary>> _runSync() async {
    final Result<SyncSummary> reportsResult = await _serviceReportRepository
        .syncPendingReports();
    if (reportsResult is Failure<SyncSummary>) return reportsResult;

    final Result<void> ticketsResult = await _ticketRepository.syncTickets();
    if (ticketsResult case Failure(:final failure)) return Failure(failure);

    await _serviceReportRepository.refreshHistory();
    return reportsResult;
  }
}
