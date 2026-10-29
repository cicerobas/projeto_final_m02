import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/view/login/login_page.dart';
import 'package:projeto_final_m02/viewModel/login_view_model.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockTicketRepository ticketRepository;

  Future<void> pumpLoginPage(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          viewModel: LoginViewModel(
            authRepository: authRepository,
            ticketRepository: ticketRepository,
          ),
        ),
      ),
    );
  }

  setUp(() {
    authRepository = MockAuthRepository();
    ticketRepository = MockTicketRepository();
  });

  group('LoginPage', () {
    testWidgets('Exibe mensagens de validação quando os campos estão vazios', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Informe o e-mail'), findsOneWidget);
      expect(find.text('Informe a senha'), findsOneWidget);
      verifyNever(
        () => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('Exibe a mensagem da API quando o login falha', (tester) async {
      when(
        () => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async =>
            const Failure(UnauthorizedFailure('Credenciais inválidas.')),
      );
      await pumpLoginPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'joao@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'errada',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Credenciais inválidas.'), findsOneWidget);
      verifyNever(() => ticketRepository.syncTickets());
    });
  });
}
