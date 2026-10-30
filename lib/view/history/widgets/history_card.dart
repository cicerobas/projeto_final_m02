import 'package:flutter/material.dart';
import 'package:projeto_final_m02/core/extensions/date_extension.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/view/shared_widgets/info_row.dart';
import 'package:projeto_final_m02/view/shared_widgets/sync_status_badge.dart';

class HistoryCard extends StatelessWidget {
  final HistoryEntryModel entry;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${entry.ticket.id} [${entry.ticket.clientCode}]',
                      style: textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  SyncStatusBadge(status: entry.report.syncStatus),
                ],
              ),
              const SizedBox(height: 8),
              Text(entry.ticket.clientName, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.build_outlined,
                text: entry.report.technicalCategory,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.event_available_outlined,
                text:
                    'Concluído em ${entry.report.resolvedAt.toDisplayLabel()}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
