import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_final_m02/core/di/injection.dart';
import 'package:projeto_final_m02/core/routes/app_routes.dart';
import 'package:projeto_final_m02/core/utils/form_validators.dart';
import 'package:projeto_final_m02/view/widgets/app_logo.dart';
import 'package:projeto_final_m02/viewModel/login_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.viewModel});

  final LoginViewModel? viewModel;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel _viewModel = widget.viewModel ?? getIt<LoginViewModel>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.login(email: _emailController.text, password: _passwordController.text);
    if (!success || !mounted) return;

    TextInput.finishAutofillContext();
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const .all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        const _LoginHeader(),
                        const SizedBox(height: 32),
                        _EmailField(
                          controller: _emailController,
                          enabled: !_viewModel.isLoading,
                          onChanged: _viewModel.clearError,
                        ),
                        const SizedBox(height: 16),
                        _PasswordField(
                          controller: _passwordController,
                          enabled: !_viewModel.isLoading,
                          isVisible: _viewModel.isPasswordVisible,
                          onToggleVisibility: _viewModel.togglePasswordVisibility,
                          onChanged: _viewModel.clearError,
                          onSubmitted: _submit,
                        ),
                        if (_viewModel.errorMessage case final message?) ...[
                          const SizedBox(height: 16),
                          _ErrorBanner(message: message),
                        ],
                        const SizedBox(height: 24),
                        _SubmitButton(
                          isLoading: _viewModel.isLoading,
                          loadingMessage: _viewModel.loadingMessage,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const AppLogo(size: 160),
        const SizedBox(height: 24),
        Text('Field S.O.', textAlign: TextAlign.center, style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Entre com seu e-mail e senha.', textAlign: TextAlign.center, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.enabled, required this.onChanged});

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.email_outlined)),
      validator: FormValidators.email,
      onChanged: (_) => onChanged(),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: !isVisible,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: FormValidators.password,
      onChanged: (_) => onChanged(),
      onFieldSubmitted: (_) => onSubmitted(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.loadingMessage, required this.onPressed});

  final bool isLoading;
  final String loadingMessage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? Row(
              mainAxisSize: .min,
              children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 12),
                Text(loadingMessage),
              ],
            )
          : const Text('Entrar'),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
