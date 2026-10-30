import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/models/session_model.dart';
import 'package:projeto_final_m02/data/models/user_model.dart';

void main() {
  late SessionLocalDatasource datasource;

  const session = SessionModel(
    token: 'abc123',
    user: UserModel(id: 1, name: 'Joao Garcia', email: 'joao@email.com'),
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    datasource = const SessionLocalDatasourceImpl(FlutterSecureStorage());
  });

  group('SessionLocalDatasource', () {
    test('Salva e recupera a sessão', () async {
      await datasource.saveSession(session);

      final saved = await datasource.getSession();

      expect(saved?.token, 'abc123');
      expect(saved?.user, session.user);
      expect(await datasource.getToken(), 'abc123');
    });

    test('Remove a sessão ao sair', () async {
      await datasource.saveSession(session);

      await datasource.clearSession();

      expect(await datasource.getSession(), isNull);
      expect(await datasource.getToken(), isNull);
    });
  });
}
