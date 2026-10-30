import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/data/models/sync_summary.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/model_factories.dart';

void main() {
  late MockServiceReportLocalDatasource localDatasource;
  late MockServiceReportRemoteDatasource remoteDatasource;
  late ServiceReportRepository repository;

  setUpAll(() => registerFallbackValue(buildServiceReport()));

  setUp(() {
    localDatasource = MockServiceReportLocalDatasource();
    remoteDatasource = MockServiceReportRemoteDatasource();
    repository = ServiceReportRepositoryImpl(
      localDatasource: localDatasource,
      remoteDatasource: remoteDatasource,
    );
    when(
      () => localDatasource.markAsSynced(
        any(),
        remoteId: any(named: 'remoteId'),
        photoUrl: any(named: 'photoUrl'),
      ),
    ).thenAnswer((_) async {});
    when(() => localDatasource.markAsFailed(any(), any()))
        .thenAnswer((_) async {});
  });

  group('ServiceReportRepository.completeReport', () {
    test('Salva o atendimento no banco local', () async {
      when(() => localDatasource.saveCompletedReport(any()))
          .thenAnswer((_) async => 1);

      final Result<void> result = await repository.completeReport(
        buildServiceReport(),
      );

      expect(result, isA<Success<void>>());
      verify(() => localDatasource.saveCompletedReport(any())).called(1);
    });

    test('Retorna falha de banco quando a gravação falha', () async {
      when(() => localDatasource.saveCompletedReport(any()))
          .thenThrow(Exception('disk full'));

      final Result<void> result = await repository.completeReport(
        buildServiceReport(),
      );

      expect(
        result,
        isA<Failure<void>>().having(
          (f) => f.failure,
          'failure',
          isA<DatabaseFailure>(),
        ),
      );
    });
  });

  group('ServiceReportRepository.syncPendingReports', () {
    test('Envia os pendentes e marca como sincronizados', () async {
      when(() => localDatasource.getPendingReports())
          .thenAnswer((_) async => [buildServiceReport(id: 10)]);
      when(() => remoteDatasource.submitReport(any()))
          .thenAnswer((_) async => (remoteId: 14, photoUrl: null));

      final Result<SyncSummary> result = await repository.syncPendingReports();

      expect(
        result,
        isA<Success<SyncSummary>>().having((s) => s.value.sent, 'sent', 1),
      );
      verify(
        () => localDatasource.markAsSynced(10, remoteId: 14, photoUrl: null),
      ).called(1);
    });

    test('Marca erro no atendimento recusado pela API e continua', () async {
      when(() => localDatasource.getPendingReports()).thenAnswer(
        (_) async => [
          buildServiceReport(id: 10, ticketId: 1),
          buildServiceReport(id: 11, ticketId: 2),
        ],
      );
      when(() => remoteDatasource.submitReport(any()))
          .thenAnswer((invocation) async {
            final report =
                invocation.positionalArguments.first as ServiceReportModel;
            if (report.id == 10) {
              throw const ServerException(
                statusCode: 409,
                message: 'Chamado já resolvido.',
              );
            }
            return (remoteId: 15, photoUrl: null);
          });

      final Result<SyncSummary> result = await repository.syncPendingReports();

      expect(
        result,
        isA<Success<SyncSummary>>()
            .having((s) => s.value.sent, 'sent', 1)
            .having((s) => s.value.rejected, 'rejected', 1),
      );
      verify(() => localDatasource.markAsFailed(10, 'Chamado já resolvido.'))
          .called(1);
    });

    test('Interrompe sem alterar os pendentes quando não há conexão', () async {
      when(() => localDatasource.getPendingReports())
          .thenAnswer((_) async => [buildServiceReport(id: 10)]);
      when(() => remoteDatasource.submitReport(any()))
          .thenThrow(const NetworkException());

      final Result<SyncSummary> result = await repository.syncPendingReports();

      expect(
        result,
        isA<Failure<SyncSummary>>().having(
          (f) => f.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
      verifyNever(() => localDatasource.markAsFailed(any(), any()));
    });
  });
}
