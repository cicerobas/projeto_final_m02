import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
          child: const Text('Entrar'),
        ),
      ),
    );
  }
}
