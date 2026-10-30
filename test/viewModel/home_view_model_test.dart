import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/services/location_service.dart';
import 'package:projeto_final_m02/viewModel/home_view_model.dart';

import '../helpers/mocks.dart';
import '../helpers/model_factories.dart';

void main() {
  late MockTicketRepository ticketRepository;
  late MockSyncRepository syncRepository;
  late MockAuthRepository authRepository;
  late MockLocationService locationService;
  late MockConnectivityService connectivityService;
  late HomeViewModel viewModel;

  final nearTicket = buildTicket(
    id: 1,
    latitude: -27.1004,
    longitude: -52.6152,
  );
  final farTicket = buildTicket(id: 2, latitude: -27.2000, longitude: -52.7000);

  setUp(() {
    ticketRepository = MockTicketRepository();
    syncRepository = MockSyncRepository();
    authRepository = MockAuthRepository();
    locationService = MockLocationService();
    connectivityService = MockConnectivityService();
    viewModel = HomeViewModel(
      ticketRepository: ticketRepository,
      syncRepository: syncRepository,
      authRepository: authRepository,
      locationService: locationService,
      connectivityService: connectivityService,
    );

    when(() => connectivityService.onStatusChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => authRepository.getLoggedUser()).thenAnswer((_) async => null);
    when(() => ticketRepository.getActiveTickets())
        .thenAnswer((_) async => Success([farTicket, nearTicket]));
    when(() => locationService.getCurrentLocation()).thenAnswer(
      (_) async => const LocationAvailable(latitude: -27.1, longitude: -52.615),
    );
  });

  tearDown(() => viewModel.dispose());

  group('HomeViewModel', () {
    test('Ordena os chamados do mais próximo ao mais distante', () async {
      when(() => connectivityService.isOnline()).thenAnswer((_) async => false);

      await viewModel.init();

      expect(viewModel.tickets.map((ticket) => ticket.id), [1, 2]);
      expect(viewModel.isSortedByDistance, isTrue);
    });

    test(
      'Encerra a sessão quando a API responde que o token expirou',
      () async {
        when(() => connectivityService.isOnline())
            .thenAnswer((_) async => true);
        when(() => syncRepository.syncAll())
            .thenAnswer((_) async => const Failure(UnauthorizedFailure()));
        when(() => authRepository.logout()).thenAnswer((_) async {});

        await viewModel.init();

        expect(viewModel.isSessionExpired, isTrue);
        verify(() => authRepository.logout()).called(1);
      },
    );
  });
}
