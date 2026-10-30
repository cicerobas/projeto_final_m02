import 'package:flutter/widgets.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextStyle? style;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}
