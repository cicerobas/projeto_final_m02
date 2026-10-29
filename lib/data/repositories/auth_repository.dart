import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/security/password_hasher.dart';
import 'package:projeto_final_m02/data/datasources/local/session_local_datasource.dart';
import 'package:projeto_final_m02/data/datasources/remote/auth_remote_datasource.dart';
import 'package:projeto_final_m02/data/models/user_model.dart';

abstract interface class AuthRepository {
  Future<Result<UserModel>> login({
    required String email,
    required String password,
  });

  Future<UserModel?> getLoggedUser();

  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SessionLocalDatasource _sessionDatasource;

  const AuthRepositoryImpl({
    required this._remoteDatasource,
    required this._sessionDatasource,
  });

  @override
  Future<Result<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _remoteDatasource.login(
        email: email.trim(),
        passwordHmac: PasswordHasher.hmacSha256(password),
      );
      await _sessionDatasource.saveSession(session);
      return Success(session.user);
    } on AppClientException catch (exception) {
      return Failure(exception.toFailure());
    } catch (_) {
      return const Failure(UnknownFailure());
    }
  }

  @override
  Future<UserModel?> getLoggedUser() async {
    try {
      final session = await _sessionDatasource.getSession();
      return session?.user;
    } catch (_) {
      await _sessionDatasource.clearSession();
      return null;
    }
  }

  @override
  Future<void> logout() => _sessionDatasource.clearSession();
}
