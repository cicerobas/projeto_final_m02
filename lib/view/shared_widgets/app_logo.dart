import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.router_outlined,
        size: size,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
