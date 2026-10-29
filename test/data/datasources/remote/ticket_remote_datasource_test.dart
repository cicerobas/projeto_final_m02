import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/data/datasources/remote/ticket_remote_datasource.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/model_factories.dart';

void main() {
  test('TicketRemoteDatasource converte a lista de chamados da API', () async {
    final client = MockAppClient();
    final datasource = TicketRemoteDatasourceImpl(client);
    final ticketJson = {
      'id': 1,
      'codigo_cliente': 'CLI-1',
      'nome_cliente': 'Mariana Silveira Ramos',
      'categoria_informada': 'Lentidão na navegação',
      'descricao_problema': 'Vídeos não carregam.',
      'endereco_cliente': 'Rua Fernando Machado, 450',
      'bairro': 'Centro',
      'cidade': 'Chapecó',
      'latitude': -27.100412,
      'longitude': -52.615234,
      'status': 'ativo',
      'criado_em': '2026-09-28 14:20:00',
    };
    when(() => client.get(ApiEndpoints.tickets)).thenAnswer(
      (_) async => {
        'dados': [ticketJson],
      },
    );

    final tickets = await datasource.getActiveTickets();

    expect(tickets, [buildTicket(id: 1)]);
  });
}
