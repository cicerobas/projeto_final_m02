import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

void main() {
  test('HistoryEntryModel converte o item do histórico da API', () {
    final entry = HistoryEntryModel.fromJson({
      'chamado_id': 1,
      'codigo_cliente': 'CLI-84920',
      'nome_cliente': 'Mariana Silveira Ramos',
      'categoria_informada': 'Lentidão na navegação',
      'descricao_problema': 'Vídeos não carregam.',
      'endereco_cliente': 'Rua Fernando Machado, 450',
      'bairro': 'Centro',
      'cidade': 'Chapecó',
      'latitude': -27.100412,
      'longitude': -52.615234,
      'status_chamado': 'resolvido',
      'chamado_criado_em': '2026-09-28 14:20:00',
      'atendimento': {
        'id': 14,
        'categoria_tecnico': 'Conector danificado',
        'descricao_procedimento': 'Feita nova conectorização da fibra.',
        'data_resolucao': '2026-10-01 15:30:00',
        'foto_url': null,
        'registrado_em': '2026-10-01 15:30:12',
      },
    });

    expect(entry.ticket.id, 1);
    expect(entry.ticket.status, TicketStatus.resolved);
    expect(entry.report.ticketId, 1);
    expect(entry.report.remoteId, 14);
  });
}
