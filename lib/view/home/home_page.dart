import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chamados'),
        actions: [
          IconButton(
            tooltip: 'Histórico',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.history),
          ),
        ],
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.serviceReport),
          child: const Text('Abrir atendimento'),
        ),
      ),
    );
  }
}
