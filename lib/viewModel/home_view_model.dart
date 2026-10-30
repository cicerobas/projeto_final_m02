import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/services/connectivity_service.dart';
import 'package:projeto_final_m02/core/services/location_service.dart';
import 'package:projeto_final_m02/core/utils/distance_calculator.dart';
import 'package:projeto_final_m02/data/models/sync_summary.dart';
import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:projeto_final_m02/data/repositories/sync_repository.dart';
import 'package:projeto_final_m02/data/repositories/ticket_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final TicketRepository _ticketRepository;
  final SyncRepository _syncRepository;
  final AuthRepository _authRepository;
  final LocationService _locationService;
  final ConnectivityService _connectivityService;

  HomeViewModel({
    required this._ticketRepository,
    required this._syncRepository,
    required this._authRepository,
    required this._locationService,
    required this._connectivityService,
  });

  List<TicketModel> _tickets = [];
  LocationAvailable? _location;
  LocationIssue? _locationIssue;
  bool _isLoading = true;
  bool _isLocating = false;
  bool _isSyncing = false;
  bool _isOnline = true;
  bool _isSessionExpired = false;
  bool _isDisposed = false;
  String? _userName;
  String? _errorMessage;
  String? _feedbackMessage;
  StreamSubscription<bool>? _connectivitySubscription;

  List<TicketModel> get tickets => List.unmodifiable(_tickets);
  LocationIssue? get locationIssue => _locationIssue;
  bool get isSortedByDistance => _location != null;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  bool get isSessionExpired => _isSessionExpired;
  String? get userName => _userName;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isOnline = await _connectivityService.isOnline();
    _connectivitySubscription = _connectivityService.onStatusChanged.listen(
      _onConnectivityChanged,
    );
    _userName = (await _authRepository.getLoggedUser())?.name;

    await loadTickets();
    await refreshLocation();
    await synchronize();
  }

  Future<void> loadTickets() async {
    final result = await _ticketRepository.getActiveTickets();

    switch (result) {
      case Success(:final value):
        _tickets = _withDistances(value);
        _errorMessage = null;
      case Failure(:final failure):
        _errorMessage = failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAfterServiceReport() async {
    await loadTickets();
    await synchronize();
  }

  Future<void> refreshLocation() async {
    if (_isLocating) return;
    _isLocating = true;

    final result = await _locationService.getCurrentLocation();

    switch (result) {
      case LocationAvailable():
        _location = result;
        _locationIssue = null;
      case LocationUnavailable(:final issue):
        _locationIssue = issue;
    }

    _isLocating = false;
    _tickets = _withDistances(_tickets);
    notifyListeners();
  }

  void onAppResumed() {
    if (_locationIssue == LocationIssue.serviceDisabled ||
        _locationIssue == LocationIssue.permissionDeniedForever) {
      refreshLocation();
    }
  }

  Future<void> handleLocationIssue() async {
    final issue = _locationIssue;
    if (issue == null) return;

    if (issue == LocationIssue.serviceDisabled ||
        issue == LocationIssue.permissionDeniedForever) {
      await _locationService.openSettings(issue);
    } else {
      await refreshLocation();
    }
  }

  Future<void> synchronize({bool isManual = false}) async {
    if (_isSyncing) return;
    if (!_isOnline) {
      if (isManual) {
        _feedbackMessage = 'Sem conexão. Os chamados salvos no aparelho continuam disponíveis.';
        notifyListeners();
      }
      return;
    }

    _isSyncing = true;
    notifyListeners();

    final Result<SyncSummary> result = await _syncRepository.syncAll();
    _isSyncing = false;

    switch (result) {
      case Success(:final value):
        await loadTickets();
        _feedbackMessage = _describe(value, isManual: isManual);
      case Failure(failure: UnauthorizedFailure()):
        await _authRepository.logout();
        _isSessionExpired = true;
      case Failure(:final failure):
        if (isManual) _feedbackMessage = failure.message;
    }

    notifyListeners();
  }

  Future<void> logout() => _authRepository.logout();

  String? takeFeedbackMessage() {
    final message = _feedbackMessage;
    _feedbackMessage = null;
    return message;
  }

  void _onConnectivityChanged(bool isOnline) {
    final reconnected = isOnline && !_isOnline;
    _isOnline = isOnline;
    notifyListeners();

    if (reconnected) unawaited(synchronize());
  }

  List<TicketModel> _withDistances(List<TicketModel> tickets) {
    final location = _location;
    if (location == null) return tickets;

    return tickets
        .map(
          (ticket) => ticket.withDistance(
            DistanceCalculator.haversineKm(
              fromLatitude: location.latitude,
              fromLongitude: location.longitude,
              toLatitude: ticket.latitude,
              toLongitude: ticket.longitude,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
  }

  static String? _describe(SyncSummary summary, {required bool isManual}) {
    final List<String> parts = [
      if (summary.sent > 0)
        summary.sent == 1
            ? '1 atendimento enviado'
            : '${summary.sent} atendimentos enviados',
      if (summary.rejected > 0)
        summary.rejected == 1
            ? '1 atendimento não foi aceito. Veja o histórico.'
            : '${summary.rejected} atendimentos não foram aceitos. Veja o histórico.',
    ];

    if (parts.isEmpty) return isManual ? 'Chamados atualizados.' : null;
    return parts.join(' ~ ');
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
