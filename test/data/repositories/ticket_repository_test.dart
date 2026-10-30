import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/repositories/ticket_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/model_factories.dart';

void main() {
  late MockTicketRemoteDatasource remoteDatasource;
  late MockTicketLocalDatasource localDatasource;
  late TicketRepository repository;

  setUpAll(() => registerFallbackValue(<TicketModel>[]));

  setUp(() {
    remoteDatasource = MockTicketRemoteDatasource();
    localDatasource = MockTicketLocalDatasource();
    repository = TicketRepositoryImpl(
      remoteDatasource: remoteDatasource,
      localDatasource: localDatasource,
    );
  });

  group('TicketRepository.syncTickets', () {
    test('Baixa os chamados da API e salva no banco local', () async {
      final tickets = [buildTicket(id: 1), buildTicket(id: 2)];
      when(() => remoteDatasource.getActiveTickets())
          .thenAnswer((_) async => tickets);
      when(() => localDatasource.saveTickets(any())).thenAnswer((_) async {});

      final result = await repository.syncTickets();

      expect(result, isA<Success<void>>());
      verify(() => localDatasource.saveTickets(tickets)).called(1);
    });

    test('Retorna falha de rede e não altera o banco local', () async {
      when(() => remoteDatasource.getActiveTickets())
          .thenThrow(const NetworkException());

      final result = await repository.syncTickets();

      expect(
        result,
        isA<Failure<void>>().having(
          (f) => f.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
      verifyNever(() => localDatasource.saveTickets(any()));
    });
  });
}
