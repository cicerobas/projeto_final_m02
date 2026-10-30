import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';

import '../../helpers/mocks.dart';
import '../../helpers/model_factories.dart';

void main() {
  late MockServiceReportLocalDatasource localDatasource;
  late ServiceReportRepository repository;

  setUpAll(() => registerFallbackValue(buildServiceReport()));

  setUp(() {
    localDatasource = MockServiceReportLocalDatasource();
    repository = ServiceReportRepositoryImpl(localDatasource: localDatasource);
  });

  group('ServiceReportRepository.completeReport', () {
    test('Salva o atendimento no banco local', () async {
      when(() => localDatasource.saveCompletedReport(any()))
          .thenAnswer((_) async => 1);

      final Result<void> result = await repository.completeReport(
        buildServiceReport(),
      );

      expect(result, isA<Success<void>>());
      verify(() => localDatasource.saveCompletedReport(any())).called(1);
    });

    test('Retorna falha de banco quando a gravação falha', () async {
      when(() => localDatasource.saveCompletedReport(any()))
          .thenThrow(Exception('disk full'));

      final Result<void> result = await repository.completeReport(
        buildServiceReport(),
      );

      expect(
        result,
        isA<Failure<void>>().having(
          (f) => f.failure,
          'failure',
          isA<DatabaseFailure>(),
        ),
      );
    });
  });
}
