import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/services/photo_service.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/viewModel/service_report_view_model.dart';

import '../helpers/mocks.dart';
import '../helpers/model_factories.dart';

void main() {
  late MockServiceReportRepository repository;
  late MockPhotoService photoService;
  late MockMapsService mapsService;
  late ServiceReportViewModel viewModel;

  setUpAll(() => registerFallbackValue(buildServiceReport()));

  setUp(() {
    repository = MockServiceReportRepository();
    photoService = MockPhotoService();
    mapsService = MockMapsService();
    viewModel = ServiceReportViewModel(
      ticket: buildTicket(id: 7),
      repository: repository,
      photoService: photoService,
      mapsService: mapsService,
    );
    when(() => repository.completeReport(any())).thenAnswer((_) async => const Success(null));
    when(() => photoService.deletePhoto(any())).thenAnswer((_) async {});
  });

  tearDown(() => viewModel.dispose());

  group('ServiceReportViewModel', () {
    test('Salva o atendimento com os dados do formulário e a foto', () async {
      when(() => photoService.takePhoto(PhotoSource.camera))
          .thenAnswer((_) async => const Success('/fotos/report.jpg'));
      viewModel
        ..selectCategory('Fibra rompida')
        ..updateDescription('  Fusão da fibra e teste de sinal.  ');
      await viewModel.pickPhoto(PhotoSource.camera);

      final bool saved = await viewModel.complete();

      expect(saved, isTrue);
      final ServiceReportModel report =
          verify(() => repository.completeReport(captureAny())).captured.single as ServiceReportModel;
      expect(report.ticketId, 7);
      expect(report.procedureDescription, 'Fusão da fibra e teste de sinal.');
      expect(report.photoPath, '/fotos/report.jpg');
      expect(report.isSynced, isFalse);
    });

    test('Apaga a foto anterior ao escolher uma nova', () async {
      when(() => photoService.takePhoto(PhotoSource.camera))
          .thenAnswer((_) async => const Success('/fotos/primeira.jpg'));
      await viewModel.pickPhoto(PhotoSource.camera);
      when(() => photoService.takePhoto(PhotoSource.gallery))
          .thenAnswer((_) async => const Success('/fotos/segunda.jpg'));

      await viewModel.pickPhoto(PhotoSource.gallery);

      expect(viewModel.photoPath, '/fotos/segunda.jpg');
      verify(() => photoService.deletePhoto('/fotos/primeira.jpg')).called(1);
    });
  });
}
