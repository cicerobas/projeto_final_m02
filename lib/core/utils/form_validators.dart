abstract final class FormValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _repeatedSpaces = RegExp(r'\s+');

  static const minDescriptionLength = 10;

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe o e-mail';
    if (!_emailPattern.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) =>
      value == null || value.isEmpty ? 'Informe a senha' : null;

  static String? category(String? value) =>
      value == null ? 'Selecione a categoria técnica' : null;

  static String? procedureDescription(String? value) {
    final length = (value ?? '').trim().replaceAll(_repeatedSpaces, ' ').length;

    if (length == 0) return 'Descreva o procedimento realizado';
    if (length < minDescriptionLength) {
      return 'Tamanho mínimo da descrição: $minDescriptionLength caracteres';
    }
    return null;
  }
}
