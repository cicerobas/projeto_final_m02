abstract final class FormValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe o e-mail';
    if (!_emailPattern.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  static String? password(String? value) =>
      value == null || value.isEmpty ? 'Informe a senha' : null;
}
