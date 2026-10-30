import 'package:flutter/foundation.dart';

import 'package:projeto_final_m02/core/errors/app_failure.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/services/connectivity_service.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/sync_summary.dart';
import 'package:projeto_final_m02/data/repositories/auth_repository.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';
import 'package:projeto_final_m02/data/repositories/sync_repository.dart';

class HistoryViewModel extends ChangeNotifier {
  final ServiceReportRepository _serviceReportRepository;
  final SyncRepository _syncRepository;
  final AuthRepository _authRepository;
  final ConnectivityService _connectivityService;

  HistoryViewModel({
    required this._serviceReportRepository,
    required this._syncRepository,
    required this._authRepository,
    required this._connectivityService,
  });

  List<HistoryEntryModel> _entries = [];
  String _query = '';
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSessionExpired = false;
  bool _isDisposed = false;
  String? _errorMessage;
  String? _feedbackMessage;

  List<HistoryEntryModel> get entries {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return List.unmodifiable(_entries);
    return _entries.where((entry) => _matches(entry, query)).toList();
  }

  bool get hasEntries => _entries.isNotEmpty;
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isSessionExpired => _isSessionExpired;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await loadHistory();
    await refresh();
  }

  Future<void> loadHistory() async {
    final result = await _serviceReportRepository.getHistory();

    switch (result) {
      case Success(:final value):
        _entries = value;
        _errorMessage = null;
      case Failure(:final failure):
        _errorMessage = failure.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh({bool isManual = false}) async {
    if (_isRefreshing) return;
    if (!await _connectivityService.isOnline()) {
      if (isManual) {
        _feedbackMessage =
            'Sem conexão. Exibindo o histórico salvo no aparelho.';
        notifyListeners();
      }
      return;
    }

    _isRefreshing = true;
    notifyListeners();

    final Result<SyncSummary> result = await _syncRepository.syncAll();
    _isRefreshing = false;

    switch (result) {
      case Success():
        break;
      case Failure(failure: UnauthorizedFailure()):
        await _authRepository.logout();
        _isSessionExpired = true;
      case Failure(:final failure):
        if (isManual) _feedbackMessage = failure.message;
    }

    await loadHistory();
  }

  void search(String query) {
    _query = query;
    notifyListeners();
  }

  String? takeFeedbackMessage() {
    final message = _feedbackMessage;
    _feedbackMessage = null;
    return message;
  }

  static bool _matches(HistoryEntryModel entry, String query) =>
      entry.ticket.id.toString().contains(query) ||
      entry.ticket.clientCode.toLowerCase().contains(query) ||
      entry.ticket.clientName.toLowerCase().contains(query);

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
