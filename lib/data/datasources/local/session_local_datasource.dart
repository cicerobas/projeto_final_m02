import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:projeto_final_m02/data/models/session_model.dart';
import 'package:projeto_final_m02/data/models/user_model.dart';

abstract interface class SessionLocalDatasource {
  Future<void> saveSession(SessionModel session);

  Future<SessionModel?> getSession();

  Future<String?> getToken();

  Future<void> clearSession();
}

class SessionLocalDatasourceImpl implements SessionLocalDatasource {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  const SessionLocalDatasourceImpl(this._storage);

  @override
  Future<void> saveSession(SessionModel session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(session.user.toJson()),
    );
  }

  @override
  Future<SessionModel?> getSession() async {
    final token = await _storage.read(key: _tokenKey);
    final user = await _storage.read(key: _userKey);

    if (token == null || user == null) return null;

    return SessionModel(
      token: token,
      user: UserModel.fromJson(jsonDecode(user) as Map<String, dynamic>),
    );
  }

  @override
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
