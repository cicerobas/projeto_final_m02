import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/di/injection.dart';
import 'package:projeto_final_m02/core/routes/app_routes.dart';
import 'package:projeto_final_m02/view/widgets/app_logo.dart';
import 'package:projeto_final_m02/viewModel/splash_view_model.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.viewModel});

  final SplashViewModel? viewModel;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final SplashViewModel _viewModel = widget.viewModel ?? getIt<SplashViewModel>();

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final hasSession = await _viewModel.hasSession();
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(hasSession ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            const AppLogo(size: 120),
            const SizedBox(height: 24),
            Text('Field S.O.', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
