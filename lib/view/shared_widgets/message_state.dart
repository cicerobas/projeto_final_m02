import 'package:flutter/material.dart';

class MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final label = actionLabel;

    return Padding(
      padding: const .all(32),
      child: Column(
        mainAxisSize: .min,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, textAlign: .center, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, textAlign: .center, style: textTheme.bodyMedium),
          if (label != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(label)),
          ],
        ],
      ),
    );
  }
}
