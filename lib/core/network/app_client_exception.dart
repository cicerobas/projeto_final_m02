import 'package:projeto_final_m02/core/errors/app_failure.dart';

sealed class AppClientException implements Exception {
  const AppClientException([this.message]);

  final String? message;
}

final class NetworkException extends AppClientException {
  const NetworkException();
}

final class UnauthorizedException extends AppClientException {
  const UnauthorizedException([super.message]);
}

final class ServerException extends AppClientException {
  const ServerException({this.statusCode, String? message}) : super(message);

  final int? statusCode;
}

final class UnknownClientException extends AppClientException {
  const UnknownClientException([super.message]);
}

extension AppClientExceptionMapper on AppClientException {
  AppFailure toFailure() => switch (this) {
    NetworkException() => const NetworkFailure(),
    UnauthorizedException(:final message) =>
      message == null
          ? const UnauthorizedFailure()
          : UnauthorizedFailure(message),
    ServerException(:final statusCode, :final message) => ServerFailure(
      message ?? 'Erro no servidor. Tente novamente.',
      statusCode: statusCode,
    ),
    UnknownClientException() => const UnknownFailure(),
  };
}
