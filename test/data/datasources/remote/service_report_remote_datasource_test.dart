import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/data/datasources/remote/service_report_remote_datasource.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/model_factories.dart';

void main() {
  late MockAppClient client;
  late ServiceReportRemoteDatasource datasource;

  setUp(() {
    client = MockAppClient();
    datasource = ServiceReportRemoteDatasourceImpl(client);
    when(
      () => client.postMultipart(
        any(),
        fields: any(named: 'fields'),
        files: any(named: 'files'),
      ),
    ).thenAnswer(
      (_) async => {
        'dados': {
          'atendimento_id': 14,
          'foto_url': 'https://exemplo.com/foto.jpg',
        },
      },
    );
  });

  group('ServiceReportRemoteDatasource', () {
    test(
      'Envia os campos e a foto do atendimento e retorna o id remoto',
      () async {
        final result = await datasource.submitReport(
          buildServiceReport(photoPath: '/fotos/atendimento.jpg'),
        );

        expect(result.remoteId, 14);
        expect(result.photoUrl, 'https://exemplo.com/foto.jpg');
        final captured = verify(
          () => client.postMultipart(
            ApiEndpoints.serviceReport,
            fields: captureAny(named: 'fields'),
            files: captureAny(named: 'files'),
          ),
        ).captured;
        expect((captured[0] as Map)['chamado_id'], 1);
        expect(captured[1], {'foto': '/fotos/atendimento.jpg'});
      },
    );

    test('Não envia arquivo quando o atendimento não tem foto', () async {
      await datasource.submitReport(buildServiceReport());

      final files = verify(
        () => client.postMultipart(
          any(),
          fields: any(named: 'fields'),
          files: captureAny(named: 'files'),
        ),
      ).captured.single;
      expect(files, isEmpty);
    });
  });
}
