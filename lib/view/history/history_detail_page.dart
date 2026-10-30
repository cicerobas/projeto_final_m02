import 'dart:io';

import 'package:flutter/material.dart';

import 'package:projeto_final_m02/core/extensions/date_extension.dart';
import 'package:projeto_final_m02/data/models/history_entry_model.dart';
import 'package:projeto_final_m02/data/models/service_report_model.dart';
import 'package:projeto_final_m02/view/shared_widgets/info_row.dart';
import 'package:projeto_final_m02/view/shared_widgets/sync_status_badge.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryEntryModel entry;

  const HistoryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final ticket = entry.ticket;
    final report = entry.report;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Atendimento #${ticket.id}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const .fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Card(
                child: Padding(
                  padding: const .all(16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket.clientCode,
                              style: textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          SyncStatusBadge(status: report.syncStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(ticket.clientName, style: textTheme.titleLarge),
                      const SizedBox(height: 12),
                      InfoRow(icon: Icons.place_outlined, text: ticket.fullAddress),
                      const SizedBox(height: 6),
                      InfoRow(icon: Icons.schedule, text: 'Aberto em ${ticket.createdAt.toDisplayLabel()}'),
                    ],
                  ),
                ),
              ),
              if (report.syncStatus == SyncStatus.failed) ...[
                const SizedBox(height: 12),
                _SyncErrorNotice(message: report.syncError ?? ''),
              ],
              const Divider(),
              _Section(
                title: 'Problema relatado',
                children: [
                  Text(ticket.reportedCategory, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(ticket.problemDescription),
                ],
              ),
              const Divider(),
              _Section(
                title: 'Parecer técnico',
                children: [
                  Text(report.technicalCategory, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(report.procedureDescription),
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.event_available_outlined,
                    text: 'Concluído em ${report.resolvedAt.toDisplayLabel()}',
                  ),
                ],
              ),
              const Divider(),
              _Section(
                title: 'Foto',
                children: [_ReportPhoto(photoPath: report.photoPath, photoUrl: report.photoUrl)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SyncErrorNotice extends StatelessWidget {
  final String message;

  const _SyncErrorNotice({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const .all(12),
      decoration: BoxDecoration(color: colors.errorContainer, borderRadius: .circular(8)),
      child: InfoRow(
        icon: Icons.error_outline,
        text: 'Registro recusado pela API: $message',
        style: TextStyle(color: colors.onErrorContainer),
      ),
    );
  }
}

class _ReportPhoto extends StatelessWidget {
  final String? photoPath;
  final String? photoUrl;

  const _ReportPhoto({required this.photoPath, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final url = photoUrl;

    if (path != null && File(path).existsSync()) {
      return _PhotoFrame(child: Image.file(File(path), fit: BoxFit.cover, cacheWidth: 1000));
    }

    if (url != null) {
      return _PhotoFrame(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          cacheWidth: 1000,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => const _PhotoPlaceholder(
            icon: Icons.cloud_off_outlined,
            message: 'Não foi possível carregar a foto. Verifique a conexão.',
          ),
        ),
      );
    }

    return const _PhotoPlaceholder(icon: Icons.no_photography_outlined, message: 'Atendimento sem foto.');
  }
}

class _PhotoFrame extends StatelessWidget {
  final Widget child;

  const _PhotoFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: .circular(12),
      child: SizedBox(height: 260, width: double.infinity, child: child),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;

  const _PhotoPlaceholder({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 120,
      decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: .circular(12)),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(icon, size: 36, color: colors.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: .center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
