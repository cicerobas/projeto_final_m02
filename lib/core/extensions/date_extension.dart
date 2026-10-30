import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  static final _format = DateFormat("dd/MM/yyyy 'às' HH:mm");

  String toDisplayLabel() => _format.format(this);
}
