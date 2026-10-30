import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';

abstract interface class ServiceReportRepository {
  Future<Result<void>> completeReport(ServiceReportModel report);
}

class ServiceReportRepositoryImpl implements ServiceReportRepository {
  final ServiceReportLocalDatasource _localDatasource;

  const ServiceReportRepositoryImpl({required this._localDatasource});

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
}
