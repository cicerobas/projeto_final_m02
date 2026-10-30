import 'package:projeto_final_m02/data/repositories/auth_repository.dart';

class SplashViewModel {
  final AuthRepository _authRepository;

  const SplashViewModel(this._authRepository);

  Future<bool> hasSession() async =>
      await _authRepository.getLoggedUser() != null;
}
