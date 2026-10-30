import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/core/network/dio_app_client.dart';
import 'package:projeto_final_m02/core/services/connectivity_service.dart';
import 'package:projeto_final_m02/core/services/location_service.dart';
import 'package:projeto_final_m02/core/services/photo_service.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/service_report_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/ticket_remote_datasource.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';
import 'package:projeto_final_m02/data/repositories/ticket_repository.dart';
import 'package:projeto_final_m02/viewModel/home_view_model.dart';
import 'package:projeto_final_m02/viewModel/login_view_model.dart';
import 'package:projeto_final_m02/viewModel/service_report_view_model.dart';
import 'package:projeto_final_m02/viewModel/splash_view_model.dart';
import 'package:sqflite/sqflite.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<Database>(await DatabaseHelper.db);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<ConnectivityService>(ConnectivityPlusService.new);
  getIt.registerLazySingleton<LocationService>(
    () => const GeolocatorLocationService(),
  );
  getIt.registerLazySingleton<PhotoService>(ImagePickerPhotoService.new);
  getIt.registerLazySingleton<SessionLocalDatasource>(
    () => SessionLocalDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TicketLocalDatasource>(
    () => TicketLocalDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ServiceReportLocalDatasource>(
    () => ServiceReportLocalDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AppClient>(
    () => DioAppClient.create(
      tokenProvider: getIt<SessionLocalDatasource>().getToken,
    ),
  );
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<TicketRemoteDatasource>(
    () => TicketRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ServiceReportRemoteDatasource>(
    () => ServiceReportRemoteDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: getIt(),
      sessionDatasource: getIt(),
    ),
  );
  getIt.registerLazySingleton<TicketRepository>(
    () => TicketRepositoryImpl(
      remoteDatasource: getIt(),
      localDatasource: getIt(),
    ),
  );
  getIt.registerLazySingleton<ServiceReportRepository>(
    () => ServiceReportRepositoryImpl(localDatasource: getIt()),
  );
  getIt.registerFactory<SplashViewModel>(() => SplashViewModel(getIt()));
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(authRepository: getIt(), ticketRepository: getIt()),
  );
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      ticketRepository: getIt(),
      authRepository: getIt(),
      locationService: getIt(),
      connectivityService: getIt(),
    ),
  );
  getIt.registerFactoryParam<ServiceReportViewModel, TicketModel, void>(
    (ticket, _) => ServiceReportViewModel(
      ticket: ticket,
      repository: getIt(),
      photoService: getIt(),
    ),
  );
}
