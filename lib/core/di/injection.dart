import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';

import 'package:projeto_final_m02/data/datasources/local/database_helper.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerSingleton<Database>(await DatabaseHelper.db);
}
