import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import 'package:projeto_final_m02/core/constants/api_constants.dart';
import 'package:projeto_final_m02/core/network/app_client.dart';
import 'package:projeto_final_m02/core/network/app_client_exception.dart';
import 'package:projeto_final_m02/core/network/auth_interceptor.dart';

class DioAppClient implements AppClient {
  DioAppClient(this._dio);

  factory DioAppClient.create({required TokenProvider tokenProvider}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    )..interceptors.add(AuthInterceptor(tokenProvider));

    return DioAppClient(dio);
  }

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(String path) =>
      _request(() => _dio.get<dynamic>(path));

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) => _request(() => _dio.post<dynamic>(path, data: data));

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, dynamic> fields,
    Map<String, String> files = const {},
  }) {
    return _request(() async {
      final formData = FormData.fromMap({
        ...fields,
        for (final MapEntry(:key, :value) in files.entries)
          key: await MultipartFile.fromFile(
            value,
            filename: p.basename(value),
            contentType: _imageMediaType(value),
          ),
      });

      return _dio.post<dynamic>(path, data: formData);
    });
  }

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    try {
      final response = await send();
      return _decode(response.data);
    } on DioException catch (exception) {
      throw _mapException(exception);
    } on AppClientException {
      rethrow;
    } catch (exception) {
      throw UnknownClientException(exception.toString());
    }
  }

  static Map<String, dynamic> _decode(Object? data) => switch (data) {
    Map<String, dynamic> json => json,
    String body when body.isNotEmpty =>
      jsonDecode(body) as Map<String, dynamic>,
    _ => throw const UnknownClientException('Resposta inválida do servidor.'),
  };

  static AppClientException _mapException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final message = _extractMessage(exception.response?.data);

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse when statusCode == 401 =>
        UnauthorizedException(message),
      DioExceptionType.badResponse => ServerException(
        statusCode: statusCode,
        message: message,
      ),
      _ => UnknownClientException(exception.message),
    };
  }

  static String? _extractMessage(Object? data) {
    try {
      return _decode(data)['mensagem'] as String?;
    } catch (_) {
      return null;
    }
  }

  static DioMediaType _imageMediaType(String path) {
    final extension = p.extension(path).replaceFirst('.', '').toLowerCase();
    return DioMediaType('image', extension == 'jpg' ? 'jpeg' : extension);
  }
}
