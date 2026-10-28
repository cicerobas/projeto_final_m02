import 'package:get_it/get_it.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:sqflite/sqflite.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<Database>(await DatabaseHelper.db);
  getIt.registerLazySingleton<TicketLocalDatasource>(
    () => TicketLocalDatasourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ServiceReportLocalDatasource>(
    () => ServiceReportLocalDatasourceImpl(getIt()),
  );
}
