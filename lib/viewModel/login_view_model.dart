import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:projeto_final_m02/data/repositories/ticket_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TicketRepository _ticketRepository;

  LoginViewModel({
    required this._authRepository,
    required this._ticketRepository,
  });

  bool _isLoading = false;
  String _loadingMessage = '';
  String? _errorMessage;
  bool _isPasswordVisible = false;

  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading('Entrando...');

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    if (result case Failure(:final failure)) {
      _errorMessage = failure.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _setLoading('Baixando seus chamados...');
    await _ticketRepository.syncTickets();

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void _setLoading(String message) {
    _isLoading = true;
    _loadingMessage = message;
    _errorMessage = null;
    notifyListeners();
  }
}
