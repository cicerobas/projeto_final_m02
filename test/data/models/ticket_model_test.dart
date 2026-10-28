import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/models/ticket_status.dart';

void main() {
  final apiJson = <String, dynamic>{
    'id': 1,
    'codigo_cliente': 'CLI-84920',
    'nome_cliente': 'Mariana Silveira Ramos',
    'categoria_informada': 'Lentidão na navegação',
    'descricao_problema': 'Vídeos em alta resolução não carregam.',
    'endereco_cliente': 'Rua Fernando Machado, 450, Apto 204',
    'bairro': 'Centro',
    'cidade': 'Chapecó',
    'latitude': -27.100412,
    'longitude': -52.615234,
    'status': 'ativo',
    'criado_em': '2026-09-28 14:20:00',
  };

  group('TicketModel', () {
    test('Converte o JSON da API em modelo', () {
      final ticket = TicketModel.fromJson(apiJson);

      expect(ticket.id, 1);
      expect(ticket.clientCode, 'CLI-84920');
      expect(ticket.status, TicketStatus.active);
      expect(ticket.createdAt, DateTime(2026, 9, 28, 14, 20));
    });

    test('Aceita números enviados como texto pela API', () {
      final ticket = TicketModel.fromJson({...apiJson, 'id': '1', 'latitude': '-27.100412', 'longitude': '-52.615234'});

      expect(ticket.id, 1);
      expect(ticket.latitude, -27.100412);
    });

    test('Mantém os dados após salvar e ler do banco', () {
      final ticket = TicketModel.fromJson(apiJson);

      expect(TicketModel.fromMap(ticket.toMap()), ticket);
    });
  });

  test('TicketStatus lança erro para status desconhecido', () {
    expect(() => TicketStatus.fromApiValue('cancelado'), throwsFormatException);
  });
}
