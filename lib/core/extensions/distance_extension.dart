import 'package:intl/intl.dart';

extension DistanceExtension on double {
  static final _format = NumberFormat('#,##0.0', 'pt_BR');

  String toDistanceLabel() => '${_format.format(this)} km';
}
