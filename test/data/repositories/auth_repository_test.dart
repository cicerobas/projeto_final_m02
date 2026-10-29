import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/security/password_hasher.dart';
import 'package:projeto_final_m02/data/models/session_model.dart';
import 'package:projeto_final_m02/data/models/user_model.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRemoteDatasource remoteDatasource;
  late MockSessionLocalDatasource sessionDatasource;
  late AuthRepository repository;

  const user = UserModel(id: 1, name: 'Joao Garcia', email: 'joao@email.com');
  const session = SessionModel(token: 'abc123', user: user);

  void stubLogin(Future<SessionModel> Function() answer) {
    when(
      () => remoteDatasource.login(
        email: any(named: 'email'),
        passwordHmac: any(named: 'passwordHmac'),
      ),
    ).thenAnswer((_) => answer());
  }

  setUpAll(() => registerFallbackValue(session));

  setUp(() {
    remoteDatasource = MockAuthRemoteDatasource();
    sessionDatasource = MockSessionLocalDatasource();
    repository = AuthRepositoryImpl(
      remoteDatasource: remoteDatasource,
      sessionDatasource: sessionDatasource,
    );
    when(() => sessionDatasource.saveSession(any())).thenAnswer((_) async {});
  });

  group('AuthRepository.login', () {
    test('Envia o hash da senha, salva a sessão e retorna o usuário', () async {
      stubLogin(() async => session);

      final result = await repository.login(
        email: ' joao@email.com ',
        password: 'senha123',
      );

      expect(result, isA<Success<UserModel>>());
      verify(
        () => remoteDatasource.login(
          email: 'joao@email.com',
          passwordHmac: PasswordHasher.hmacSha256('senha123'),
        ),
      ).called(1);
      verify(() => sessionDatasource.saveSession(session)).called(1);
    });

    test(
      'Retorna falha de credenciais com a mensagem da API e não salva sessão',
      () async {
        stubLogin(
          () async =>
              throw const UnauthorizedException('Credenciais inválidas.'),
        );

        final result = await repository.login(
          email: 'joao@email.com',
          password: 'errada',
        );

        expect(
          result,
          isA<Failure<UserModel>>().having(
            (failure) => failure.failure,
            'failure',
            isA<UnauthorizedFailure>().having(
              (f) => f.message,
              'message',
              'Credenciais inválidas.',
            ),
          ),
        );
        verifyNever(() => sessionDatasource.saveSession(any()));
      },
    );

    test('Retorna falha de rede quando não há conexão', () async {
      stubLogin(() async => throw const NetworkException());

      final result = await repository.login(
        email: 'joao@email.com',
        password: 'senha123',
      );

      expect(
        result,
        isA<Failure<UserModel>>().having(
          (f) => f.failure,
          'failure',
          isA<NetworkFailure>(),
        ),
      );
    });
  });
}
