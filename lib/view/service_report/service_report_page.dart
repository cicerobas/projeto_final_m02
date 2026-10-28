import 'package:flutter/material.dart';

class ServiceReportPage extends StatelessWidget {
  const ServiceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento')),
      body: const Center(child: Text('Formulário de atendimento')),
    );
  }
}
