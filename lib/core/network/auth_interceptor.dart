import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

class AuthInterceptor extends Interceptor {
  final TokenProvider _tokenProvider;

  AuthInterceptor(this._tokenProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenProvider();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
