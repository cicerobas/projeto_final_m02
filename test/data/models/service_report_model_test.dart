import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';

void main() {
  group('ServiceReportModel', () {
    test('Mantém os dados após salvar e ler do banco, com campos opcionais nulos', () {
      final report = ServiceReportModel(
        ticketId: 1,
        technicalCategory: 'Conector danificado',
        procedureDescription: 'Feita nova conectorização da fibra.',
        resolvedAt: DateTime(2026, 10, 27, 10, 30),
        createdAt: DateTime(2026, 10, 27, 10, 31),
      );

      expect(ServiceReportModel.fromMap(report.toMap()), report);
    });

    test('Converte o atendimento do histórico da API como sincronizado', () {
      final report = ServiceReportModel.fromHistoryJson({
        'id': 14,
        'categoria_tecnico': 'Conector danificado',
        'descricao_procedimento': 'Feita nova conectorização da fibra.',
        'data_resolucao': '2026-10-01 15:30:00',
        'foto_url': 'https://exemplo.com/foto.jpg',
        'registrado_em': '2026-10-01 15:30:12',
      }, ticketId: 1);

      expect(report.remoteId, 14);
      expect(report.ticketId, 1);
      expect(report.isSynced, isTrue);
      expect(report.photoUrl, 'https://exemplo.com/foto.jpg');
    });

    test('Gera os campos de envio no formato de data esperado pela API', () {
      final report = ServiceReportModel(
        ticketId: 1,
        technicalCategory: 'Conector danificado',
        procedureDescription: 'Feita nova conectorização da fibra.',
        resolvedAt: DateTime(2026, 10, 27, 9, 5, 3),
        createdAt: DateTime(2026, 10, 27, 9, 6),
      );

      expect(report.toApiFields()['data_resolucao'], '2026-10-27 09:05:03');
    });
  });
}
