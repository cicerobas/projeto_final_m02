import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';

import 'package:projeto_final_m02/view/service_report/service_report_page.dart';
import 'package:projeto_final_m02/viewModel/service_report_view_model.dart';

import '../../helpers/mocks.dart';
import '../../helpers/model_factories.dart';

void main() {
  final descriptionField = find.widgetWithText(
    TextFormField,
    'Procedimento realizado *',
  );
  final submitButton = find.text('Concluir atendimento');

  Future<void> pumpServiceReportPage(WidgetTester tester) {
    final TicketModel ticket = buildTicket();
    return tester.pumpWidget(
      MaterialApp(
        home: ServiceReportPage(
          ticket: ticket,
          viewModel: ServiceReportViewModel(
            ticket: ticket,
            repository: MockServiceReportRepository(),
            photoService: MockPhotoService(),
          ),
        ),
      ),
    );
  }

  group('ServiceReportPage', () {
    testWidgets(
      'Exibe erro nos campos e SnackBar quando o formulário é inválido',
      (tester) async {
        await pumpServiceReportPage(tester);

        await tester.enterText(descriptionField, 'curto');
        await tester.tap(submitButton);
        await tester.pump();

        expect(find.text('Selecione a categoria técnica'), findsOneWidget);
        expect(
          find.text('Tamanho mínimo da descrição: 10 caracteres'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Corrija os campos destacados para concluir o atendimento.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('Não aceita descrição formada apenas por espaços', (
      tester,
    ) async {
      await pumpServiceReportPage(tester);

      await tester.enterText(descriptionField, '            ');
      await tester.tap(submitButton);
      await tester.pump();

      expect(find.text('Descreva o procedimento realizado'), findsOneWidget);
    });

    testWidgets('Pede confirmação quando o formulário é válido', (
      tester,
    ) async {
      await pumpServiceReportPage(tester);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fibra rompida').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        descriptionField,
        'Fusão da fibra no ponto rompido e teste de sinal.',
      );
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Concluir atendimento?'), findsOneWidget);
    });
  });
}
