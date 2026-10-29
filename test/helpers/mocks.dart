import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/ticket_remote_datasource.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:projeto_final_m02/data/repositories/ticket_repository.dart';

class MockAppClient extends Mock implements AppClient {}

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

class MockSessionLocalDatasource extends Mock
    implements SessionLocalDatasource {}

class MockTicketRemoteDatasource extends Mock
    implements TicketRemoteDatasource {}

class MockTicketLocalDatasource extends Mock implements TicketLocalDatasource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTicketRepository extends Mock implements TicketRepository {}
