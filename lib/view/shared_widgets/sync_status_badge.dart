import 'package:flutter/material.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (
      String label,
      IconData icon,
      Color background,
      Color foreground,
    ) = switch (status) {
      SyncStatus.synced => (
        'Sincronizado',
        Icons.cloud_done_outlined,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      SyncStatus.pending => (
        'Pendente de envio',
        Icons.cloud_upload_outlined,
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      SyncStatus.failed => (
        'Erro de envio',
        Icons.error_outline,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };

    return Container(
      padding: const .symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: .circular(16)),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: foreground, fontWeight: .w600),
          ),
        ],
      ),
    );
  }
}
