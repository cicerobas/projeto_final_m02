import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/data/models/session_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<SessionModel> login({
    required String email,
    required String passwordHmac,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final AppClient _client;

  const AuthRemoteDatasourceImpl(this._client);

  @override
  Future<SessionModel> login({
    required String email,
    required String passwordHmac,
  }) async {
    final json = await _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'senha_hmac': passwordHmac},
    );

    return SessionModel.fromJson(json['dados'] as Map<String, dynamic>);
  }
}
