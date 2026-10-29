import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';

class MockAppClient extends Mock implements AppClient {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class MockSessionLocalDatasource extends Mock
    implements SessionLocalDatasource {}
