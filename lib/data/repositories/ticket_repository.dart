import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/datasources/local/ticket_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/ticket_remote_datasource.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';

abstract interface class TicketRepository {
  Future<Result<void>> syncTickets();

  Future<Result<List<TicketModel>>> getActiveTickets();
}

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDatasource _remoteDatasource;
  final TicketLocalDatasource _localDatasource;

  const TicketRepositoryImpl({
    required this._remoteDatasource,
    required this._localDatasource,
  });

  @override
  Future<Result<void>> syncTickets() async {
    try {
      final tickets = await _remoteDatasource.getActiveTickets();
      await _localDatasource.saveTickets(tickets);
      return const Success(null);
    } on AppClientException catch (exception) {
      return Failure(exception.toFailure());
    } catch (_) {
      return const Failure(UnknownFailure());
    }
  }

  @override
  Future<Result<List<TicketModel>>> getActiveTickets() async {
    try {
      return Success(await _localDatasource.getActiveTickets());
    } catch (_) {
      return const Failure(DatabaseFailure());
    }
  }
}
