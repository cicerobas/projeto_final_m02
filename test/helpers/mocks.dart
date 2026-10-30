import 'package:mocktail/mocktail.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/core/services/connectivity_service.dart';
import 'package:projeto_final_m02/core/services/location_service.dart';
import 'package:projeto_final_m02/core/services/photo_service.dart';
import 'package:projeto_final_m02/data/datasources/local/service_report_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/service_report_remote_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/ticket_remote_datasource.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';
import 'package:projeto_final_m02/data/repositories/sync_repository.dart';
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

class MockLocationService extends Mock implements LocationService {}

class MockConnectivityService extends Mock implements ConnectivityService {}

class MockServiceReportLocalDatasource extends Mock
    implements ServiceReportLocalDatasource {}

class MockServiceReportRepository extends Mock
    implements ServiceReportRepository {}

class MockPhotoService extends Mock implements PhotoService {}

class MockServiceReportRemoteDatasource extends Mock
    implements ServiceReportRemoteDatasource {}

class MockSyncRepository extends Mock implements SyncRepository {}
