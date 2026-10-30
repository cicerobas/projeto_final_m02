sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Sem conexão com a internet.']);
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([
    super.message = 'Sessão expirada. Faça login novamente.',
  ]);
}

final class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode});

  final int? statusCode;
}

final class DatabaseFailure extends AppFailure {
  const DatabaseFailure([super.message = 'Erro ao acessar os dados locais.']);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Erro inesperado. Tente novamente.']);
}

final class PhotoFailure extends AppFailure {
  const PhotoFailure([
    super.message = 'Não foi possível obter a foto. Tente novamente.',
  ]);
}
