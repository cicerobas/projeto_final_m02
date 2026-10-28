enum TicketStatus {
  active('ativo'),
  resolved('resolvido');

  const TicketStatus(this.apiValue);

  final String apiValue;

  static TicketStatus fromApiValue(String value) => TicketStatus.values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => throw FormatException('Unknown ticket status: $value'),
  );
}
