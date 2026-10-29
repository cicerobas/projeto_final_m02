import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/core/network/dio_app_client.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/service_report_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/ticket_remote_datasource.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:sqflite/sqflite.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<Database>(await DatabaseHelper.db);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
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
}

//TODO VERIFICAR SINGLETON POR FACTORY
