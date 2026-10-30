import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/service_report_remote_datasource.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/data/models/sync_summary.dart';

abstract interface class ServiceReportRepository {
  Future<Result<void>> completeReport(ServiceReportModel report);

  Future<Result<SyncSummary>> syncPendingReports();

  Future<Result<void>> refreshHistory();

  Future<Result<List<HistoryEntryModel>>> getHistory();
}

class ServiceReportRepositoryImpl implements ServiceReportRepository {
  final ServiceReportLocalDatasource _localDatasource;
  final ServiceReportRemoteDatasource _remoteDatasource;

  const ServiceReportRepositoryImpl({
    required this._localDatasource,
    required this._remoteDatasource,
  });

  @override
  Future<Result<void>> completeReport(ServiceReportModel report) async {
    try {
      await _localDatasource.saveCompletedReport(report);
      return const Success(null);
    } catch (_) {
      return const Failure(
        DatabaseFailure(
          'Não foi possível salvar o atendimento. Tente novamente.',
        ),
      );
    }
  }

  @override
  Future<Result<SyncSummary>> syncPendingReports() async {
    try {
      final pendingReports = await _localDatasource.getPendingReports();
      int sent = 0;
      int rejected = 0;

      for (final report in pendingReports) {
        final int id = report.id!;
        try {
          final response = await _remoteDatasource.submitReport(report);
          await _localDatasource.markAsSynced(
            id,
            remoteId: response.remoteId,
            photoUrl: response.photoUrl,
          );
          sent++;
        } on AppClientException catch (exception) {
          if (_shouldStopSync(exception)) return Failure(exception.toFailure());

          await _localDatasource.markAsFailed(
            id,
            exception.toFailure().message,
          );
          rejected++;
        }
      }

      return Success(SyncSummary(sent: sent, rejected: rejected));
    } catch (_) {
      return const Failure(DatabaseFailure());
    }
  }

  @override
  Future<Result<void>> refreshHistory() async {
    try {
      final entries = await _remoteDatasource.getHistory();
      await _localDatasource.saveHistory(entries);
      return const Success(null);
    } on AppClientException catch (exception) {
      return Failure(exception.toFailure());
    } catch (_) {
      return const Failure(UnknownFailure());
    }
  }

  @override
  Future<Result<List<HistoryEntryModel>>> getHistory() async {
    try {
      return Success(await _localDatasource.getHistory());
    } catch (_) {
      return const Failure(DatabaseFailure());
    }
  }

  static bool _shouldStopSync(AppClientException exception) =>
      switch (exception) {
        NetworkException() || UnauthorizedException() => true,
        ServerException(:final statusCode) =>
          statusCode == null || statusCode >= 500,
        UnknownClientException() => false,
      };
}
