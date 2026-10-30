import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/models/sync_summary.dart';
import 'package:projeto_final_m02/data/repositories/sync_repository.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockServiceReportRepository serviceReportRepository;
  late MockTicketRepository ticketRepository;
  late SyncRepository repository;

  setUp(() {
    serviceReportRepository = MockServiceReportRepository();
    ticketRepository = MockTicketRepository();
    repository = SyncRepositoryImpl(
      serviceReportRepository: serviceReportRepository,
      ticketRepository: ticketRepository,
    );
    when(
      () => serviceReportRepository.syncPendingReports(),
    ).thenAnswer((_) async => const Success(SyncSummary(sent: 1, rejected: 0)));
    when(() => ticketRepository.syncTickets())
        .thenAnswer((_) async => const Success(null));
    when(() => serviceReportRepository.refreshHistory())
        .thenAnswer((_) async => const Success(null));
  });

  group('SyncRepository', () {
    test(
      'Envia os atendimentos antes de atualizar chamados e histórico',
      () async {
        await repository.syncAll();

        verifyInOrder([
          () => serviceReportRepository.syncPendingReports(),
          () => ticketRepository.syncTickets(),
          () => serviceReportRepository.refreshHistory(),
        ]);
      },
    );

    test('Chamadas simultâneas compartilham a mesma sincronização', () async {
      await Future.wait([repository.syncAll(), repository.syncAll()]);

      verify(() => serviceReportRepository.syncPendingReports()).called(1);
    });

    test('Não atualiza os chamados quando a sessão expirou', () async {
      when(() => serviceReportRepository.syncPendingReports())
          .thenAnswer((_) async => const Failure(UnauthorizedFailure()));

      final Result<SyncSummary> result = await repository.syncAll();

      expect(result, isA<Failure<SyncSummary>>());
      verifyNever(() => ticketRepository.syncTickets());
    });
  });
}
