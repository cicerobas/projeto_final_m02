import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockAppClient client;
  late AuthRemoteDatasource datasource;

  setUp(() {
    client = MockAppClient();
    datasource = AuthRemoteDatasourceImpl(client);
  });

  test(
    'AuthRemoteDatasource envia email e hash da senha e retorna a sessão',
    () async {
      when(() => client.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => {
          'sucesso': true,
          'dados': {
            'token': 'abc123',
            'usuario': {
              'id': 1,
              'nome': 'Joao Garcia',
              'email': 'joao@email.com',
            },
          },
        },
      );

      final session = await datasource.login(
        email: 'joao@email.com',
        passwordHmac: 'hash',
      );

      expect(session.token, 'abc123');
      expect(session.user.id, 1);
      final sentData = verify(
        () => client.post(ApiEndpoints.login, data: captureAny(named: 'data')),
      ).captured.single;
      expect(sentData, {'email': 'joao@email.com', 'senha_hmac': 'hash'});
    },
  );
}
