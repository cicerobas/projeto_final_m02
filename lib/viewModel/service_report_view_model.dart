import 'package:flutter/foundation.dart';

import 'package:projeto_final_m02/data/models/ticket_model.dart';

class ServiceReportViewModel extends ChangeNotifier {
  final TicketModel ticket;

  ServiceReportViewModel({required this.ticket});

  String? _category;
  String _description = '';
  DateTime _resolvedAt = DateTime.now();

  String? get category => _category;
  String get description => _description;
  DateTime get resolvedAt => _resolvedAt;

  bool get hasChanges => _category != null || _description.trim().isNotEmpty;

  DateTime get earliestResolutionDate {
    final now = DateTime.now();
    return ticket.createdAt.isAfter(now) ? now : ticket.createdAt;
  }

  void selectCategory(String? category) => _category = category;

  void updateDescription(String description) => _description = description;

  void updateResolvedAt(DateTime resolvedAt) {
    final now = DateTime.now();
    _resolvedAt = resolvedAt.isAfter(now) ? now : resolvedAt;
    notifyListeners();
  }
}
