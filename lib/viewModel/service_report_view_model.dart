import 'package:flutter/foundation.dart';
import 'package:projeto_final_m02/core/result/result.dart';
import 'package:projeto_final_m02/core/services/photo_service.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';

import 'package:projeto_final_m02/data/models/ticket_model.dart';
import 'package:projeto_final_m02/data/repositories/service_report_repository.dart';

class ServiceReportViewModel extends ChangeNotifier {
  final TicketModel ticket;
  final ServiceReportRepository _repository;
  final PhotoService _photoService;

  ServiceReportViewModel({
    required this.ticket,
    required this._repository,
    required this._photoService,
  });

  String? _category;
  String _description = '';
  DateTime _resolvedAt = DateTime.now();
  String? _photoPath;
  bool _isPickingPhoto = false;
  bool _isSaving = false;
  String? _feedbackMessage;

  String? get category => _category;
  String get description => _description;
  DateTime get resolvedAt => _resolvedAt;
  String? get photoPath => _photoPath;
  bool get isPickingPhoto => _isPickingPhoto;
  bool get isSaving => _isSaving;

  bool get hasChanges =>
      _category != null || _description.trim().isNotEmpty || _photoPath != null;

  DateTime get earliestResolutionDate {
    final DateTime now = DateTime.now();
    return ticket.createdAt.isAfter(now) ? now : ticket.createdAt;
  }

  void selectCategory(String? category) => _category = category;

  void updateDescription(String description) => _description = description;

  void updateResolvedAt(DateTime resolvedAt) {
    final DateTime now = DateTime.now();
    _resolvedAt = resolvedAt.isAfter(now) ? now : resolvedAt;
    notifyListeners();
  }

  Future<void> pickPhoto(PhotoSource source) async {
    if (_isPickingPhoto) return;
    _isPickingPhoto = true;
    notifyListeners();

    final Result<String?> result = await _photoService.takePhoto(source);

    switch (result) {
      case Success(value: final String path?):
        final String? previousPath = _photoPath;
        _photoPath = path;
        if (previousPath != null) await _photoService.deletePhoto(previousPath);
      case Success():
        break;
      case Failure(:final failure):
        _feedbackMessage = failure.message;
    }

    _isPickingPhoto = false;
    notifyListeners();
  }

  Future<void> removePhoto() async {
    final String? path = _photoPath;
    if (path == null) return;

    _photoPath = null;
    notifyListeners();
    await _photoService.deletePhoto(path);
  }

  Future<void> discardDraft() async {
    final String? path = _photoPath;
    _photoPath = null;
    if (path != null) await _photoService.deletePhoto(path);
  }

  Future<bool> complete() async {
    final String? category = _category;
    if (category == null || _isSaving) return false;

    _isSaving = true;
    notifyListeners();

    final Result<void> result = await _repository.completeReport(
      ServiceReportModel(
        ticketId: ticket.id,
        technicalCategory: category,
        procedureDescription: _description.trim(),
        resolvedAt: _resolvedAt,
        photoPath: _photoPath,
        createdAt: DateTime.now(),
      ),
    );

    _isSaving = false;
    if (result case Failure(:final failure)) {
      _feedbackMessage = failure.message;
    }
    notifyListeners();

    return result is Success<void>;
  }

  String? takeFeedbackMessage() {
    final String? message = _feedbackMessage;
    _feedbackMessage = null;
    return message;
  }
}
